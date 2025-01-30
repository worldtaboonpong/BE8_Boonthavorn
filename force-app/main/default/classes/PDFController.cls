global without sharing class PDFController {

    public List<SObject> tableRecord { get; set; }
    public List<String> tableHeader { get; set; }
    public List<String> fieldAPI { get; set; }
    public static final String CONSTANT_PDF_FILE_EXTENSION = '.PDF';
    

    public PDFController(){
        
        System.debug('fieldSetName' + ApexPages.currentPage().getParameters().get('FieldSetDevName'));
        System.debug('sObjectName' + ApexPages.currentPage().getParameters().get('ObjectAPIName'));
        System.debug('conditionId' + ApexPages.currentPage().getParameters().get('Id'));

        String fieldSetDevName = ApexPages.currentPage().getParameters().get('FieldSetDevName');
        String objectAPIName = ApexPages.currentPage().getParameters().get('ObjectAPIName');
        String conditionId = ApexPages.currentPage().getParameters().get('Id');

        List<Schema.FieldSetMember> targetFieldSet = getFieldSet(objectAPIName, fieldSetDevName);
        String query = getQueryFromFieldset(targetFieldSet, objectAPIName, conditionId);
        System.debug(query);
        

        this.tableRecord = (!String.isBlank(query)&&query!=null)?Database.query(query):null;
        this.tableHeader = (targetFieldSet!=null)?getTableHeaderList(targetFieldSet):null;
        this.fieldAPI = (targetFieldSet!=null)?getFieldAPIList(targetFieldSet):null;

        System.debug('this.tableRecord '+ this.tableRecord);

        System.debug('this.tableHeader '+ this.tableHeader);

        System.debug('this.fieldAPI '+ this.fieldAPI);
    }


    private static List<Schema.FieldSetMember> getFieldSet(String sObjectAPIName, String fieldsetDevName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sObjectAPIName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj;

        try{
            fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldsetDevName);    
            return fieldSetObj.getFields();
        }catch (Exception e){
            return null;
        }
            
    }

    private static String getQueryFromFieldset(List<Schema.FieldSetMember> fieldsetMember, String sObjectAPIName, String queryConditionId){
        
        List<String> fieldSetList  = new List<String>();
        String query;

        if (fieldsetMember!= null && !fieldsetMember.isEmpty()) {
            query = 'SELECT ';
            
            for(Schema.FieldSetMember eachFieldsetMember : fieldsetMember) {
                
                fieldSetList.add(eachFieldsetMember.getFieldPath());
            }
            query += String.join(fieldSetList,',');
            query += ' FROM ' + sObjectAPIName + ' WHERE Id =\'' + queryConditionId +'\'';
        }


        System.debug(query);

        return query;
    }

    private static List<String> getTableHeaderList(List<Schema.FieldSetMember> fieldsetMember){

        List<String> tableheaderList  = new List<String>();

        for(Schema.FieldSetMember eachFieldsetMember : fieldsetMember) {
            
            tableheaderList.add(eachFieldsetMember.getLabel());
        }

        return tableheaderList;
    }

    private static List<String> getFieldAPIList(List<Schema.FieldSetMember> fieldsetMember){

        List<String> fieldAPIList  = new List<String>();

        for(Schema.FieldSetMember eachFieldsetMember : fieldsetMember) {
            
            fieldAPIList.add(eachFieldsetMember.getFieldPath());
        }

        return fieldAPIList;
    }

    @AuraEnabled
    public static Boolean SaveQuotation(String recordId){
        Blob pdfData = null;
        if(Test.isRunningTest()) { 
            pdfData = blob.valueOf('Unit.Test');
          } else {
            pdfData = new PageReference('/apex/PDFPage?oppId='+recordId+'&renderredDraft=F').getContent();
          }
 
        User integrationUser = [select id, name from User where Name LIKE '%Integration%' and isActive = true limit 1];
        Opportunity updateOpp = [select id, Quotation_No__c, Recordtype.DeveloperName FROM Opportunity WHERE id =: recordId limit 1];
        //add on to updateOpp
        // tms_QuotationGenerated__c,Recordtype.DeveloperName
        //String runningNumber = tms_RunningNumberUtility.generateRunningNumber(recordId, null);
        system.debug('integrationUser : '+integrationUser);
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = pdfData;
        ContVerFile.Title = updateOpp.Quotation_No__c;
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient = updateOpp.Quotation_No__c+CONSTANT_PDF_FILE_EXTENSION;
        insert ContVerFile;

        ContentVersion targetContentVersion = [select id, ContentDocumentId from ContentVersion where id =: ContVerFile.Id];

        system.debug('debug conver : '+targetContentVersion);

        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = targetContentVersion.ContentDocumentId;
        cDe.LinkedEntityId = recordId;
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        insert cDe;

        ContentDocument newContentDoc = new ContentDocument(Id = targetContentVersion.ContentDocumentId, OwnerId = integrationUser.Id);
        update newContentDoc;

        //QuotationGenerated --> ? , What condition to use */
        //updateOpp.tms_QuotationGenerated__c = true;
        if(updateOpp.Recordtype.DeveloperName != 'Rent_Event') updateOpp.StageName = 'Negotiation in Progress';
        update updateOpp;
        System.debug(newContentDoc.Id);
        return true;
    }

    @AuraEnabled
    public static String GeneratePDFContent(String recordId){
        String returnResponse = '';

        
        try{
            Id id = recordId;
            String recordType = String.valueOf(id.getSobjectType());
            if(recordType == 'Opportunity'){
                List<Opportunity> oppList = OpportunitySelector.getOpportunityInfoByOppId(new Set<Id>{recordId});
                System.debug(oppList);

                List<Opportunity> targetOpp = [SELECT Id,Approve_Status__c,Owner.Profile.Name FROM Opportunity WHERE Id =:oppList.get(0).Id];


                String quotationLanguage = oppList.get(0).Quotation_Language__c == 'EN' ? 'English' : 'Thai';
                String rentalType = oppList.get(0).Rental_Type__c;
                if(rentalType == 'OP_Rental	') rentalType = 'Space_Rental';
                System.debug('Rental: ' +  rentalType);
                System.debug('Lang: ' + quotationLanguage);

                

                // add condition to not delete fixed content after approval
                //check if there's an empty signature spot for manager
                String deleteBlankSignature = '';
                if(targetOpp[0].Approve_Status__c == 'Approved'){
                
                List<PDF_Content__c> managerSignatureTemplate = [SELECT Expression_Criteria__c FROM PDF_Content__c WHERE Opportunity__c =: recordId ];
                for(PDF_Content__c record : managerSignatureTemplate){
                    if(record.Expression_Criteria__c == 'Approve_Status__c != "Approved"'){
                        deleteBlankSignature = (targetOpp[0].Approve_Status__c == 'Approved')? 'AND Expression_Criteria__c Like \'%Approve_Status__c != "Approved"%\'' : '';
                        System.debug(deleteBlankSignature);
                        Opportunity oppSigned = new Opportunity(Id=targetOpp[0].Id,  Refresh_Approved__c = true);
                        update oppSigned;
                        break;
                    }
                }
                }
                

                PDFContentUtility pdfUtil = new PDFContentUtility();
                pdfUtil.removeRecordByCondition('Opportunity__c = \'' + recordId + '\' '+ deleteBlankSignature);
                pdfUtil.generatePDFContent(recordId, quotationLanguage, 'Opportunity__c',rentalType);

                
                Opportunity updateOpp = new Opportunity(Id=oppList.get(0).Id, IsPDFContentGenerated__c=true);
                
                update updateOpp;
                System.debug('Update Opp Success');

            }else if(recordType == 'Contract__c'){
                List<Contract__c> contractList = ContractSelector.getContractInfoByOppId(new Set<Id>{recordId});
                System.debug(contractList);
                // String quotationLanguage = contractList.get(0).Quotation_Language__c == 'EN' ? 'English' : 'Thai';
                String quotationLanguage = 'Thai';
                String rentalType = contractList.get(0).Rental_Type__c;
                System.debug('Rental: ' +  rentalType);
                System.debug('Lang: ' + quotationLanguage);

                List<Contract__c> targetOpp = [SELECT Approve_Status__c,Owner.Profile.Name FROM Contract__c WHERE Id =:contractList.get(0).Id];
                if(targetOpp[0].Owner.Profile.Name == 'Manager' && targetOpp[0].Approve_Status__c != 'Approved'){
                    Contract__c updateConApproval = new Contract__c(Id=contractList.get(0).Id, Approve_Status__c = 'Approved');
                    update updateConApproval;
                }


                String deleteBlankSignature = '';
                if(targetOpp[0].Approve_Status__c == 'Approved'){
                    if(targetOpp[0].Owner.Profile.Name != 'Manager'){
                        Contract__c contractSigned = new Contract__c(Id=recordId,  Refresh_Approved__c = true);
                            update contractSigned;
                            
                    }
                    return returnResponse;
                }

                PDFContentUtility pdfUtil = new PDFContentUtility();
                pdfUtil.removeRecordByCondition(recordType +' = \'' + recordId + '\'');
                pdfUtil.generatePDFContent(recordId, quotationLanguage, 'Contract__c', rentalType);

                Contract__c updateContract = new Contract__c(Id=contractList.get(0).Id);
                update updateContract;
                System.debug('Update Contract Success');
                
            }
            return returnResponse;
        }
        catch(Exception ex){
            returnResponse = 'Failed : '+ex.getCause()+', '+ex.getMessage()+', '+ex.getLineNumber();
            return returnResponse;
        }
        
    }
}
public with sharing class PDFRenderController {

	public List<PDF_Content__c> contentList { get; set; }
    public Boolean isDraftRenderred { get; set; }
    public Boolean isContractType {get;set;}
    public String contractNumber{get;set;}
    public String serviceNumber{get;set;}
    public String jsonContentList { get; set; }
    public List<String> contractOrigins{get;set;}
    public String buildingLogo{get;set;}

    public PDFRenderController() {
        this.contractOrigins = new List<String>{'ต้นฉบับ','คู่ฉบับ'};

    	Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=Quotation PDF.pdf');
        System.debug(ApexPages.currentPage().getParameters());
        Id oppId =ApexPages.currentPage().getParameters().get('oppId');
        String recordType = String.valueOf(oppId.getSobjectType());
        // System.debug(recordType); contract__c?
        String renderredDraft = ApexPages.currentPage().getParameters().get('renderredDraft');
        System.debug('renderredDraft:' + renderredDraft);
        // * User request to remove draft watermark
        // this.isDraftRenderred = (renderredDraft == 'T')?true:false;
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        System.debug(profileName);
        if(profileName == 'Manager'){
            this.isDraftRenderred = false;
        }else{
            SOQLBuilder queryString = new SOQLBuilder(recordType);
            queryString.addCondition('WHERE Id =:oppId');
            if(recordType == 'Opportunity'){
                Opportunity opp = Database.query(queryString.getQueryString());
                if(opp.Approve_Status__c == 'Approved'){
                    this.isDraftRenderred = false;
                }else{
                    this.isDraftRenderred = true;
                }
            } else if(recordType == 'Contract__c'){
                Contract__c contract = Database.query(queryString.getQueryString());
                if(contract.Approve_Status__c =='Approved'){
                    this.isDraftRenderred = false;
                }else{
                    this.isDraftRenderred = true;
                }
            }
            else{
                this.isDraftRenderred = true;
            }
            
            
        }
        Id recordTypeId = Schema.SObjectType.PDF_Content__c.getRecordTypeInfosByName().get('Content').getRecordTypeId();
        String currentRecordType = String.valueOf(oppId.getSobjectType());
        List<PDF_Content__c> pdfContentList;
        if(oppId == null){
            pdfContentList = new List<PDF_Content__c>();
        }else if(currentRecordType == 'Opportunity'){
            pdfContentList = [SELECT Display_Content__c, Content__c,Sequence__c, Is_Show_Sequence__c FROM PDF_Content__c WHERE Opportunity__c = :oppId AND Is_Active__c =: true AND RecordType.Id =: recordTypeId  ORDER BY Master_Content__r.Sequence__c ASC];
        }else if(currentRecordType == 'Contract__c'){
            pdfContentList = [SELECT Display_Content__c, Content__c,Sequence__c, Is_Show_Sequence__c,Contract__c,Contract__r.Contract_Number__c,Contract__r.Contract_Service_No__c,Master_Content__r.Content_Description__c, Contract__r.Building__r.Building_Logo__c FROM PDF_Content__c WHERE Contract__c = :oppId AND Is_Active__c =: true AND RecordType.Id =: recordTypeId  ORDER BY Master_Content__r.Sequence__c ASC];
            this.buildingLogo = pdfContentList[0].Contract__r.Building__r.Building_Logo__c;
            // this.buildingLogo = pdfContentList[0].Contract__r.Building__r.Building_Logo__c.substringBetween('src="','"');
            // this.buildingLogo = this.buildingLogo.replace('<img', '<img class="logoHeader"')
            // .replace('<p>', '')
            // .replace('</p>', '');
        }
        for (PDF_Content__c pdfContent : pdfContentList) {
            pdfContent.Content__c = pdfContent.Content__c?.unescapeHtml4();
            pdfContent.Display_Content__c = pdfContent.Display_Content__c?.unescapeHtml4();
            // pdfContent.Content__c = pdfContent.Content__c.replace('<img','<img class="pagebreak imageQuotation"');
            // pdfContent.Display_Content__c =  pdfContent.Display_Content__c.replace('<img','img class="pagebreak imageQuotation"');
            System.debug(pdfContent.Display_Content__c);

            // if(contractNumber == null && pdfContent.Contract__r.Contract_Number__c != null ){
            //     this.contractNumber = pdfContent.Contract__r.Contract_Number__c;
            // }
        }
        this.contentList = pdfContentList;
        this.jsonContentList = JSON.serialize(this.contentList);
        System.debug('Content List :--> '+this.jsonContentList);
        //get logo

    }
}
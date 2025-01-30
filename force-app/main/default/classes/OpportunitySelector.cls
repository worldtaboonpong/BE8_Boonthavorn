public class OpportunitySelector {

    public static List<Opportunity> getCurrentVersion(Set<Id> oppIdSet) {
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [SELECT Id, CurrentVersion__c FROM Opportunity WHERE Id IN : oppIdSet];
        return oppList;
    }

    public static void insertOpportunity(List<Opportunity> oppList) {
        if (oppList.size() > 0) {
            insert oppList;
        }
    }

    public static void updateOpportunity(List<Opportunity> oppList) {
        if (oppList.size() > 0) {
            update oppList;
        }
    }

    public static void upsertOpportunity(List<Opportunity> oppList) {
        if (oppList.size() > 0) {
            upsert oppList;
        }
    }

    public static List<Opportunity> getOpportunityApproverCriteriaInfo(Set<Id> idSet) {

        List<Opportunity> oppInfoList = [SELECT Shop_Name__c
                                         FROM Opportunity 
                                         WHERE Id IN: idSet];
        return oppInfoList;
    }

    public static List<Opportunity> getOpportunityOwner(Set<Id> idSet) {

        List<Opportunity> oppInfoList = [SELECT Id, OwnerId, Owner.Name
                                         FROM Opportunity 
                                         WHERE Id IN: idSet];
        return oppInfoList;
    }

    public static List<Opportunity> getOpportunityInfoByOppId(Set<Id> oppIdSet) {
        DescribeSObjectResult describeResult = Opportunity.getSObjectType().getDescribe();
        Set<String> queryFieldSet = describeResult.fields.getMap().keySet();
        String queryFieldString = String.join(new List<String>(queryFieldSet), ',');
        //String addOnField = ',Parent_Contract__r.RoomNumber__c,Parent_Contract__r.Total_Area_sq_m__c,Contact_Name__r.Name';
        String addOnField = ',Parent_Contract__r.Unit_No__c,Parent_Contract__r.Agreement_Total_Area__c';
        String queryString = 'SELECT ' + queryFieldString + addOnField + ' FROM Opportunity WHERE Id IN: oppIdSet';
        List<Opportunity> oppInfoList = Database.query(queryString);
        return oppInfoList;
    }

    public static List<SObject> getRelatedOpportunityInfoByOppId(String objectName, Set<Id> oppIdSet) {
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Set<String> queryFieldSet = describeResult.fields.getMap().keySet();
        String queryFieldString = String.join(new List<String>(queryFieldSet), ',');
        String queryString = 'SELECT ' + queryFieldString + ' FROM ' + objectName + ' WHERE Opportunity__c IN: oppIdSet';
        System.debug(queryString);
        List<SObject> relatedOppInfoList = Database.query(queryString);
        System.debug(relatedOppInfoList);
        return relatedOppInfoList;
    }

    public static List<SObject> getRelatedOpportunityInfoByOppId(String addedFieldName, String objectName, Set<Id> oppIdSet) {
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Set<String> queryFieldSet = describeResult.fields.getMap().keySet();
        String queryFieldString = String.join(new List<String>(queryFieldSet), ',');
        String queryString = 'SELECT ' + addedFieldName + ', ' + queryFieldString + ' FROM ' + objectName + ' WHERE Opportunity__c IN: oppIdSet';
        System.debug(queryString);
        List<SObject> relatedOppInfoList = Database.query(queryString);
        System.debug(relatedOppInfoList);
        return relatedOppInfoList;
    }
    
    public static List<OpportunityLineItem__c> getOpportunityLineInfoByOppId(Set<Id> oppIdSet) {
        List<OpportunityLineItem__c> oppLineList = [SELECT Id, Unit__c, Opportunity__r.Estimated_Contract_Start_Date__c, Opportunity__r.Estimated_Contract_End_Date__c
                                                        FROM OpportunityLineItem__c
                                                        WHERE Opportunity__c IN: oppIdSet];
        return oppLineList;
    }

    public static List<ListView> getOpportunityListView(String developerName) {
        List<ListView> listviews = new List<ListView>();
        listviews = [SELECT Id, Name, DeveloperName 
                    FROM ListView 
                    WHERE SobjectType = 'Opportunity' AND 
                        DeveloperName =: developerName];
        return listviews;
    }

    public static List<OpportunityPrice__c> getOpportunityPriceByOppPeriodId(Set<Id> oppPeriodIdSet) {
        List<OpportunityPrice__c> oppPriceInfoList = [SELECT Id
                                                          FROM OpportunityPrice__c
                                                          WHERE OpportunityPeriod__c IN: oppPeriodIdSet];
        return oppPriceInfoList;
    }

    public static List<OpportunityDepositExpense__c> getSecurityDepositHeaderByOppId(Set<Id> oppIdSet) {
        List<OpportunityDepositExpense__c> oppDepositExpenseList = [SELECT Id
                                                                    FROM OpportunityDepositExpense__c
                                                                    WHERE (Type__c =: Constant.TYPE_SECURITY_DEPOSIT
                                                                            OR Type__c =: Constant.TYPE_CARRIED_DEPOSIT)
                                                                            AND Opportunity__c IN: oppIdSet];
        return oppDepositExpenseList;
    }

    public static List<OpportunityPrice__c> getSecurityDepositPriceByOppId(Set<Id> oppIdSet) {
        List<OpportunityPrice__c> oppPriceInfoList = [SELECT Id
                                                          FROM OpportunityPrice__c
                                                          WHERE (DepositExpenseType__c =: Constant.TYPE_SECURITY_DEPOSIT
                                                                OR DepositExpenseType__c =: Constant.TYPE_CARRIED_DEPOSIT)
                                                                AND Opportunity__c IN: oppIdSet];
        return oppPriceInfoList;
    }

    public static List<OpportunityPrice__c> getFullAndAmortizedPriceByOppId(Set<Id> oppIdSet) {
        List<OpportunityPrice__c> oppPriceInfoList = [SELECT Id
                                                          FROM OpportunityPrice__c
                                                          WHERE TypeGroup__c =: Constant.TYPE_EXPENSE
                                                                AND SubType__c !=: OpportunityController.TYPE_INSTALLMENT
                                                                AND Opportunity__c IN: oppIdSet];
        return oppPriceInfoList;
    }
}
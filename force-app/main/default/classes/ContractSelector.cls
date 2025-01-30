public with sharing class ContractSelector {
    public static List<Contract__c> getContractInfoByOppId(Set<Id> contractIdSet) {
        DescribeSObjectResult describeResult = Contract__c.getSObjectType().getDescribe();
        System.debug(describeResult);
        Set<String> queryFieldSet = describeResult.fields.getMap().keySet();
        System.debug(queryFieldSet);
        String queryFieldString = String.join(new List<String>(queryFieldSet), ',');
        // String addOnField = ',Unit_No__c,Agreement_Total_Area__c';
        String queryString = 'SELECT ' + queryFieldString + ' FROM Contract__c WHERE Id IN: contractIdSet';
        List<Contract__c> contractInfoList = Database.query(queryString);
        System.debug(contractInfoList);
        return contractInfoList;
    }
}

// public with sharing class OpportunitySelector {
//     public static List<Opportunity> getOpportunityInfoByOppId(Set<Id> oppIdSet) {
//         DescribeSObjectResult describeResult = Opportunity.getSObjectType().getDescribe();
//         Set<String> queryFieldSet = describeResult.fields.getMap().keySet();
//         String queryFieldString = String.join(new List<String>(queryFieldSet), ',');
//         System.debug('describeResult: ' + describeResult);
//         System.debug('queryFieldString: ' + queryFieldString);
//         String addOnField = ',Parent_Contract__r.Unit_No__c,Parent_Contract__r.Agreement_Total_Area__c';
//         String queryString = 'SELECT ' + queryFieldString + addOnField + ' FROM Opportunity WHERE Id IN: oppIdSet';
//         List<Opportunity> oppInfoList = Database.query(queryString);
//         return oppInfoList;
//     }
// }
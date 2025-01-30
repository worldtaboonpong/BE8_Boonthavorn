public class Reset_RunningNumber_Batch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Quote_Billboard__c, Quote_Event__c, Quote_Space__c, Contract_Space__c,';
        query += 'Contract_Service__c, Contract_OP__c, Contract_Event__c, Contract_Billboard__c FROM Branch__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Branch__c> scope) {
        for(Branch__c setting : scope) {
            setting.Quote_Space__c = setting.Quote_Event__c = setting.Quote_Billboard__c = 1;
            setting.Contract_Space__c = setting.Contract_Service__c = setting.Contract_OP__c = 1;
            setting.Contract_Event__c = setting.Contract_Billboard__c = 1;
        }
        update(scope);
    }

    public void finish(Database.BatchableContext BC){

    }
}
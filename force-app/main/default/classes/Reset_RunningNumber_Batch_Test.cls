@isTest
public class Reset_RunningNumber_Batch_Test {
    @isTest
    static void test_ResetRunnungNumberBatch() {
        Branch__c br = new Branch__c();
        br.Quote_Space__c = 999;
        br.Quote_Event__c = 99;
        br.Quote_Billboard__c = 99;
        br.Contract_Space__c = 99;
        br.Contract_Service__c = 99;
        br.Contract_OP__c = 99;
        br.Contract_Event__c = 99;
        br.Contract_Billboard__c = 99;
        insert br;
        
        Test.startTest();
        Reset_RunningNumber_Batch myBatch = new Reset_RunningNumber_Batch();
        Database.executeBatch(myBatch);
        Test.stopTest();
    }
}
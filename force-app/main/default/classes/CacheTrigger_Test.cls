@isTest
public class CacheTrigger_Test {
    @isTest
    static void testCacheTriggerClass() {
        Test.startTest();
        CacheTrigger.isRunningOpportunityTrigger = true;
        CacheTrigger.isRunningContractTrigger = true;
        Test.stopTest();
    }
}
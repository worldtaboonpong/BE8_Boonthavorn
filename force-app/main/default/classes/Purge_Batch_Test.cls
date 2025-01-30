@isTest
public class Purge_Batch_Test {
    @testSetup static void setUpApplicationLog() {
        List<ApplicationLogActivation__c> setting = [SELECT Id, WS_Success_Log__c, System_Success_Log__c, Batch_Success_Log__c FROM ApplicationLogActivation__c];
        ApplicationLogActivation__c customSetting;
        if(setting.size() > 0) {
            customSetting = setting.get(0);
            customSetting.System_Success_Log__c = true;
            customSetting.WS_Success_Log__c = true;
            customSetting.Batch_Success_Log__c = true;
            update customSetting;
        } else {
            customSetting = new ApplicationLogActivation__c();
            customSetting.System_Success_Log__c = true;
            customSetting.WS_Success_Log__c = true;
            customSetting.Batch_Success_Log__c = true;
            insert customSetting;
        }
        ApplicationLogUtils.createSuccessBatchLogUtils('BatchService', 'query', '');       
    }
    
  @isTest static void testPurgeBatch() {
        Test.startTest();
        Id batchInstanceId = Database.executeBatch(new Purge_Batch(), 5); 
        Test.stopTest();
    }
}
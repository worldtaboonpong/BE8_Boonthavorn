@isTest
public with sharing class WSCalloutCreateAccountToSAP_Test {

    private static String MOCK_RESPONSE = '{"statuscode": "0000","message": "Success","timestamp": "2022-01-28T11:24:53"}';

    @testSetup
    static void setupData(){
        List<ApplicationLogActivation__c> setting = [SELECT Id, WS_Success_Log__c, System_Success_Log__c,Batch_Success_Log__c FROM ApplicationLogActivation__c];
        ApplicationLogActivation__c customSetting;
        if(setting.size() > 0){
            customSetting = setting.get(0);
            customSetting.WS_Success_Log__c = true;
            customSetting.System_Success_Log__c = true;
            customSetting.Batch_Success_Log__c = true;
            update customSetting;
        }else{
            customSetting = new ApplicationLogActivation__c();
            customSetting.WS_Success_Log__c = true;
            customSetting.System_Success_Log__c = true;
            customSetting.Batch_Success_Log__c = true;
            insert customSetting;
        }
    }

    @isTest
    public static void test_CreatAccountToSAP() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        WSCalloutCreateAccountToSAP.response result = WSCalloutCreateAccountToSAP.callout(acc);
        Test.stopTest();
    }
}
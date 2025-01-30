@isTest
public with sharing class WSCalloutGetAccountDetailFromSAP_Test {
    
    private static String MOCK_RESPONSE = '{"isSuccess":true,"message":"Success","payload":{"cid":"a5c940bf-193c-4f87-8e4e-66ba01718499"}}';

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
        acc.Customer_ID__c = 'xx';
        insert(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        WSCalloutGetAccountDetailFromSAP.response result = WSCalloutGetAccountDetailFromSAP.callout(acc);
        Test.stopTest();
    }

    @isTest
    public static void test_CreatAccountToSAP2() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Customer_ID__c = 'xx';
        insert(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(''));
        WSCalloutGetAccountDetailFromSAP.response result = WSCalloutGetAccountDetailFromSAP.callout(acc);
        Test.stopTest();
    }

    @isTest
    public static void test_CreatAccountToSAP3() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Customer_ID__c = 'xx';
        insert(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('[]'));
        WSCalloutGetAccountDetailFromSAP.response result = WSCalloutGetAccountDetailFromSAP.callout(acc);
        Test.stopTest();
    }
}
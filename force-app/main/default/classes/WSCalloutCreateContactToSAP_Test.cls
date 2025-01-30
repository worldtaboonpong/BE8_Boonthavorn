@isTest
public with sharing class WSCalloutCreateContactToSAP_Test {

    private static String MOCK_RESPONSE = '{"isSuccess":true,"message":"Success","payload":{"contact_id":"xxxxxxxx"}}';
    private static String MOCK_RESPONSE2 = '{"isSuccess":true,"message":"Success"}';

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
    public static void test_CreatContactToSAP() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Customer_ID__c = 'xxx';
        insert(acc);

        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'xx@gmail.com';
        con.AccountId = acc.Id;
        insert(con);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        WSCalloutCreateContactToSAP.response result = WSCalloutCreateContactToSAP.callout(con);
        Test.stopTest();
    }

    @isTest
    public static void test_CreatContactToSAP2() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Customer_ID__c = 'xxx';
        insert(acc);

        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'xx@gmail.com';
        con.AccountId = acc.Id;
        insert(con);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE2));
        WSCalloutCreateContactToSAP.response result = WSCalloutCreateContactToSAP.callout(con);
        Test.stopTest();
    }
}
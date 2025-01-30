@isTest
public with sharing class WSCalloutUpdateContactToSAP_Test {
    private static String MOCK_RESPONSE = '{"isSuccess":true,"message":"Success","payload":{"contact_Id":"94420604-fcf1-4c43-b423-8d3d29f083eb"}}';

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

        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'xx@gmail.com';
        con.AccountId = acc.Id;
        insert(con); 

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        WSCalloutUpdateContactToSAP.response result = WSCalloutUpdateContactToSAP.callout(con);
        Test.stopTest();
    }

    @isTest
    public static void test_CreatAccountToSAPEmpty() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert(acc);

        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'xx@gmail.com';
        con.AccountId = acc.Id;
        insert(con); 

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(''));
        WSCalloutUpdateContactToSAP.response result = WSCalloutUpdateContactToSAP.callout(con);
        Test.stopTest();
    }

    @isTest
    public static void test_CreatAccountToSAPInvalid() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert(acc);

        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'xx@gmail.com';
        con.AccountId = acc.Id;
        insert(con); 

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('[]'));
        WSCalloutUpdateContactToSAP.response result = WSCalloutUpdateContactToSAP.callout(con);
        Test.stopTest();
    }
}
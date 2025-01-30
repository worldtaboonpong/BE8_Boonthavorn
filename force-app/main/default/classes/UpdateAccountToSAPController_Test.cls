@isTest
public with sharing class UpdateAccountToSAPController_Test {
    private static String MOCK_RESPONSE = '{"isSuccess":true,"message":"Success"}';
    private static String MOCK_RESPONSE2 = '{"isSuccess":false,"message":"Success"}';


    @isTest
    public static void test_getcid() {
        Account acc = new Account(Name = 'Test', Customer_ID__c = 'xxx');
        insert(acc);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        WSCalloutGetAccountDetailFromSAP.response res = UpdateAccountToSAPController.getcid(acc.Id);
        Test.stopTest();
    }

    @isTest
    public static void test_getcidError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        WSCalloutGetAccountDetailFromSAP.response res = UpdateAccountToSAPController.getcid('xx');
        Test.stopTest();
    }

    @isTest
    public static void test_updateAccount() {
        Account acc = new Account(Name = 'Test', Customer_ID__c = 'xxx');
        insert(acc);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        UpdateAccountToSAPController.SyncResponse res = new UpdateAccountToSAPController.SyncResponse();
        res = UpdateAccountToSAPController.calloutAndUpdateAccount(acc, acc.Id, 'xx');
        Test.stopTest();
    }

    @isTest
    public static void test_updateAccountFail() {
        Account acc = new Account(Name = 'Test', Customer_ID__c = 'xxx');
        insert(acc);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE2));
        UpdateAccountToSAPController.SyncResponse res = UpdateAccountToSAPController.calloutAndUpdateAccount(acc, acc.Id, 'xx');
        Test.stopTest();
    }

    @isTest
    public static void test_updateAccountError() {
        Account acc = new Account(Name = 'Test', Customer_ID__c = 'xxx');
        insert(acc);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        UpdateAccountToSAPController.SyncResponse res = UpdateAccountToSAPController.calloutAndUpdateAccount(acc, 'xx', 'xx');
        Test.stopTest();
    }
}
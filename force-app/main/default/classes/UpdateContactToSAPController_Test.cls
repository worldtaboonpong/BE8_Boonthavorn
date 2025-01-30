@isTest
public with sharing class UpdateContactToSAPController_Test {
    private static String MOCK_RESPONSE = '{"isSuccess":true,"message":"Success"}';
    private static String MOCK_RESPONSE2 = '{"isSuccess":false,"message":"Success"}';

    @isTest
    public static void test_updateContact() {
        Account acc = new Account(Name = 'Test', Customer_ID__c = 'xxx');
        insert(acc);

        Contact con = new Contact(LastName = 'Test', Email = 'xx@test.com', AccountId = acc.Id);
        insert(con);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        UpdateContactToSAPController.SyncResponse res = new UpdateContactToSAPController.SyncResponse();
        res = UpdateContactToSAPController.calloutAndUpdateContact(con, con.Id);
        Test.stopTest();
    }

    @isTest
    public static void test_updateContactFail() {
        Account acc = new Account(Name = 'Test', Customer_ID__c = 'xxx');
        insert(acc);

        Contact con = new Contact(LastName = 'Test', Email = 'xx@test.com', AccountId = acc.Id);
        insert(con);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE2));
        UpdateContactToSAPController.SyncResponse res = new UpdateContactToSAPController.SyncResponse();
        res = UpdateContactToSAPController.calloutAndUpdateContact(con, con.Id);
        Test.stopTest();
    }
}
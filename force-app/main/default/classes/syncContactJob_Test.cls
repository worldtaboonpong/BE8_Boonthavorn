@isTest
public with sharing class syncContactJob_Test {
    private static String MOCK_RESPONSE = '{"isSuccess":true,"message":"Success","payload":{"contact_id":"xxxxxxxx"}}';

    @isTest
    public static void test_syncContact() {
        Account acc = new Account(Name = 'Test', Customer_ID__c = 'xxx');
        insert(acc);
        Contact con = new Contact(LastName = 'Test', Email = 'xx@test.com', AccountId = acc.Id);
        insert(con);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        syncContactJob job = new syncContactJob(new List<Contact>{con});
        ID jobID = System.enqueueJob(job);
        Test.stopTest();
    }
}
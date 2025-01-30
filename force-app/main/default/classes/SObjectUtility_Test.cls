@isTest
public with sharing class SObjectUtility_Test {

    @isTest
    public static void test_getSObjectTypeByID() {
        Test.startTest();
        String objectName = SObjectUtility.getSObjectTypeByID(IDGenerator.generate(Schema.getGlobalDescribe().get('Account')));
        Test.stopTest();
    }
}
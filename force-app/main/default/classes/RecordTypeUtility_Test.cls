@isTest
public with sharing class RecordTypeUtility_Test {
    @isTest
    public static void test_getRecordTypeId() {
        Test.startTest();
        Id res = RecordTypeUtility.getRecordTypeId('Account', 'Corporate');
        String res2 = RecordTypeUtility.getRecordTypeDeveloperName('Account', res);
        Test.stopTest();
    }

    @isTest
    public static void test_getRecordTypeByDeveloperName() {
        Test.startTest();
        List<RecordType> res = RecordTypeUtility.getRecordTypeByDeveloperName('Account', new List<String>{'Corporate'});
        Test.stopTest();
    }

    @isTest
    public static void test_getRecordTypeByObject() {
        Test.startTest();
        List<RecordType> res = RecordTypeUtility.getRecordTypeByObject('Account');
        Test.stopTest();
    }
}
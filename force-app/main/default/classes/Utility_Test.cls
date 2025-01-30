@isTest
public with sharing class Utility_Test {
    
    @isTest
    public static void test_getAllSObjectAPINameList() {
        Test.startTest();
        List<String> res = Utility.getAllSObjectAPINameList();
        Test.stopTest();
    }

    @isTest
    public static void test_getAllFieldFromsObject() {
        Test.startTest();
        List<String> res = Utility.getAllFieldFromsObject('Account');
        Test.stopTest();
    }

    @isTest
    public static void test_getDefaultValuePicklist() {
        Test.startTest();
        String res = Utility.getDefaultValuePicklist('Account', 'Name');
        Test.stopTest();
    }

    @isTest
    public static void test_getPicklistValues() {
        Test.startTest();
        List<SelectOption> res = Utility.getPicklistValues('Account', 'Type');
        Test.stopTest();
    }

    @isTest
    public static void test_getDependentPicklistValues() {
        Test.startTest();
        Map<String, List<String>> res = Utility.getDependentPicklistValues(Opportunity.Calculation_Method__c);
        Test.stopTest();
    }

    @isTest
    public static void test_getLookupValue() {
        Test.startTest();
        String res = Utility.getLookupValue(new Opportunity(), 'AccountId');
        Test.stopTest();
    }

    @isTest
    public static void test_getOrgInst() {
        Test.startTest();
        String res = Utility.getOrgInst();
        Test.stopTest();
    }

    @isTest
    public static void test_getBrandTemplate() {
        BrandTemplate eachBrandTemplateList = [SELECT id, name, value FROM BrandTemplate LIMIT 1];
        Test.startTest();
        BrandTemplate res = Utility.getBrandTemplate(eachBrandTemplateList.Id);
        Test.stopTest();
    }

    @isTest
    public static void test_getOrganization() {
        Test.startTest();
        String res = Utility.getOrganization();
        Test.stopTest();
    }

    @isTest
    public static void test_isRichText() {
        Test.startTest();
        Boolean res = Utility.isRichText(new Account(), 'Name');
        Test.stopTest();
    }

    @isTest
    public static void test_setDecToFormatCommaTwoDigits() {
        Test.startTest();
        String res = Utility.setDecToFormatCommaTwoDigits(1);
        Test.stopTest();
    }

    @isTest
    public static void test_isPeriodOverlap() {
        Test.startTest();
        Boolean res = Utility.isPeriodOverlap(System.today(), System.today(), System.today(), System.today());
        Test.stopTest();
    }

    @isTest
    public static void test_changeDateToStringShortMonthFormat() {
        Test.startTest();
        String res = Utility.changeDateToStringShortMonthFormat(System.today());
        Test.stopTest();
    }

    @isTest
    public static void test_changeDateToStringShortMonthNoDayFormat() {
        Test.startTest();
        String res = Utility.changeDateToStringShortMonthNoDayFormat(System.today());
        Test.stopTest();
    }

    @isTest
    public static void test_getMonthBetween() {
        Test.startTest();
        Decimal res = Utility.getMonthBetween(System.today(), System.today());
        Test.stopTest();
    }

    @isTest
    public static void test_isLastDateOfMonth() {
        Test.startTest();
        Boolean res = Utility.isLastDateOfMonth(System.today());
        Test.stopTest();
    }

    @isTest
    public static void test_isFirstDate() {
        Test.startTest();
        Boolean res = Utility.isFirstDate(System.today());
        Test.stopTest();
    }

    @isTest
    public static void test_isDecimal() {
        Test.startTest();
        Boolean res = Utility.isDecimal('');
        Test.stopTest();
    }

}
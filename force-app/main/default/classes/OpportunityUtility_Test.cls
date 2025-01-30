@isTest
public with sharing class OpportunityUtility_Test {

    @isTest
    public static void test_getYearCalendarPeriod() {
        Test.startTest();
        OpportunityUtility.getYearCalendarPeriod(System.today(), System.today().addYears(3).addMonths(2), 'Long-Term', 'ระบุราคาทุกปีตามปีสัญญา');
        Test.stopTest();
    }

    @isTest
    public static void test_getYearCalendarPeriod2() {
        Test.startTest();
        OpportunityUtility.getYearCalendarPeriod(System.today(), System.today().addYears(3).addMonths(2), 'Long-Term', 2, 1, 'ระบุราคาทุกปีตามปีสัญญา');
        Test.stopTest();
    }

    @isTest
    public static void test_getPricingDatePeriod() {
        Test.startTest();
        OpportunityUtility.getPricingDatePeriod(System.today(), System.today().addYears(3).addMonths(2));
        Test.stopTest();
    }

    @isTest
    public static void test_getPricingDatePeriod2() {
        Test.startTest();
        OpportunityUtility.getPricingDatePeriod(System.today(), System.today().addYears(3).addMonths(2), 2, 1);
        Test.stopTest();
    }

    @isTest
    public static void test_getYearCalendarPeriod3() {
        Test.startTest();
        OpportunityUtility.getYearCalendarPeriod(System.today(), System.today().addMonths(1), 'Long-Term', 'ระบุราคาปีปฏิทินแรก');
        Test.stopTest();
    }

    @isTest
    public static void test_getYearCalendarPeriod4() {
        Test.startTest();
        OpportunityUtility.getYearCalendarPeriod(System.today(), System.today().addMonths(1), 'Long-Term', 1, 1, 'ระบุราคาปีปฏิทินแรก');
        Test.stopTest();
    }

    @isTest
    public static void test_getPricingDatePeriod3() {
        Test.startTest();
        OpportunityUtility.getPricingDatePeriod(System.today(), System.today().addMonths(1));
        Test.stopTest();
    }

    @isTest
    public static void test_getPricingDatePeriod4() {
        Test.startTest();
        OpportunityUtility.getPricingDatePeriod(System.today(), System.today().addMonths(1), 1, 1);
        Test.stopTest();
    }
}
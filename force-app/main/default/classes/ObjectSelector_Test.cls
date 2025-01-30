@isTest
public with sharing class ObjectSelector_Test {
    @isTest
    public static void test_getRentalObjectByCondition() {
        Test.startTest();
        List<Units__c> res = ObjectSelector.getRentalObjectByCondition('Name != null', 'Name');
        Test.stopTest();
    }

    @isTest
    public static void test_getUnitByIdSet() {
        Test.startTest();
        List<Units__c> res = ObjectSelector.getUnitByIdSet(new Set<Id>());
        Test.stopTest();
    }

    @isTest
    public static void test_getContractByPeriod() {
        Test.startTest();
        List<Contract__c> res = ObjectSelector.getContractByPeriod(System.Today(), System.Today());
        Test.stopTest();
    }

    @isTest
    public static void test_getContractById() {
        Test.startTest();
        Contract__c res = ObjectSelector.getContractById('');
        Test.stopTest();
    }

    @isTest
    public static void test_getContractBySetId() {
        Test.startTest();
        List<Contract__c> res = ObjectSelector.getContractBySetId(new Set<Id>());
        Test.stopTest();
    }

    @isTest
    public static void test_getOppLineItemFromOppId() {
        Test.startTest();
        List<OpportunityLineItem__c> res = ObjectSelector.getOppLineItemFromOppId(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')));
        Test.stopTest();
    }

    @isTest
    public static void test_getOppLineItemFromOpp() {
        Test.startTest();
        List<OpportunityLineItem__c> res = ObjectSelector.getOppLineItemFromOpp(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')));
        Test.stopTest();
    }

    @isTest
    public static void test_getROMeasurementFromRO() {
        Test.startTest();
        List<Measurement__c> res = ObjectSelector.getROMeasurementFromRO(new Set<Id>{IDGenerator.generate(Schema.getGlobalDescribe().get('Units__c'))}, System.Today(), System.Today());
        Test.stopTest();
    }

    @isTest
    public static void test_getOppPeriodCAMOrAirServiceFromOpp() {
        Test.startTest();
        List<OpportunityPeriod__c> res = ObjectSelector.getOppPeriodCAMOrAirServiceFromOpp(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')));
        Test.stopTest();
    }

    @isTest
    public static void test_getOppPriceFromOpp() {
        Test.startTest();
        Map<Id,List<OpportunityPrice__c>> res = ObjectSelector.getOppPriceFromOpp(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')), new List<OpportunityPeriod__c>());
        Test.stopTest();
    }

    @isTest
    public static void test_getOppPeriodForRentAndServiceFromOpp() {
        Test.startTest();
        List<OpportunityPeriod__c> res = ObjectSelector.getOppPeriodForRentAndServiceFromOpp(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')));
        Test.stopTest();
    }

    @isTest
    public static void test_getOppPeriodFromOppId() {
        Test.startTest();
        List<OpportunityPeriod__c> res = ObjectSelector.getOppPeriodFromOppId(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')));
        Test.stopTest();
    }

    @isTest
    public static void test_getOppPeriodFromOpp() {
        Test.startTest();
        List<OpportunityPeriod__c> res = ObjectSelector.getOppPeriodFromOpp(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')), new List<String>());
        Test.stopTest();
    }

    @isTest
    public static void test_getOppGradingFromOpp() {
        Test.startTest();
        Map<Id,Map<String,List<OpportunityGradingModel.Data>>> res = ObjectSelector.getOppGradingFromOpp(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')), new List<OpportunityPeriod__c>());
        Test.stopTest();
    }

    @isTest
    public static void test_getOppDepositAndExpense() {
        Test.startTest();
        List<OpportunityDepositExpense__c> res = ObjectSelector.getOppDepositAndExpense(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')), '');
        Test.stopTest();
    }

    @isTest
    public static void test_getOppPriceFromOppExpense() {
        Test.startTest();
        Map<Id,List<OpportunityPrice__c>> res = ObjectSelector.getOppPriceFromOppExpense(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')), new List<OpportunityDepositExpense__c>(), '');
        Test.stopTest();
    }

    @isTest
    public static void test_getContractDepositAndExpense() {
        Test.startTest();
        List<ContractDepositExpense__c>  res = ObjectSelector.getContractDepositAndExpense(IDGenerator.generate(Schema.getGlobalDescribe().get('Contract__c')), '');
        Test.stopTest();
    }
}
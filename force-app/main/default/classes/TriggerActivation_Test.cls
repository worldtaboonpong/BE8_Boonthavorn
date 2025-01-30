@isTest
public with sharing class TriggerActivation_Test {
    @isTest
    static void testTriggerActivation(){
        Test.startTest();
        TriggerActivation setting = TriggerActivation.getInstance('Opportunity');
        setting.isActiveTrigger();
        Test.stopTest();
    }
}
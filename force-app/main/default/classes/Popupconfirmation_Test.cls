@isTest
public with sharing class Popupconfirmation_Test {
    @isTest
    public static void test_constructure() {

        Test.startTest();
        Popupconfirmation res = new Popupconfirmation('Test','Test',true,'Test');
        Test.stopTest();
    }
}
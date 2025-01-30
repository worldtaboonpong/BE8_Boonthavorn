@isTest
public with sharing class numberToWord_Test {
    @isTest
    static void test_numberToWordTH(){
        Test.startTest();
        String word = numberToWord.numberToWordTH(1212121.25, true);
        Test.stopTest();
        System.debug(word);
    }

    @isTest
    static void test_numberToWordTHZero(){
        Test.startTest();
        String word = numberToWord.numberToWordTH(0, false);
        Test.stopTest();
        System.debug(word);
    }

    @isTest
    static void test_numberToWordTH2(){
        Test.startTest();
        String word = numberToWord.numberToWordTH(100, false);
        Test.stopTest();
        System.debug(word);
    }
    
    @isTest
    static void test_numberToWordTH3(){
        Test.startTest();
        String word = numberToWord.numberToWordTH(1212121.25, false);
        Test.stopTest();
        System.debug(word);
    }

    @isTest
    static void test_numberToWordEN(){
        Test.startTest();
        String word = numberToWord.numberToWordEN(121212121.25);
        Test.stopTest();
        System.debug(word);
    }

    @isTest
    static void test_numberToWordEN2(){
        Test.startTest();
        String word = numberToWord.numberToWordEN(0);
        Test.stopTest();
        System.debug(word);
    }
}
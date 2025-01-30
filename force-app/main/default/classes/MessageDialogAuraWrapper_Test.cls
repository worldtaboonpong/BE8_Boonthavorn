@isTest
public  class MessageDialogAuraWrapper_Test {
    
    @isTest
    public static void test_constructor1() {
        Test.startTest();
        MessageDialogAuraWrapper res = new MessageDialogAuraWrapper('', false, false);
        Test.stopTest();
    }

    @isTest
    public static void test_constructor2() {
        Test.startTest();
        MessageDialogAuraWrapper res = new MessageDialogAuraWrapper('', false, false, IDGenerator.generate(Schema.getGlobalDescribe().get('Account')));
        Test.stopTest();
    }

    @isTest
    public static void test_constructor3() {
        Test.startTest();
        MessageDialogAuraWrapper res = new MessageDialogAuraWrapper('', false, false, new Account());
        Test.stopTest();
    }
}
@isTest
public class DescribeSObjectUtility_Test {
    
    @isTest
    public static void test_getStaticDescribe() {
        String sObjectType = 'Account';
        Test.startTest();
        Schema.DescribeSObjectResult res = DescribeSObjectUtility.getStaticDescribe(sObjectType);
        Test.stopTest();
    }
}
@isTest
public class HttpFormBuilder_Test {
    
    @isTest
    public static void test_GetContentType() {
        Test.startTest();
        String res = HttpFormBuilder.GetContentType();
        Test.stopTest();
    }

    @isTest
    public static void test_WriteBoundary() {
        Test.startTest();
        String res = HttpFormBuilder.WriteBoundary();
        Test.stopTest();
    }

    @isTest
    public static void test_WriteBoundary2() {
        Test.startTest();
        String res = HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.None);
        Test.stopTest();
    }

    @isTest
    public static void test_WriteBodyParameter() {
        Test.startTest();
        String res = HttpFormBuilder.WriteBodyParameter('','');
        Test.stopTest();
    }
}
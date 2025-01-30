@isTest
public with sharing class PDFContentEditorController_Test {
    @TestSetup
    static void setupData(){
        PDF_Content__c content = new PDF_Content__c(
            Content__c = '<p>ผู้ให้เช่ามีความยินดีจะเสนอพื้นที่เช่า โดยมีรายละเอียดและเงื่อนไขดังนี้:</p>');
        insert content;
    }

    private static testmethod void testSaveDataCKEditorNew()
     {
        List<PDF_Content__c> pdfContent = [SELECT Id FROM PDF_Content__c];

        PageReference pageRef = Page.DocumentEditorPage;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(pdfContent.get(0).Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(pdfContent.get(0));
        PDFContentEditorController contentCtrl = new PDFContentEditorController(sc);

        
        String htmlData = '<p>ผู้ให้เช่ามีความยินดีจะเสนอพื้นที่เช่าในศูนย์การค้า</p>';
        String recID = pdfContent.get(0).Id;
        PDFContentEditorController.saveDataCKEditorNew(htmlData, recID);
        PDF_Content__c result = [SELECT Content__c FROM PDF_Content__c];
        System.assertEquals(result.Content__c, '<p>ผู้ให้เช่ามีความยินดีจะเสนอพื้นที่เช่าในศูนย์การค้า</p>');

    }
}
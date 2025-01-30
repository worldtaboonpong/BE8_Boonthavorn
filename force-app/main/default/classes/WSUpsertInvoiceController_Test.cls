@isTest
public with sharing class WSUpsertInvoiceController_Test {

    @isTest
    public static void test_InsertInvoice() {

        String ls_requestService = '[{"invoiceId":"VPCNC2200007","invoiceDate":"10-03-2022","customerId":"DZ000002","taxId":"","accountName":"คลังสยามพรารากอน รีเทล จำกัด (สำนักงานฬหญ่)","address":"","phone":"","fax":"","contact":"","invoiceAmount":190177.44,"vat":0,"totalValue":190177.44}]';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/upsertinvoice';
        req.requestBody = blob.valueOf(ls_requestService);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';

        Test.startTest();
            RestContext.request = req;
            WSInvoiceModel.InvoiceInfoResponse responseService = WSUpsertInvoiceService.upsertInvoice();
        Test.stopTest();
    }

    @isTest
    public static void test_InsertInvoiceMissingField() {

        String ls_requestService = '[{"invoiceDate":"10-03-2022","customerId":"DZ000002","taxId":"","accountName":"คลังสยามพรารากอน รีเทล จำกัด (สำนักงานฬหญ่)","address":"","phone":"","fax":"","contact":"","invoiceAmount":190177.44,"vat":0,"totalValue":190177.44}]';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/upsertinvoice';
        req.requestBody = blob.valueOf(ls_requestService);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';

        Test.startTest();
            RestContext.request = req;
            WSInvoiceModel.InvoiceInfoResponse responseService = WSUpsertInvoiceService.upsertInvoice();
        Test.stopTest();
    }

    @isTest
    public static void test_UpdateInvoice() {
        Invoice__c inv = new Invoice__c(Name='VPCNC2200007');
        insert(inv);

        String ls_requestService = '[{"invoiceId":"VPCNC2200007","invoiceDate":"10-03-2022","customerId":"DZ000002","taxId":"","accountName":"คลังสยามพรารากอน รีเทล จำกัด (สำนักงานฬหญ่)","address":"","phone":"","fax":"","contact":"","invoiceAmount":190177.44,"vat":0,"totalValue":190177.44}]';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/upsertinvoice';
        req.requestBody = blob.valueOf(ls_requestService);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';

        Test.startTest();
            RestContext.request = req;
            WSInvoiceModel.InvoiceInfoResponse responseService = WSUpsertInvoiceService.upsertInvoice();
        Test.stopTest();
    }

    @isTest
    public static void test_InsertInvoiceError() {
        String ls_requestService = '{}';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/upsertinvoice';
        req.requestBody = blob.valueOf(ls_requestService);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';

        Test.startTest();
            RestContext.request = req;
            WSInvoiceModel.InvoiceInfoResponse responseService = WSUpsertInvoiceService.upsertInvoice();
        Test.stopTest();
    }
}
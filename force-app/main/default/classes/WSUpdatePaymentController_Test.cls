@isTest
public with sharing class WSUpdatePaymentController_Test {
    @isTest
    public static void test_updatepayment() {
        Invoice__c inv = new Invoice__c(Name='VPCNC2200007');
        insert(inv);

        String ls_requestService = '[{"invoiceId":"VPCNC2200007","paidDate":"10-03-2022","totalPaidAmount":190177.44}]';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updatepayment';
        req.requestBody = blob.valueOf(ls_requestService);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';

        Test.startTest();
            RestContext.request = req;
            WSPaymentModel.PaymentInfoResponse responseService = WSUpdatePaymentService.updatePayment();
        Test.stopTest();
    }

    @isTest
    public static void test_updatepaymentNotFound() {
        String ls_requestService = '[{"invoiceId":"VPCNC2200007","paidDate":"10-03-2022","totalPaidAmount":190177.44}]';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updatepayment';
        req.requestBody = blob.valueOf(ls_requestService);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';

        Test.startTest();
            RestContext.request = req;
            WSPaymentModel.PaymentInfoResponse responseService = WSUpdatePaymentService.updatePayment();
        Test.stopTest();
    }

    @isTest
    public static void test_updatepaymentError() {
        String ls_requestService = '{}';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/updatepayment';
        req.requestBody = blob.valueOf(ls_requestService);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';

        Test.startTest();
            RestContext.request = req;
            WSPaymentModel.PaymentInfoResponse responseService = WSUpdatePaymentService.updatePayment();
        Test.stopTest();
    }
}
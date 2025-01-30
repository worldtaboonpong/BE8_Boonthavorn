@isTest
public with sharing class ResendWSActionController_Test {
    static String ls_LogIdWSCallOutCreateAccount = '';
    static String ls_LogIdWSCallOutUpdateAccount = '';
    static String ls_LogIdWSCalloutCreateContact = '';
    static String ls_LogIdWSCallOutUpdateContact = '';
    private static String MOCK_RESPONSE = '{"isSuccess":true,"message":"Success"}';

    @isTest
    static void ResendWSActionControllerTest1(){
        createLogWSCallOutCreateAccount();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        ResendWSActionController.resend(ls_LogIdWSCallOutCreateAccount);
        Test.stopTest();
    }

    @isTest
    static void ResendWSActionControllerTest2(){
        createLogWSCallOutUpdateAccount();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        ResendWSActionController.resend(ls_LogIdWSCallOutUpdateAccount);
        Test.stopTest();
    }

    @isTest
    static void ResendWSActionControllerTest3(){
        createLogWSCallOutCreateContact();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        ResendWSActionController.resend(ls_LogIdWSCalloutCreateContact);
        Test.stopTest();
    }

    @isTest
    static void ResendWSActionControllerTest4(){
        createLogWSCalloutUpdateContact();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(MOCK_RESPONSE));
        ResendWSActionController.resend(ls_LogIdWSCallOutUpdateContact);
        Test.stopTest();
    }

    private static void createLogWSCallOutCreateAccount() {
        List<Application_Log__c> logInsert = new List<Application_Log__c>();
        Application_Log__c logData = new Application_Log__c();
        logData.Webservice_Response__c = '';
        logData.Webservice_Body__c = '[{"flag":"SO","customer_code":"","tax_branch":"","tax_no":"","currency":"THB","title":" ","name":"Tood-4-neaw-1","address":"71","road":"","subdistrict":"สายไหม","district":"สายไหม","city":"กรุงเทพมหานคร","postcode":"10220","country":"TH","telephone":"","telephone_ext":"","mobile":"0265711912","fax":"","fax_ext":"","email":"apps@boonthavorn.com","passport":"","lat":13.9214974,"lng":100.676197,"map_zoom":18,"searchterm":"","customergroup":"16","remark":"หน้าบ้านลูกค้ามีต้นมะม่วง 8 ต้น","vat":7,"tr_zone":"B152"}]';
        logData.Webservice_Name__c = 'WSCalloutCreateAccountToSAP';
        logData.Log_Type__c = 'Webservice';
        logData.Webservice_Type__c = 'Outbound';
        logInsert.add(logData);
        insert logInsert;
        ls_LogIdWSCallOutCreateAccount = logInsert[0].Id;
    }

    private static void createLogWSCallOutUpdateAccount() {
        List<Application_Log__c> logInsert = new List<Application_Log__c>();
        Application_Log__c logData = new Application_Log__c();
        logData.Webservice_Response__c = '';
        logData.Webservice_Body__c = '{"cid":"94420604-fcf1-4c43-b423-8d3d29f083eb","cust_code":"0011397718","cust_name":[{"prefix":"หจก.","name":"moohoo 8000_it test","searchterm":"moohoo 8000_it test","address":"61","street":"","subdistrict":"บางปลาม้า","district":"บางปลาม้า","province":"สุพรรณบุรี","zipcode":"72150","transport_zone":"C10201","country_code":"TH","mobs":["0265711912"],"tels":[""],"fax":null}],"passport_number":"","email":null,"lattitude":"14.4061782563964","longtitude":"100.107459734393","map_type":"","map_zoom":"","tax_number":"1234444444444","tax_branch":"00000","customer_type":"C001","customer_group":"11","sales_district":"","ref_customer_code":null,"remark":"","ref_code":"SF00000001","ref_source":"SALEFORCE"}';
        logData.Webservice_Name__c = 'WSCalloutUpdateAccountToSAP';
        logData.Log_Type__c = 'Webservice';
        logData.Webservice_Type__c = 'Outbound';
        logInsert.add(logData);
        insert logInsert;
        ls_LogIdWSCallOutUpdateAccount = logInsert[0].Id;
    }

    private static void createLogWSCallOutCreateContact() {
        List<Application_Log__c> logInsert = new List<Application_Log__c>();
        Application_Log__c logData = new Application_Log__c();
        logData.Webservice_Response__c = '';
        logData.Webservice_Body__c = '{"customer_code":"0011399063","title":" ","firstname":"tah contact 1","lastname":"tah01","other_title":"0001","department":"IT Business Application","function":"IT","email":"apps@boonthavorn.com","langu":"TH","mobile":"0265711912"}';
        logData.Webservice_Name__c = 'WSCalloutCreateContactToSAP';
        logData.Log_Type__c = 'Webservice';
        logData.Webservice_Type__c = 'Outbound';
        logInsert.add(logData);
        insert logInsert;
        ls_LogIdWSCalloutCreateContact = logInsert[0].Id;
    }

    private static void createLogWSCalloutUpdateContact() {
        List<Application_Log__c> logInsert = new List<Application_Log__c>();
        Application_Log__c logData = new Application_Log__c();
        logData.Webservice_Response__c = '';
        logData.Webservice_Body__c = '{"contact_id":"xxxxx","customer_code":"0011399063","title":" ","firstname":"tah contact 1","lastname":"tah01","other_title":"0001","department":"IT Business Application","function":"IT","email":"apps@boonthavorn.com","langu":"TH","mobile":"0265711912"}';
        logData.Webservice_Name__c = 'WSCalloutUpdateContactToSAP';
        logData.Log_Type__c = 'Webservice';
        logData.Webservice_Type__c = 'Outbound';
        logInsert.add(logData);
        insert logInsert;
        ls_LogIdWSCallOutUpdateContact = logInsert[0].Id;
    }

    
}
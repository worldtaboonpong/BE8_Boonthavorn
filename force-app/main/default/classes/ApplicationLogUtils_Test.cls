@isTest
public with sharing class ApplicationLogUtils_Test {
    @testSetup
    static void setCustom(){
        List<ApplicationLogActivation__c> setting = [SELECT Id, WS_Success_Log__c, System_Success_Log__c, Batch_Success_Log__c FROM ApplicationLogActivation__c];
        ApplicationLogActivation__c customSetting;
        if(setting.size() > 0) {
            customSetting = setting.get(0);
            customSetting.System_Success_Log__c = true;
            customSetting.WS_Success_Log__c = true;
            customSetting.Batch_Success_Log__c = true;
            update customSetting;
        } else {
            customSetting = new ApplicationLogActivation__c();
            customSetting.System_Success_Log__c = true;
            customSetting.WS_Success_Log__c = true;
            customSetting.Batch_Success_Log__c = true;
            insert customSetting;
        }
    }

    @isTest
    public static void insertOtherWebService(){
        setCustom();
        String WebServiceType = 'Inbound';
        String WebServiceName = 'AnyService';
        String Request = 'TestRequest';
        String Response = 'TestResponse';

        ApplicationLogUtils.createSuccessIntegrationLogUtils(WebServiceName, WebServiceType, Request, Response);
        String ls_WebServiceType = '';
        String ls_WebServiceName = '';
        String ls_Request = '';
        String ls_Response = '';
        List<Application_Log__c> integrationInsert = [SELECT Log_Type__c, Webservice_Type__c, Webservice_Name__c, Webservice_Body__c, Webservice_Response__c FROM Application_Log__c WHERE Webservice_Type__c =: WebServiceType and Webservice_Name__c =: WebServiceName];
        if(!integrationInsert.isEmpty() && integrationInsert.size() > 0){
            for (Application_Log__c intlog : integrationInsert) {
                ls_WebServiceType = String.valueOf(intlog.Webservice_Type__c);
                ls_WebServiceName = String.valueOf(intlog.Webservice_Name__c);
                ls_Request = String.valueOf(intlog.Webservice_Body__c);
                ls_Response = String.valueOf(intlog.Webservice_Response__c);
            }
        }

        System.debug(ls_WebServiceType);
        System.debug(ls_WebServiceName);
        System.debug(ls_Request);
        System.debug(ls_Response);
    }

    @isTest
    public static void insertOtherBatch(){
        setCustom();
        String BatchNameData = 'AnyService';
        String QuaryString = 'Select';
        String BatchRuntime = '10.11';

        ApplicationLogUtils.createSuccessBatchLogUtils(BatchNameData, QuaryString, BatchRuntime);
        String ls_ServiceType = '';
        String ls_BatchNameData = '';
        String ls_QuaryString = '';
        String ls_BatchRuntime = '';
        List<Application_Log__c> integrationInsert = [SELECT Log_Type__c, Batch_Name__c, Log_Query__c , Batch_RunTime__c FROM Application_Log__c WHERE Batch_Name__c =: BatchNameData];
        if(!integrationInsert.isEmpty() && integrationInsert.size() > 0){
            for (Application_Log__c intlog : integrationInsert) {
                ls_ServiceType = String.valueOf(intlog.Log_Type__c);
                ls_BatchNameData = String.valueOf(intlog.Batch_Name__c);
                ls_QuaryString = String.valueOf(intlog.Log_Query__c );
                ls_BatchRuntime = String.valueOf(intlog.Batch_RunTime__c);
            }
        }

        System.debug(ls_ServiceType);
        System.debug(ls_BatchNameData);
        System.debug(ls_QuaryString);
        System.debug(ls_BatchRuntime);

    }

    @isTest
    public static void insertOtherSystem(){
        setCustom();
        String LogActionString = 'Insert';
        String LogInfoString = 'Account';
        String RecordIDString = 'A1111';
        String ApexMessageString = 'TestString';

        ApplicationLogUtils.createSuccessSystemLogUtils(ApexMessageString, LogActionString, LogInfoString, RecordIDString);
        String ls_LogActionString = '';
        String ls_LogInfoString = '';
        String ls_RecordIDString = '';
        List<Application_Log__c> integrationInsert = [SELECT Log_Type__c, Log_Info__c, Log_Action__c FROM Application_Log__c WHERE Log_Action__c =: LogActionString and Log_Info__c =: LogInfoString];
        if(!integrationInsert.isEmpty() && integrationInsert.size() > 0){
            for (Application_Log__c intlog : integrationInsert) {
                ls_LogInfoString = String.valueOf(intlog.Log_Info__c);
                ls_LogActionString = String.valueOf(intlog.Log_Action__c);
            }
        }

    }

    @isTest
    public static void test_WebBodyExceededFieldLen(){
        setCustom();
        //web service body
		Integer webServiceBodyFieldLength = Schema.SObjectType.Application_Log__c.fields.Webservice_Body__c.getLength();
		System.debug('webServiceBodyFieldLength : ' + webServiceBodyFieldLength);

		//web service response
		Integer webServiceResponseFieldLength = Schema.SObjectType.Application_Log__c.fields.Webservice_Response__c.getLength();
		System.debug('webServiceResponseFieldLength : ' + webServiceResponseFieldLength);

        String exceededWebBody = 'i';
        for (Integer i = 0; i< webServiceBodyFieldLength; i++) {
            exceededWebBody += 'i' ;            
        }
        System.debug(exceededWebBody.length());

        String exceededWebResponse = 'i';
        for (Integer i = 0; i< webServiceResponseFieldLength; i++) {
            exceededWebResponse += 'i' ;            
        }
        System.debug(exceededWebResponse.length());

        String WebServiceName = 'ExceededBodyService';
        String ServiceType = 'TestClass';
        String WebServiceType = 'Inbound';
        String Request =  exceededWebBody;
        String Response = exceededWebResponse;

        Test.startTest();
        ApplicationLogUtils.createFailIntegrationLogUtils(WebServiceName, WebServiceType, Request, Response, '');
        Test.stopTest();

        List<Application_Log__c> logList = [SELECT Id, Log_Type__c, Webservice_Type__c, Webservice_Name__c, Webservice_Body__c, Webservice_Response__c FROM Application_Log__c WHERE Webservice_Name__c = 'ExceededBodyService' LIMIT 1];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId =: logList[0].Id];
        System.assertEquals(1, logList.size());
        System.assertEquals(2, attachmentList.size());       
    }
}
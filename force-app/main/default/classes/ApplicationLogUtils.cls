public class ApplicationLogUtils {
    public static void createSuccessIntegrationLogUtils(String WebServiceName, String WebServiceType, String Request, String Response) {
    String ExceptionMessage = '';
    Boolean lb_stampLogStatus = false;
    lb_stampLogStatus = CheckWSStampLogSuccess();
    System.debug('lb_stampLogStatus1 ' + lb_stampLogStatus);
    //setting.WS_Success_Log__c = false --> not create log
    if (lb_stampLogStatus == false) {  
      System.debug('Application Log : Not create log.');
    } else {
      createIntegrationLogUtils(WebServiceName, WebServiceType, Constant.APP_LOG_WEBSERVICE_TYPE, Request, Response, Constant.STATUS_SUCCESS, ExceptionMessage);
    }
  }
    
    public static void createFailIntegrationLogUtils(String WebServiceName, String WebServiceType, String Request, String Response, String ExceptionMessage) {
    createIntegrationLogUtils(WebServiceName, WebServiceType, Constant.APP_LOG_WEBSERVICE_TYPE, Request, Response, Constant.STATUS_FAIL, ExceptionMessage);
    }

    public static void createSuccessBatchLogUtils(String BatchName, String QuaryString, String BatchRuntime) {
        String ExceptionMessage = '';
    Boolean lb_stampLogStatus = false;
    lb_stampLogStatus = CheckBatchStampLogSuccess();
    System.debug('lb_stampLogStatus2 ' + lb_stampLogStatus);
    //setting.Batch_Success_Log__c = false --> not create log
    if (lb_stampLogStatus == false) {
      System.debug('Application Log : Not create log.');
    } else {
      CreateBatchLog(Constant.APP_LOG_BATCH_TYPE, BatchName, Constant.STATUS_SUCCESS, QuaryString, BatchRuntime, ExceptionMessage);
    }
    }

    public static void createFailBatchLogUtils(String BatchName, String QuaryString, String BatchRuntime, String ExceptionMessage) {
    CreateBatchLog(Constant.APP_LOG_BATCH_TYPE, BatchName, Constant.STATUS_FAIL, QuaryString, BatchRuntime, ExceptionMessage);
    }

  public static void createSuccessSystemLogUtils(String ApexClass, String LogActionString, String LogInfoString, String RecordData) {
    String ExceptionMessage = '';
    Boolean lb_stampLogStatus = false;
    lb_stampLogStatus = CheckSystemStampLogSuccess();
    System.debug('lb_stampLogStatus3 ' + lb_stampLogStatus);
    //isetting.System_Success_Log__c = false --> not create log
    if (lb_stampLogStatus == false) {
      System.debug('Application Log : Not create log.');
    } else {
      CreateSystemLog(ApexClass, Constant.APP_LOG_SYSTEM_TYPE, LogActionString, LogInfoString, RecordData, Constant.STATUS_SUCCESS, ExceptionMessage);
    }
  }

  public static void createFailSystemLogUtils(String ApexClass, String LogActionString, String LogInfoString, String RecordData, String ExceptionMessage) {
    CreateSystemLog(ApexClass, Constant.APP_LOG_SYSTEM_TYPE, LogActionString, LogInfoString, RecordData, Constant.STATUS_FAIL, ExceptionMessage);
  }

    private static void createIntegrationLogUtils(String WebServiceName, String WebServiceType, String ServiceType, String Request, String Response, String Status, String ExceptionMessage) {
    String ls_webservicetype = '';
    Application_Log__c newApplicationLog = new Application_Log__c();
  
    newApplicationLog.Log_Type__c = ServiceType;
    newApplicationLog.Status__c = Status;
    newApplicationLog.Exception_Message__c = ExceptionMessage;

    //web service body
    Integer webServiceBodyFieldLength = Schema.SObjectType.Application_Log__c.fields.Webservice_Body__c.getLength();
    System.debug('webServiceBodyFieldLength : ' + webServiceBodyFieldLength);

    //web service response
    Integer webServiceResponseFieldLength = Schema.SObjectType.Application_Log__c.fields.Webservice_Response__c.getLength();
    System.debug('webServiceResponseFieldLength : ' + webServiceResponseFieldLength);

    if (Request.length() <= webServiceBodyFieldLength) {
      newApplicationLog.Webservice_Body__c = Request;
    }else{
      //create attachment file of web service body for application log
      newApplicationLog.Webservice_Body__c = Constant.CREATE_LOG_ATTACHMENT;
    }
    if (Response.length() <= webServiceResponseFieldLength) {
      newApplicationLog.Webservice_Response__c = Response;  
    }else{
      //create attachment file of web service response for application log
      newApplicationLog.Webservice_Response__c = Constant.CREATE_LOG_ATTACHMENT;
    }
    System.debug('newApplicationLog.Webservice_Body__c: '+newApplicationLog.Webservice_Body__c);
    System.debug('newApplicationLog.Webservice_Response__c: '+newApplicationLog.Webservice_Response__c);
    newApplicationLog.Webservice_Name__c = WebServiceName;
    newApplicationLog.Webservice_Type__c = CaseCheckWebServeiceType(WebServiceType);
    newApplicationLog.RecordTypeId = CaseCheckRecordType(ServiceType);

    insert newApplicationLog;
    System.debug('newApplicationLog: '+String.valueOf(newApplicationLog));
    if (newApplicationLog.Webservice_Body__c == Constant.CREATE_LOG_ATTACHMENT || newApplicationLog.Webservice_Response__c == Constant.CREATE_LOG_ATTACHMENT) {
      List<Attachment> toInsertAttachmentList = new List<Attachment>();
      if (newApplicationLog.Webservice_Body__c == Constant.CREATE_LOG_ATTACHMENT && newApplicationLog.Webservice_Response__c == Constant.CREATE_LOG_ATTACHMENT) {
        toInsertAttachmentList = createAttachmentForIntegrationLog(newApplicationLog.Id,Request,Response);
      }
      else if (newApplicationLog.Webservice_Body__c == Constant.CREATE_LOG_ATTACHMENT && newApplicationLog.Webservice_Response__c != Constant.CREATE_LOG_ATTACHMENT) {
        toInsertAttachmentList = createAttachmentForIntegrationLog(newApplicationLog.Id,Request,null);
      }
      else if (newApplicationLog.Webservice_Body__c != Constant.CREATE_LOG_ATTACHMENT && newApplicationLog.Webservice_Response__c == Constant.CREATE_LOG_ATTACHMENT) {
        toInsertAttachmentList = createAttachmentForIntegrationLog(newApplicationLog.Id,null,Response);    
      }
      if (toInsertAttachmentList.size() > 0 ) {
        insert toInsertAttachmentList;      
      }    
    }
  }    

    private static void CreateBatchLog(String ServiceType, String BatchName, String Status, String QuaryString, String BatchRuntime, String ExceptionMessage) {
        Application_Log__c newApplicationLog = new Application_Log__c();
  
    newApplicationLog.Log_Type__c = ServiceType;
    newApplicationLog.Status__c = Status;
    newApplicationLog.Batch_Name__c = BatchName;
    newApplicationLog.Log_Query__c = QuaryString;
    newApplicationLog.Batch_RunTime__c = BatchRuntime;
    newApplicationLog.RecordTypeId = CaseCheckRecordType(ServiceType);

    Integer exceptionhMessageFieldLength = Schema.SObjectType.Application_Log__c.fields.Exception_Message__c.getLength();
    System.debug('exceptionhMessageFieldLength : ' + exceptionhMessageFieldLength);

        if (ExceptionMessage.length() <= exceptionhMessageFieldLength) {
      newApplicationLog.Exception_Message__c = ExceptionMessage;
    }else{
      //create attachment file of batch message for application log
      newApplicationLog.Exception_Message__c = Constant.CREATE_LOG_ATTACHMENT;
    }

        insert newApplicationLog;

        if (newApplicationLog.Exception_Message__c == Constant.CREATE_LOG_ATTACHMENT) {
      List<Attachment> toInsertAttachmentList = new List<Attachment>();
      if (newApplicationLog.Exception_Message__c == Constant.CREATE_LOG_ATTACHMENT) {
        toInsertAttachmentList = createAttachmentForBatchLog(newApplicationLog.Id, ExceptionMessage);
      }
      if (toInsertAttachmentList.size() > 0 ) {
        insert toInsertAttachmentList;      
      }    
    }
    }

  private static void CreateSystemLog(String ApexClass, String ServiceType, String LogActionString, String LogInfoString, String RecordData, String Status, String ExceptionMessage) {
    Application_Log__c newApplicationLog = new Application_Log__c();
  
    newApplicationLog.Apex_Class__c = ApexClass;
    newApplicationLog.Log_Type__c = ServiceType;
    newApplicationLog.Status__c = Status;
        newApplicationLog.Exception_Message__c = ExceptionMessage;
    newApplicationLog.Log_Action__c = LogActionString;
    newApplicationLog.Log_Info__c = LogInfoString;
    newApplicationLog.Record_Data__c = RecordData;
    newApplicationLog.RecordTypeId = CaseCheckRecordType(ServiceType);

    insert newApplicationLog;
  }
    
  private static String CaseCheckRecordType(String ServiceType) {
    String recordTypeData = '';
    if (ServiceType.equalsIgnoreCase(Constant.APP_LOG_WEBSERVICE_TYPE)) { 
      List<RecordType> recordSetting = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constant.APP_LOG_RECORDTYPE_INTEGRATION];
      recordTypeData = String.valueof(recordSetting[0].Id);
    }  else if (ServiceType.equalsIgnoreCase(Constant.APP_LOG_BATCH_TYPE)) { 
      List<RecordType> recordSetting = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constant.APP_LOG_RECORDTYPE_BATCH];
      recordTypeData = String.valueof(recordSetting[0].Id);
    } else if (ServiceType.equalsIgnoreCase(Constant.APP_LOG_SYSTEM_TYPE)) { 
      List<RecordType> recordSetting = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constant.APP_LOG_RECORDTYPE_SYSTEM];
      recordTypeData = String.valueof(recordSetting[0].Id);
        }else { recordTypeData = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DeveloperNameOfRecordType').getRecordTypeId(); }

    return recordTypeData;
  }

  private static String CaseCheckWebServeiceType(String WebServiceType)
  {
    String webServiceTypeData = '';
    if (WebServiceType.equalsIgnoreCase('inbound')) { webServiceTypeData = Constant.APP_LOG_INBOUND_TYPE;
    } else if (WebServiceType.equalsIgnoreCase('outbound')) { webServiceTypeData = Constant.APP_LOG_OUTBOUND_TYPE;
    } else { webServiceTypeData = 'Other'; }

    return webServiceTypeData;
  }
  /*
  private static String CaseCheckServeiceType(String ServiceType) {
    String serviceTypeData = '';
    if (ServiceType.equalsIgnoreCase('batch')) { serviceTypeData = Constant.APP_LOG_BATCH_TYPE;
    } else if (ServiceType.equalsIgnoreCase('system')) { serviceTypeData = Constant.APP_LOG_SYSTEM_TYPE;
        } else if (ServiceType.equalsIgnoreCase('webservice')) { serviceTypeData = Constant.APP_LOG_WEBSERVICE_TYPE;
    } else { serviceTypeData = 'Other'; }

    return serviceTypeData;
  }*/

  private static List<Attachment> createAttachmentForIntegrationLog(Id integrationLogId, String Request, String Response){
    //create attachment for integration log if web service Request|Response exceeded field length limit
    List<Attachment> toReturnAttachmentList = new List<Attachment>();
    if (Request != null) {
      Attachment attachRequest = new Attachment();
      attachRequest.ParentId = integrationLogId;
      attachRequest.Name = 'Web_Service_Body';
      attachRequest.ContentType = 'text/plain';
      attachRequest.Body = Blob.valueOf(Request);

      toReturnAttachmentList.add(attachRequest);
    }
    
    if (Response != null) {
      Attachment attachResponse = new Attachment();
      attachResponse.ParentId = integrationLogId;
      attachResponse.Name = 'Web_Service_Response';
      attachResponse.ContentType = 'text/plain';
      attachResponse.Body = Blob.valueOf(Response);

      toReturnAttachmentList.add(attachResponse);    
    }
    return toReturnAttachmentList;
  }
    
    private static List<Attachment> createAttachmentForBatchLog(Id integrationLogId, String BatchMessage){
    //create attachment for batch log if Batch message exceeded field length limit
    List<Attachment> toReturnAttachmentList = new List<Attachment>();
    if (BatchMessage != null) {
      Attachment attachBatch = new Attachment();
      attachBatch.ParentId = integrationLogId;
      attachBatch.Name = 'Batch_Message';
      attachBatch.ContentType = 'text/plain';
      attachBatch.Body = Blob.valueOf(BatchMessage);

      toReturnAttachmentList.add(attachBatch);
    }
    
    return toReturnAttachmentList;
  }

  private static Boolean CheckWSStampLogSuccess() {
    //Use for check Web service stamp log setting
    Boolean lb_returnStatus = false;
    List<ApplicationLogActivation__c> setting = [SELECT WS_Success_Log__c FROM ApplicationLogActivation__c];
        if (!setting.isEmpty() && setting.size() > 0) {
            lb_returnStatus = Boolean.valueof(setting[0].WS_Success_Log__c);
        }
    return lb_returnStatus;
  }

  private static Boolean CheckBatchStampLogSuccess() {
    //Use for check Batch stamp log setting
    Boolean lb_returnStatus = false;
    List<ApplicationLogActivation__c> setting = [SELECT Batch_Success_Log__c FROM ApplicationLogActivation__c];
        if (!setting.isEmpty() && setting.size() > 0) {
            lb_returnStatus = Boolean.valueof(setting[0].Batch_Success_Log__c);
        }
    return lb_returnStatus;
  }

  private static Boolean CheckSystemStampLogSuccess() {
    //Use for check Web service stamp log setting
    Boolean lb_returnStatus = false;
    List<ApplicationLogActivation__c> setting = [SELECT System_Success_Log__c FROM ApplicationLogActivation__c];
        if (!setting.isEmpty() && setting.size() > 0) {
            lb_returnStatus = Boolean.valueof(setting[0].System_Success_Log__c);
        }
    return lb_returnStatus;
  }
}
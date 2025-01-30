@isTest
public with sharing class WSAPICallout_Test {
    static String SERVICENAME = 'Callout_Get_Account_Detail';
    static String REQUEST_BODY = '{"status":[],"productSymbol":[],"periodTo":"2022-03-10T16:59:59","periodFrom":"2021-09-10T17:00:10","orderType":[],"accountNumber":"DA-000098"}';
    static String RESPONSE_BODY = '{"code":"0000","message":"Success","data":[]}';
    static String API_KEY = '';
    static String API_STATUS_CODE = 'S';
    static String API_ERROR_CODE = '';
    static String EXTERNAL_KEY = '';

    @isTest 
  static void test_callOut(){
        WSAPICallout apiCall = new WSAPICallout(SERVICENAME);
      	apiCall.setCustCode('xx');
        apiCall.setRequestBody(REQUEST_BODY,API_KEY);
        apiCall.setResponseBody(RESPONSE_BODY);
        apiCall.callout();
        String response = apiCall.getResponseBody();
        String endPoint = apiCall.getEndPoint();
        Boolean isRetrievedFromCache = apiCall.getIsRetrievedFromCache();
        String requestLabel = apiCall.getRequestLabel();
        String requestBody = apiCall.getRequestBody();
        String serviceName = apiCall.getServiceName();
        Integer responseCode = apiCall.getResponseCode();
      	String responseStatud = apiCall.getResponseStatus();
        WSAuthen__mdt apiAuthen = apiCall.getApiAuthen();
        apiAuthen.AccessToken__c = 'mockToken';
        System.debug('apiAuthen: '+String.valueOf(apiAuthen));
        WSService__mdt apiConfig = apiCall.getApiConfig();
        WSAPICallout.startContinuationRequest(apiAuthen, apiConfig, '', '', '', '');
    }
    @isTest 
  static void test_callOutContinuation(){
        WSAPICallout apiCall = new WSAPICallout(SERVICENAME);
        apiCall.setRequestBody(REQUEST_BODY,API_KEY,EXTERNAL_KEY);
        apiCall.setResponseBody(RESPONSE_BODY);
        apiCall.callout(true);
        String response = apiCall.getResponseBody();
        String endPoint = apiCall.getEndPoint();
        Boolean isRetrievedFromCache = apiCall.getIsRetrievedFromCache();
        String requestLabel = apiCall.getRequestLabel();
        String requestBody = apiCall.getRequestBody();
        String serviceName = apiCall.getServiceName();
        Integer responseCode = apiCall.getResponseCode();
    }
    
    @isTest 
  static void test_getmock(){
       String mock_response = WSAPICallout.getMOCKResponse(SERVICENAME);
    }
}
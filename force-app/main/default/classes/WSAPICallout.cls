public inherited sharing class WSAPICallout {
    public String dateTimeString = Util.toGMT7TextUserUpdate(Constant.NOW).replace(' ','T').replace('+07:00','.000+07:00');
    private String SERVICENAME;
    private static final String LOCALSESSION = 'localSession';
    WSService__mdt apiConfig;
    private WSAuthen__mdt apiAuthen;
    private String request_body;
    private Integer response_code;
    private String response_status;
    private String response_body;
    private String request_label;
    private String api_key;
    private Boolean isRetrievedFromCache;
    private String requestRecordExternalKey;
    private String custCode;

    public WSAPICallout(String serviceName)
    {
        apiConfig = new WSService__mdt();
        this.SERVICENAME = serviceName;
        this.isRetrievedFromCache = false;
    }
    
    public String getEndPoint() {
        if(this.apiConfig == null || this.apiConfig.Url__c == null || Test.isRunningTest()) {
            this.apiConfig = getConfigByDevName(this.SERVICENAME);
        }
        if(this.apiAuthen == null || Test.isRunningTest()) {
            WSAPIAuthen oAuth = new WSAPIAuthen();
            this.apiAuthen = oAuth.getAuthenWithScope(this.apiConfig.Authen__c);
        }
        //return this.apiAuthen.BasePath__c + this.apiConfig.Url__c;
        return this.apiAuthen.InstantURL__c + this.apiConfig.Url__c;
    }

    public void setRequestBody(String request_body, String api_key)
    {
        this.request_body = request_body;
        this.api_key = api_key;
    }

    public void setRequestBody(String request_body, String api_key, String requestRecordExternalKey)
    {
        this.request_body = request_body;
        this.api_key = api_key;
        this.requestRecordExternalKey = requestRecordExternalKey;
    }

    public void setCustCode(String custCode)
    {
        this.custCode = custCode;
    }

    public Boolean getIsRetrievedFromCache() {
        return this.isRetrievedFromCache;
    }

    public String getRequestLabel()
    {
        return this.request_label;
    }
    
    public String getRequestBody()
    {
        return this.request_body;
    }

    public String getServiceName() {
        return this.SERVICENAME;
    }

    public Integer getResponseCode()
    {
        return this.response_code;
    }

    public String getResponseStatus()
    {
        return this.response_status;
    }

    public String getResponseBody()
    {
        return this.response_body;
    }

    public WSService__mdt getApiConfig()
    {
        return this.apiConfig;
    }

    public WSAuthen__mdt getApiAuthen()
    {
        return this.apiAuthen;
    }

    public void callout()
    {
        processCallout(false);
    }

    public Object callout(Boolean isContinuation)
    {
        return processCallout(isContinuation);
    }

    public Object processCallout(Boolean isContinuation) {
        this.apiConfig = getConfigByDevName(this.SERVICENAME);
        if(this.apiConfig.CallType__c != '' && this.apiConfig.CallType__c == 'MOCK')
        {   
            this.response_code = 200;
            this.response_body = getMOCKResponse(this.SERVICENAME);
        }
        else
        {
            if(!isContinuation && apiConfig.CacheTimeSecond__c != null && apiConfig.CacheTimeSecond__c > 0)
            {
                Cache.SessionPartition sessionPart = Cache.Session.getPartition(LOCALSESSION);
                System.debug('check cache before get response ' + this.api_key);
                System.debug(sessionPart.contains(this.api_key));
                System.debug('check cache before get response ' + sessionPart.contains(this.api_key));
                if (!sessionPart.contains(this.api_key)){
                    System.debug('get response from callout and store cache');
                    Object contCallout = calloutAPIService(isContinuation);
                    sessionPart.put(this.api_key, this.response_body, (Integer)apiConfig.CacheTimeSecond__c);
                    return contCallout;
                } else {
                    System.debug('get response from cache');
                    this.isRetrievedFromCache = true;
                    this.response_code = 200;
                    this.response_body = (String)sessionPart.get(this.api_key);
                }
            }
            else
            {
                System.debug('get response from callout without storing cache');
                return calloutAPIService(isContinuation);
            }
        }
        return null;
    }

    public Object calloutAPIService(Boolean isContinuation)
    {
        WSAPIAuthen oAuth = new WSAPIAuthen(this.apiConfig.Authen__c);
        this.apiAuthen = oAuth.getAuthen();
        System.debug('AUTHEN :'+this.apiAuthen);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse resp;
        try{
            if (isContinuation) {
                System.debug('calloutAPIService is called with continuation ' + this.SERVICENAME + 'Running test ? ' + Test.isRunningTest());
                // call from another controller
                if(Test.isRunningTest()) {
                    System.debug('about to call mockContinuationRequest');
                    return mockContinuationRequest(this.apiAuthen, this.apiConfig, this.request_body, this.SERVICENAME, this.requestRecordExternalKey, getEndPoint());
                }
                return startContinuationRequest(this.apiAuthen, this.apiConfig, this.request_body, this.SERVICENAME, this.requestRecordExternalKey, getEndPoint());
                // return con;
            } else {
                request = getRequest();
                System.debug('REQUEST BODY :'+request.getBody());
                resp = Http.send(request);
                this.response_code = resp.getStatusCode();
                this.response_status = resp.getStatus();
                this.response_body = resp.getBody();
                System.debug('RESPONSE BODY :'+resp.getBody());
                //oAuth.saveAuthRecord();
                //saveLog(this.SERVICENAME, this.request_body, this.response_body,'PASS','');
            }
            return null;
        }catch(Exception ex){
            try{
                WSErrorJSON.Root_object error = WSErrorJSON.parse(resp.getBody());
                System.debug('Exception RESPONSE BODY :'+request.getBody());
                this.response_body = resp.getBody();
                //saveLog(this.SERVICENAME, this.request_body, this.response_body,'FAIL',error.error.code);
            }catch(Exception ex2){
                if(resp!=null) {
                    this.response_body = resp.getBody();
                    //saveLog(this.SERVICENAME ,this.request_body, this.response_body,'FAIL','');
                } else {
                    this.response_body = '{"error": { "code": "-1", "message" : "Service timeout"}}';
                }
                //throw new KWBPOSTSaveOpportunityException(ex.getMessage()); 
            }
        }
        return null;
    }
    
    @AuraEnabled(continuation=true)
    public static Object startContinuationRequest(WSAuthen__mdt apiAuthen, WSService__mdt apiConfig, String request_body, String serviceName, String requestRecordExternalKey, String requestEndPoint) {
        APICalloutModel calloutModel = new APICalloutModel();
        calloutModel.requestEndPoint = requestEndPoint;
        calloutModel.serviceName = serviceName;
        calloutModel.requestBody = request_body;
        calloutModel.requestRecordExternalKey = requestRecordExternalKey;
        // Create continuation. Argument is timeout in seconds.
        Continuation con = new Continuation(40);
        con.continuationMethod='processResponse';
        // Add callout request to continuation
        HttpRequest request = getRequest(apiAuthen, apiConfig, request_body);
        con.addHttpRequest(request);
        con.state = calloutModel;
        // Return the continuation
        return con;
    }

    public Object mockContinuationRequest(WSAuthen__mdt apiAuthen, WSService__mdt apiConfig, String request_body, String serviceName, String requestRecordExternalKey, String requestEndPoint) {
        System.debug('mockContinuationRequest is called');
        System.debug('requestEndPoint ' + requestEndPoint);
        System.debug('serviceName ' + serviceName);
        System.debug('request_body ' + request_body);
        System.debug('requestRecordExternalKey ' + requestRecordExternalKey);
        APICalloutModel calloutModel = new APICalloutModel();
        calloutModel.requestEndPoint = requestEndPoint;
        calloutModel.serviceName = serviceName;
        calloutModel.requestBody = request_body;
        calloutModel.requestRecordExternalKey = requestRecordExternalKey;
        // Create continuation. Argument is timeout in seconds.
        System.debug('init continuation');
        Continuation con = new Continuation(40);
        con.continuationMethod='processResponse';
        // Add callout request to continuation
        HttpRequest request = getRequest(apiAuthen, apiConfig, request_body);
        this.request_label = con.addHttpRequest(request);
        System.debug('mockContinuationRequest ' + request);
        System.debug('mockContinuationRequest ' + this.request_label);
        con.state = calloutModel;
        return con;
    }
    
    private HttpRequest getRequest(){
        //String guid = GuidUtil.NewGuid();
        //String dateTimeString = Util.toGMT7TextUserUpdate(AppConstants.NOW).replace(' ','T').replace('+07:00','.000+07:00');
        HttpRequest request = new HttpRequest();
        //request.setEndpoint(this.apiAuthen.BasePath__c + this.apiConfig.url__c);
        String url = this.apiConfig.url__c;
        if (url.contains('{cust_code}')) {
            url = url.replace('{cust_code}', this.custCode);
        }
        request.setEndpoint(this.apiAuthen.InstantURL__c + url);
        System.debug('URL :'+this.apiAuthen.InstantURL__c + url);
        request.setTimeout(120000);
        request.setMethod(this.apiConfig.CallType__c);
        System.debug('Method :'+this.apiConfig.CallType__c);
        //request.setHeader('X-Client-Transaction-ID', guid);
        //request.setHeader('X-Client-Transaction-Datetime',dateTimeString);
        //request.setHeader('api-key', this.apiAuthen.ClientId__c);
        request.setHeader('Content-Type','application/json');
        request.setHeader('accept','*/*');
        request.setHeader('x-api-key', this.apiAuthen.CLientSecret__c);
        request.setHeader('Authorization', this.apiAuthen.TokenType__c + ' ' + this.apiAuthen.AccessToken__c); 
        System.debug('Token Type: '+this.apiAuthen.TokenType__c);
        System.debug('Token :'+apiAuthen.AccessToken__c);

        //Set body with Signature
        //String X_SIGNATURE = generateHmacSHA256Signature(this.request_body, this.apiConfig.SecretKey__c);
        //request.setHeader('X-Signature', X_SIGNATURE);
        if(this.apiConfig.CallType__c != 'GET') request.setBody(this.request_body);

        return request;
    }

    // static call for aura
    private static HttpRequest getRequest(WSAuthen__mdt apiAuthen, WSService__mdt apiConfig, String request_body){
        //String guid = GuidUtil.NewGuid();
        //String dateTimeString = Util.toGMT7TextUserUpdate(AppConstants.NOW).replace(' ','T').replace('+07:00','.000+07:00');
        HttpRequest request = new HttpRequest();
        //request.setEndpoint(this.apiAuthen.BasePath__c + this.apiConfig.url__c);
        request.setEndpoint(apiAuthen.InstantURL__c + apiConfig.url__c);
        request.setTimeout(120000);
        request.setMethod(apiConfig.CallType__c);
        //request.setHeader('X-Client-Transaction-ID', guid);
        //request.setHeader('X-Client-Transaction-Datetime',dateTimeString);
        //request.setHeader('api-key', apiAuthen.ClientId__c);
        request.setHeader('Content-Type','application/json');
        request.setHeader('accept','*/*');
        //request.setHeader('Authorization', apiAuthen.TokenType__c + ' ' + apiAuthen.AccessToken__c);
        request.setHeader('x-api-key', apiAuthen.AccessToken__c);
        
        //Set body with Signature
        //String X_SIGNATURE = generateHmacSHA256Signature(request_body, apiConfig.SecretKey__c);
        //request.setHeader('X-Signature', X_SIGNATURE);
        request.setBody(request_body);

        return request;
    }
    
    @TestVisible
    private static String getMOCKResponse(string serviceName)
    {
        String response = '';
        List<WSMockupData__mdt> mocks = new List<WSMockupData__mdt>();
        mocks = [SELECT Id, json__c FROM WSMockupData__mdt WHERE DeveloperName =: serviceName];
        if(mocks.size() > 0) response = mocks.get(0).json__c;
        return response;
    }
    @TestVisible
    private void setResponseBody(String response_body)
    {
        this.response_body = response_body;
    }
    /*
    private static String generateHmacSHA256Signature(String saltValue, String secretKeyValue) {
    String algorithmName = 'HmacSHA256';

        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(saltValue), Blob.valueOf(secretKeyValue));

        return EncodingUtil.base64Encode(hmacData);
    }*/
    
    private static WSService__mdt getConfigByDevName(String serviceName)
    {
        List<WSService__mdt> apiConfigs = new List<WSService__mdt>();
        WSService__mdt config = new WSService__mdt();
        apiConfigs = [Select id, Authen__c, CacheTimeSecond__c, DeveloperName, MasterLabel, SecretKey__c, url__c, CallType__c From WSService__mdt where DeveloperName =: serviceName];
        System.debug('getConfigByDevName apiConfigs.size() ' + apiConfigs.size());
        if(apiConfigs.size() > 0) config = apiConfigs.get(0);
        return config;
    }
    /*
    @TestVisible
    @future(callout=true) 
    private static void saveLog(String serviceName, String request_body,String response, String statusCode,String errorCode){
        ApplicationLog__c logObj = new ApplicationLog__c( 
                                        be8omni_WebserviceName__c       = serviceName,
                                        be8omni_LogType__c              = 'WebserviceLog',
                                        be8omni_WebserviceRequest__c    = request_body,
                                        be8omni_WebserviceResponse__c   = response,
                                        be8omni_WebserviceType__c       = 'OUTBOUND',
                                        be8omni_IntegrationDate__c      = AppConstants.NOW,
                                        be8omni_Status__c   = statusCode,
                                        //RequestRecordExternalKey__c = this.queryId,
                                        be8omni_ErrorMessage__c             = errorCode

                                ); 
        if(!Test.isRunningTest()) insert logObj;
        // else this.logs.add(logObj);
    }*/
    
    public class CCAPICallOutException extends Exception{}

    public class APICalloutModel{
        @AuraEnabled
        public String requestEndPoint      { get; set; }
        @AuraEnabled
        public String serviceName      { get; set; }
        @AuraEnabled
        public String requestBody      { get; set; }
        @AuraEnabled
        public String requestRecordExternalKey      { get; set; }
    }
}
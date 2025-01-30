public inherited sharing class WSAPIAuthen {
  private String contentType   = 'application/x-www-form-urlencoded';
  //private String contentType   = 'application/json';
  //private String contentType   = 'multipart/form-data';
  private String grantType   = 'client_credentials';
  private AuthenticateResponse authResponse;
  private WSAuthen__mdt apiConfig;

    public WSAPIAuthen() { }

    public WSAPIAuthen(String scopeId) {
    getConfigByAPIName(scopeId);
    if((this.apiConfig.Expires__c == null || this.apiConfig.Expires__c <= Constant.NOW.addMinutes(-5)) && !Test.isRunningTest()) callOut();
  }

  public WSAuthen__mdt getAuthenWithScope(String scopeId) {
    getConfigByAPIName(scopeId);
    return this.apiConfig;
  }
  
  public WSAuthen__mdt getAuthen(){
    return this.apiConfig;
  }
    
  private void getConfigByAPIName(String scopeId){
    WSAuthen__mdt scopeCredential = getOpenAPICredentialByScope(scopeId);
    this.apiConfig = scopeCredential;
  }

  @TestVisible 
  private void callOut(){
    Http http = new Http();

    HttpRequest request = getRequest();
    HttpResponse response;
    system.debug('request: ' + request);
    if(!Test.isRunningTest()) response = http.send(request);
    system.debug('response: ' + response);
    //system.debug('response body: ' + response.getBody());

    try{
      if(!Test.isRunningTest()) authResponse = (AuthenticateResponse)JSON.deserialize(response.getBody(), AuthenticateResponse.class);
      if(authResponse.access_token != null)
      {
        this.apiConfig.Accesstoken__c = authResponse.access_token;
        this.apiConfig.TokenType__c = authResponse.token_type;
        this.apiConfig.Issued__c = Constant.NOW;
        this.apiConfig.Expires__c = Constant.NOW.addSeconds(authResponse.expires_in);
        //if(!String.isBlank(authResponse.instanturl)) this.apiConfig.InstantURL__c = authResponse.instanturl;
      }
    }catch(Exception ex){
      String message = 'Authen fail';
      message += '\n error : ' + ex.getMessage();
      throw new OpenAPIAuthenticationException(message);
    }
  }

  @TestVisible 
  private void setResponse(AuthenticateResponse mockResponse){
    this.authResponse = mockResponse;
  }

  @TestVisible
  private HttpRequest getRequest(){
    System.debug('Endpoint: '+this.apiConfig.BasePath__c+this.apiConfig.EndPoint__c);
    HttpRequest request = new HttpRequest();
    //request.setClientCertificateName('SelfSignedCert_17Feb2021_033630');
    request.setEndpoint(this.apiConfig.BasePath__c+this.apiConfig.EndPoint__c);
    request.setMethod('POST');
    request.setHeader('Content-Type', this.contentType);
    //request.setHeader('Content-Type', HttpFormBuilder.GetContentType());
    // request.setHeader('Content-Type', 'multipart/form-data; boundary=<calculated when request is sent>');
    // request.setHeader('Authorization', this.apiConfig.ClientId__c);
    request.setBody(getBody());
    return request;
  }

  @TestVisible
  private static WSAuthen__mdt getOpenAPICredentialByScope(String scopeId){
    List<WSAuthen__mdt> APICredentials = new List<WSAuthen__mdt>();
    WSAuthen__mdt configs = new WSAuthen__mdt();
    APICredentials = [SELECT id, ClientId__c, CLientSecret__c, GrantType__c, BasePath__c, Username__c, Password__c, InstantURL__c,
    AccessToken__c, Expires__c, Issued__c, EndPoint__c, MasterLabel, DeveloperName, TokenType__c, Scope__c FROM WSAuthen__mdt 
    WHERE id =:scopeId];
    if(APICredentials.size() > 0) configs = APICredentials.get(0);
    return configs;
  }

  private String getBody(){
    String body = '';
    /*body += 'grant_type=' + this.grantType;
    body += '&scope=' + this.apiConfig.Scope__c;
    body += '&client_id=' + this.apiConfig.ClientId__c;
    body += '&client_secret=' + this.apiConfig.CLientSecret__c;
    body += '"source":"' + this.apiConfig.CLientSecret__c + '",';
    body += '"username":"' + this.apiConfig.Username__c + '",'; 
    body += '"password":"' + this.apiConfig.Password__c + '"'; */
    body += 'grant_type=' + this.apiConfig.GrantType__c;
    body += '&client_id=' + this.apiConfig.ClientId__c;
    body += '&client_secret=' + this.apiConfig.CLientSecret__c;
    body += '&scope=' + this.apiConfig.Scope__c;
    body += '&username=' + this.apiConfig.Username__c; 
    body += '&password=' + this.apiConfig.Password__c;
    // body += '&resource=' + this.apiConfig.
    //body += '}';

    /*
    body += HttpFormBuilder.WriteBoundary();
    body += HttpFormBuilder.WriteBodyParameter('id', recordId);
    body += HttpFormBuilder.WriteBoundary();
    body += HttpFormBuilder.WriteBodyParameter('userId', userId);
    body += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
    */
    System.debug(body);
    return body;
  } 

  public class AuthenticateResponse{
    public String   access_token;
    public Integer   expires_in;
    public String   token_type;
    public String   scope;
    public List<String> roles;
  }
    
  public void saveAuthRecord() {
        try{
      WSAuthen__mdt metadataRecord = this.apiConfig;
            String nameSpacePrefix = '';
            // A unique name for developer name 
            // Set up custom metadata to be created in the subscriber org.
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = 'WSAuthen__mdt.' + metadataRecord.DeveloperName;
            customMetadata.label = metadataRecord.MasterLabel;
             
            // Add all the field values 
            
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'Issued__c';
            customField.value = metadataRecord.Issued__c;
            customMetadata.values.add(customField);
            
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Expires__c';
            customField.value = metadataRecord.Expires__c;
            customMetadata.values.add(customField);
            
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'AccessToken__c';
            customField.value = metadataRecord.AccessToken__c;
      customMetadata.values.add(customField);
      
      customField = new Metadata.CustomMetadataValue();
            customField.field = 'TokenType__c';
            customField.value = metadataRecord.TokenType__c;
      customMetadata.values.add(customField);

      customField = new Metadata.CustomMetadataValue();
      customField.field = 'InstantURL__c';
      customField.value = metadataRecord.InstantURL__c;
      customMetadata.values.add(customField);
            
            System.debug( ' >>>> Created custom metadata object >>> ' + customMetadata );
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            
            // Setup deploy callback, MyDeployCallback implements
            // the Metadata.DeployCallback interface 
            CustomMetadataCallback callback = new CustomMetadataCallback();
        
            // Enqueue custom metadata deployment
            // jobId is the deployment ID
            Id jobId = Test.isRunningTest() ? 'a059D000000HkxKQAS' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
            
        }catch(Exception ex){
      System.debug('Exception : ' + ex.getMessage());
        }
        
    return; 
    }

  public class OpenAPIAuthenticationException extends Exception{}
}
@isTest
public with sharing class WSAPIAuthen_Test {
    private static String MOCK_RESPONSE = '{"access_token":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9","token_type":"Bearer","expires_in":3600}';

    @isTest 
  static void test_authenticate(){
        Id scopeId = getMetaData();
        WSAPIAuthen auth = new WSAPIAuthen(scopeId);
        WSAPIAuthen.AuthenticateResponse response = (WSAPIAuthen.AuthenticateResponse)JSON.deserialize(MOCK_RESPONSE, WSAPIAuthen.AuthenticateResponse.class);
        auth.setResponse(response);
        auth.callOut();
    auth.saveAuthRecord();
  }
  @isTest 
  static void test_fail_getauthen(){
        Id scopeId = getMetaData();
        WSAPIAuthen auth = new WSAPIAuthen(scopeId);
        WSAuthen__mdt config = auth.getAuthen();
        
    }

    private static Id getMetaData()
    {
        List<WSAuthen__mdt> configs = new List<WSAuthen__mdt>();
        configs = [Select Id from WSAuthen__mdt];

        return configs.get(0).Id;
    }
}
@isTest
public class WSErrorJSON_Test {
  @isTest 
  static void testParse(){
        String errorTxt = '{"error":{"code":"1000-Fail"}}';
        WSErrorJSON.Root_object error = WSErrorJSON.parse(errorTxt);
        System.debug(error.error);
        System.debug(error.error.code);
        System.debug(error.error.messageTH);
        System.debug(error.error.serverTransactionID);
        System.debug(error.error.message);
        System.debug(error.error.serverDateTime);
        System.debug(error.error.clientTransactionID);
    }
}
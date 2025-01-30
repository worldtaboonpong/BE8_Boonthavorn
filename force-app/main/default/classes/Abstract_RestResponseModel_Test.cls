@isTest
public class Abstract_RestResponseModel_Test {
    private static String MOCK_RESPONSE = '{"isSuccess":true,"message":"Success","timeStamp":"2022-01-28T11:24:53"}';
    
    @isTest
    static void testModel()	{
        Test.startTest();
        WSCalloutCreateAccountToSAP.response model = new WSCalloutCreateAccountToSAP.response();
        model = (WSCalloutCreateAccountToSAP.response) JSON.deserialize(MOCK_RESPONSE, WSCalloutCreateAccountToSAP.response.class);
        System.debug(model.timeStamp);
        System.debug(model.SystemDate);
        Test.stopTest();
    }
}
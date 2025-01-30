public without sharing class WSCalloutGetAccountDetailFromSAP {
    public static response callout(Account acc){
        response result = new response();
        String custCode = acc.Customer_ID__c;
        if(custCode != null) result = responseRequest(custCode);
        else {
            result.isSuccess = false;
            result.message = 'Cannot get Customer ID';
        }
        return result;
    }
    public static response responseRequest(String custCode){
        response result = new response();
        String res = '';
        String message;
        Map<String, Object> mapResponse;
        Map<String, Object> payload = new Map<String, Object>();
        Boolean isSuccess = false;
        String cid;
        try {
            WSAPICallout apicall = new WSAPICallout('Callout_Get_Account_Detail');
            apicall.setCustCode(custCode);
            apicall.callout();
            
            res = apicall.getResponseBody();
            if(!String.isBlank(res)){
                mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res);
                System.debug('API'+res);
                System.debug('Parsed JSON'+mapResponse);
                isSuccess = (Boolean)mapResponse.get('isSuccess');
                message = (String)mapResponse.get('message');
                System.debug('isSuccess : ' + isSuccess); 
                if(isSuccess) {
                    //Create Application Log Entry (Success)
                    if(mapResponse.containsKey('payload')) payload = (Map<String, Object>)mapResponse.get('payload');
                    if(!payload.isEmpty() && payload.containsKey('cid')) {
                        cid = (String)payload.get('cid');
                    }    
                    ApplicationLogActivation__c logAPISetting = ApplicationLogActivation__c.getOrgDefaults();
                    if (logAPISetting.WS_Success_Log__c){
                        ApplicationLogUtils.createSuccessIntegrationLogUtils('WSCalloutGetAccountDetailFromSAP', Constant.APP_LOG_OUTBOUND_TYPE, '', res);
                    }
                } else {
                    //Create Application Log Entry (Fail)
                    ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutGetAccountDetailFromSAP', Constant.APP_LOG_OUTBOUND_TYPE, '', res, 'Fail');
                }
            } else {
                String error = apicall.getResponseStatus();
                message = error;
                System.debug(error);

                //Create Application Log Entry (Fail)
                ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutGetAccountDetailFromSAP', Constant.APP_LOG_OUTBOUND_TYPE, '', res, 'Fail');
            }
        } catch(Exception ex) {
            // result.code = '1000-Invalid Format';
            String error = !String.isBlank(res)? res : ex.getMessage();
            System.debug('message : ' + error);
            message = error;

            //Create Application Log Entry (Fail)
            system.debug('ex: ' + String.valueOf(ex));
            system.debug('res: ' + String.valueOf(res));

            ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutGetAccountDetailFromSAP', Constant.APP_LOG_OUTBOUND_TYPE, '', res, ex.getMessage());
        }
        result.isSuccess = isSuccess;
        result.message = message;
        result.cid = cid;
        return result;
    }

    public class response {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String cid;
    }

}
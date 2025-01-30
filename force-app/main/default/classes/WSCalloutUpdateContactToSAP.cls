public without sharing class WSCalloutUpdateContactToSAP {
    @AuraEnabled(cacheable=true)
    public static response callout(Contact contact){
        response result = new response();
        String body = getRequestBody(contact);
        result = responseRequest(body);
        return result;
    }

    public static String getRequestBody(Contact con){

        ContactData contactData = new ContactData();
        contactData.contact_id = con.Contact_ID__c;
        if(con.Account != null) contactData.customer_code = con.Account.Customer_ID__c;
        else {
            Account acc = [SELECT Id, Customer_ID__c FROM Account WHERE Id =: con.AccountId limit 1];
            contactData.customer_code = acc.Customer_ID__c;
        }
        contactData.title = con.Salutation_TH__c;
        contactData.firstname = con.Firstname;
        contactData.lastname = con.Lastname;
        contactData.department = con.Department;
        contactData.function = con.Function__c;
        contactData.email = con.Email;
        // contactData.street = con.Street__c;
        // contactData.city = con.Province__c;
        contactData.langu = 'TH';
        contactData.mobile = con.MobilePhone;

        String requestBodyJSONString = JSON.serialize(contactData, true);
        system.debug('Callout Update Contact To SAP API Request Body: ' + requestBodyJSONString);
        return requestBodyJSONString;
    }

    public static response responseRequest(String body){
        response result = new response();
        String res = '';
        Map<String, Object> mapResponse;
        Map<String, Object> payload;
        List<Object> listPayload;
        Boolean isSuccess = false;
        try {
            WSAPICallout apicall = new WSAPICallout('Callout_Update_Contact_To_SAP');
            apicall.setRequestBody(body, '');
            apicall.callout();
            
            res = apicall.getResponseBody();
            if(!String.isBlank(res)){
                mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res);
                System.debug('API'+res);
                System.debug('Parsed JSON'+mapResponse);
                isSuccess = (Boolean)mapResponse.get('isSuccess');
                result.message = (String)mapResponse.get('message');   
                System.debug('isSuccess : ' + isSuccess); 
                if(isSuccess) {
                    payload = (Map<String, Object>) mapResponse.get('payload');
                    result.payload = new responsePayload();
                    result.payload.contactId = (String)payload.get('contact_id');
                    if(payload.get('status') == 'E') {
                        result.isSuccess = false;
                        result.message = (String)payload.get('return');
                    }
                    //Create Application Log Entry (Success)
                    ApplicationLogActivation__c logAPISetting = ApplicationLogActivation__c.getOrgDefaults();
                    if (logAPISetting.WS_Success_Log__c){
                        ApplicationLogUtils.createSuccessIntegrationLogUtils('WSCalloutUpdateContactToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res);
                    }
                } else {
                    //Create Application Log Entry (Fail)
                    ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutUpdateContactToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, 'Fail');
                }
            } else {
                // result.code = '' + apicall.getResponseCode();
                String message = apicall.getResponseStatus();
                System.debug(message);

                //Create Application Log Entry (Fail)
                ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutUpdateContactToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, 'Fail');
            }
        } catch(Exception ex) {
            // result.code = '1000-Invalid Format';
            String message = !String.isBlank(res)? res : ex.getMessage();
            System.debug('message : ' + message);

            //Create Application Log Entry (Fail)
            system.debug('ex: ' + String.valueOf(ex));
            system.debug('res: ' + String.valueOf(res));
            
            ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutUpdateContactToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, ex.getMessage());
        }
        result.isSuccess = isSuccess;
        return result;
    }

    public class response extends Abstract_RestResponseModel{
        // @AuraEnabled
        // public Boolean isSuccess;
        // @AuraEnabled
        // public String message;
        @AuraEnabled
        public responsePayload payload;
    }

    public class responsePayload {
        @AuraEnabled
        public String contactId;
    }

    public class ContactData{
        @AuraEnabled public String contact_id;
        @AuraEnabled public String customer_code;
        @AuraEnabled public String title;
        @AuraEnabled public String firstname;
        @AuraEnabled public String lastname;
        @AuraEnabled public String department;
        @AuraEnabled public String function;
        @AuraEnabled public String email;
        //@AuraEnabled public String street;
        //@AuraEnabled public String city;
        @AuraEnabled public String langu;
        @AuraEnabled public String mobile;
    }
}
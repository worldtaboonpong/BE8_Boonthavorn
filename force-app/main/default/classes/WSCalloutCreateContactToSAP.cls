public without sharing class WSCalloutCreateContactToSAP {
    // public static response callout(List<Contact> listContact){
    //     response result = new response();
    //     String body = getRequestBody(listContact);
    //     result = responseRequest(body);
    //     return result;
    // }

    // public static String getRequestBody(List<Contact> listContact){

    //     ContactRequestModel contactReqModel = new ContactRequestModel();
    //     List<ContactData> listContactData = new List<ContactData>();

    //     for(Contact contact : listContact){
    //         ContactData contactData = new ContactData();
    //         contactData.Title = contact.Title__c;
    //         contactData.First_Name = contact.Name;
    //         contactData.Last_Name = '';
    //         contactData.Mobile = contact.MobilePhone;
    //         listContactData.add(contactData);
    //     }
    //     contactReqModel.data = listContactData;

    //     String requestBodyJSONString = JSON.serialize(contactReqModel, true);
    //     system.debug('Callout Create Contact To SAP API Request Body: ' + requestBodyJSONString);
    //     return requestBodyJSONString;
    // }

    public static response callout(Contact con){
        response result = new response();
        String body = getRequestBody(con);
        result = responseRequest(body);
        return result;
    }

    public static String getRequestBody(Contact con){

        ContactData contactData = new ContactData();
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
        //contactData.street = con.Street__c;
        //contactData.city = con.Province__c;
        contactData.langu = 'TH';
        contactData.mobile = con.MobilePhone;

        String requestBodyJSONString = JSON.serialize(contactData, true);
        system.debug('Callout Create Contact To SAP API Request Body: ' + requestBodyJSONString);
        return requestBodyJSONString;
    }

    public static response responseRequest(String body){
        response result = new response();
        String res = '';
        String message;
        String customerId;
        Map<String, Object> mapResponse;
        Map<String, Object> payload;
        List<Object> listPayload;
        Boolean isSuccess = false;
        try {
            WSAPICallout apicall = new WSAPICallout('Callout_Create_Contact_To_SAP');
            apicall.setRequestBody(body, '');
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
                    // listPayload = (List<Object>)mapResponse.get('payload');
                    // System.debug('listPayload : ' + listPayload);
                    // result.payload = new List<responsePayload>();
                    // for (Object itemObj : listPayload) {
                    //     payload = (Map<String, Object>) itemObj;
                    //     responsePayload detail = new responsePayload();
                    //     detail.contactId = (String)payload.get('contactId');
                    //     result.payload.add(detail);
                    // }
                    payload = (Map<String, Object>) mapResponse.get('payload');
                    result.payload = new responsePayload();
                    result.payload.contactId = (String)payload.get('contact_id');
                    if(payload.get('status') == 'E') {
                        result.isSuccess = false;
                        result.message = (String)payload.get('return');
                    }
                    
                    ApplicationLogUtils.createSuccessIntegrationLogUtils('WSCalloutCreateContactToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res);
                } else {
                    //Create Application Log Entry (Fail)
                    ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutCreateContactToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, 'Fail');
                }
            } else {
                // result.code = '' + apicall.getResponseCode();
                String error = apicall.getResponseStatus();
                System.debug(error);

                //Create Application Log Entry (Fail)
                ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutCreateContactToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, 'Fail');
            }
        } catch(Exception ex) {
            // result.code = '1000-Invalid Format';
            String error = !String.isBlank(res)? res : ex.getMessage();
            System.debug('message : ' + error);

            //Create Application Log Entry (Fail)
            system.debug('ex: ' + String.valueOf(ex));
            system.debug('res: ' + String.valueOf(res));

            ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutCreateContactToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, ex.getMessage());
            
        }
        result.isSuccess = isSuccess;
        result.message = message;
        return result;
    }

    public class response extends Abstract_RestResponseModel{
        // @AuraEnabled
        // public Boolean isSuccess;
        // @AuraEnabled
        // public String message;
        @AuraEnabled
        public responsePayload payload;
        // public List<responsePayload> payload;
    }

    public class responsePayload {
        @AuraEnabled
        public String contactId;
    }

    public class ContactRequestModel {
        @AuraEnabled
        public List<ContactData> data;
    }

    public class ContactData{
        public String customer_code;
        public String title;
        public String firstname;
        public String lastname;
        public String department;
        public String function;
        public String email;
        // public String street;
        // public String city;
        public String langu;
        public String mobile;
    }

}
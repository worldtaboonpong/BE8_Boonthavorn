public without sharing class WSCalloutCreateAccountToSAP {
    @AuraEnabled(cacheable=true)
    public static response callout(Account acc){
        response result = new response();
        String body = getRequestBody(acc);
        result = responseRequest(body);
        return result;
    }

    public static String getRequestBody(Account accData){

        Map<String, Object> inputMap = new Map<String, Object>();
        String vat = getVat();

        // AccountData accountData = new AccountData();
        inputMap.put('flag', 'OT');
        inputMap.put('customer_code', '');
        inputMap.put('tax_branch', accData.Tax_Branch__c != null ? accData.Tax_Branch__c : '00000');
        inputMap.put('tax_no', accData.Tax_Number__c != null ? accData.Tax_Number__c : '');
        inputMap.put('currency', accData.Currency__c != null ? accData.Currency__c : 'THB');
        //inputMap.put('title', accData.Title__c != null ? accData.Title__c : '');
        inputMap.put('title', accData.Salutation_TH__c != null ? accData.Salutation_TH__c : '');
        inputMap.put('name', accData.Name != null ? accData.Name : '');
        inputMap.put('address', accData.Address__c != null ? accData.Address__c : '');
        inputMap.put('road', accData.Street__c != null ? accData.Street__c : '');
        inputMap.put('subdistrict', accData.Subdistrict__c != null ? accData.Subdistrict__c : '');
        inputMap.put('district', accData.District__c != null ? accData.District__c : '');
        inputMap.put('city', accData.Province__c != null ? accData.Province__c : '');
        inputMap.put('postcode', accData.Zipcode__c != null ? accData.Zipcode__c : '');
        inputMap.put('country', accData.Country_Code__c != null ? accData.Country_Code__c : 'TH');
        inputMap.put('telephone', accData.Phone != null ? accData.Phone : '');
        inputMap.put('telephone_ext', accData.Phone_Ext__c != null ? accData.Phone_Ext__c : '');
        inputMap.put('mobile', accData.Mobile_Phone__c != null ? accData.Mobile_Phone__c : '');
        inputMap.put('fax', accData.Fax != null ? accData.Fax : '');
        inputMap.put('fax_ext', accData.Fax_Ext__c != null ? accData.Fax_Ext__c : '');
        inputMap.put('email', accData.Email__c != null ? accData.Email__c : '');
        inputMap.put('passport', accData.Passport__c != null ? accData.Passport__c : '');
        inputMap.put('lat', accData.BillingLatitude != null ? accData.BillingLatitude : 0);
        inputMap.put('lng', accData.BillingLongitude != null ? accData.BillingLongitude : 0);
        inputMap.put('map_zoom', '');
        inputMap.put('searchterm', '');
        inputMap.put('customergroup', accData.Customer_Group__c != null ? accData.Customer_Group__c : '16');
        inputMap.put('remark', accData.Remark__c != null ? accData.Remark__c : '');
        inputMap.put('vat', vat != null ? vat : '');
        inputMap.put('tr_zone', accData.TR_Zone__c != null ? accData.TR_Zone__c : 'B202');

        String requestBodyJSONString = '['+JSON.serialize(inputMap, true)+']';
        system.debug('Callout Create Account To SAP API Request Body: ' + requestBodyJSONString);
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
            WSAPICallout apicall = new WSAPICallout('Callout_Create_Account_To_SAP');
            apicall.setRequestBody(body, '');
            apicall.callout();
            
            res = apicall.getResponseBody();
            if(!String.isBlank(res)){
                mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res);
                System.debug('API'+res);
                System.debug('Parsed JSON'+mapResponse);
                isSuccess = (Boolean)mapResponse.get('isSuccess');
                message = (String)mapResponse.get('message');   
                listPayload = (List<Object>)mapResponse.get('payload');
                System.debug('listPayload : ' + listPayload);
                for (Object itemObj : listPayload) {
                    payload = (Map<String, Object>) itemObj;
                }
                System.debug('payload : ' + payload);
                if(payload.containsKey('return_cust_no')) customerId = (String)payload.get('return_cust_no');
                System.debug('isSuccess : ' + isSuccess); 
                if(isSuccess) {
                    //Create Application Log Entry (Success)
                    ApplicationLogActivation__c logAPISetting = ApplicationLogActivation__c.getOrgDefaults();
                    if (logAPISetting.WS_Success_Log__c){
                        ApplicationLogUtils.createSuccessIntegrationLogUtils('WSCalloutCreateAccountToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res);
                    }
                } else {
                    //Create Application Log Entry (Fail)
                    ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutCreateAccountToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, 'Fail');
                }
            } else {
                // result.code = '' + apicall.getResponseCode();
                String error = apicall.getResponseStatus();
                System.debug(error);

                //Create Application Log Entry (Fail)
                ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutCreateAccountToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, 'Fail');
            }
        } catch(Exception ex) {
            // result.code = '1000-Invalid Format';
            String error = !String.isBlank(res)? res : ex.getMessage();
            System.debug('message : ' + error);

            //Create Application Log Entry (Fail)
            system.debug('ex: ' + String.valueOf(ex));
            system.debug('res: ' + String.valueOf(res));

            ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutCreateAccountToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, ex.getMessage());
        }
        result.isSuccess = isSuccess;
        result.message = message;
        result.customerId = customerId;
        return result;
    }

    public class response extends Abstract_RestResponseModel{
        // @AuraEnabled
        // public Boolean isSuccess;
        // @AuraEnabled
        // public String message;
        @AuraEnabled
        public String customerId;
    }

    private static String getVat() {
        Decimal vat = OpportunitySetting__c.getInstance().Tax__c;
        return String.valueOf(vat);
    }

    public class AccountRequestModel {
        // @AuraEnabled
        // public List<AccountData> data;
    }

    // public class AccountData{
    //     public String flag;
    //     public String customer_code;
    //     public String tax_branch;
    //     public String tax_no;
    //     public String currency;
    //     public String title;
    //     public String name;
    //     public String address;
    //     public String road;
    //     public String subdistrict;
    //     public String district;
    //     public String city;
    //     public String postcode;
    //     public String country;
    //     public String telephone;
    //     public String telephone_ext;
    //     public String mobile;
    //     public String fax;
    //     public String fax_ext;
    //     public String email;
    //     public String passport;
    //     public Decimal lat;
    //     public Decimal lng;
    //     public String map_zoom;
    //     public String searchterm;
    //     public String customergroup;
    //     public String remark;
    //     public String vat;
    //     public String tr_zone;
    // }
}
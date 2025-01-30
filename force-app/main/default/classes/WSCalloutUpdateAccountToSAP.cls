public without sharing class WSCalloutUpdateAccountToSAP {
    @AuraEnabled(cacheable=true)
    public static response callout(Account acc, Account accDataDefaultValue, String cid){
        response result = new response();
        String body = getRequestBody(acc, accDataDefaultValue, cid);
        result = responseRequest(body);
        return result;
    }

    public static String getRequestBody(Account accData, Account accDataDefaultValue, String cid){

        CustomerData customerData = new CustomerData();
        customerData.prefix = accData.Title__c != null ? accData.Title__c : '';
        customerData.name = accData.Name != null ? accData.Name : '';
        customerData.searchterm = '';
        customerData.address = accData.Address__c != null ? accData.Address__c : ''; 
        customerData.street = accData.Street__c != null ? accData.Street__c : '';
        customerData.subdistrict = accData.Subdistrict__c != null ? accData.Subdistrict__c : '';
        customerData.district = accData.District__c != null ? accData.District__c : '';
        customerData.province = accData.Province__c != null ? accData.Province__c : '';
        customerData.zipcode = accData.Zipcode__c != null ? accData.Zipcode__c : '';
        customerData.transport_zone = accDataDefaultValue.TR_Zone__c != null ? accDataDefaultValue.TR_Zone__c : 'B202';
        customerData.country_code = accDataDefaultValue.Country_Code__c != null ? accDataDefaultValue.Country_Code__c : 'TH';
        customerData.mobs = accData.Mobile_Phone__c != null ? new List<String>{accData.Mobile_Phone__c} : new List<String>();
        customerData.tels = accData.Phone != null ? new List<String>{accData.Phone} : new List<String>();
        customerData.fax = accData.Fax != null ? accData.Fax : '';

        AccountData accountData = new AccountData();
        accountData.cid = cid;
        accountData.cust_code = accDataDefaultValue.Customer_ID__c != null ? accDataDefaultValue.Customer_ID__c : '';
        accountData.cust_name = new List<CustomerData>{customerData};
        accountData.passport_number = '';
        accountData.email = accData.Email__c != null ? accData.Email__c : '';
        accountData.lattitude = accData.BillingLatitude != null ? String.valueOf(accData.BillingLatitude) : '0';
        accountData.longtitude = accData.BillingLongitude != null ? String.valueOf(accData.BillingLongitude) : '0';
        accountData.map_type = '';
        accountData.map_zoom = '';
        accountData.tax_number = accData.Tax_Number__c != null ? accData.Tax_Number__c : '';
        accountData.tax_branch = accDataDefaultValue.Tax_Branch__c != null ? accDataDefaultValue.Tax_Branch__c : '00000';
        accountData.customer_type = accDataDefaultValue.Customer_Type__c != null ? accDataDefaultValue.Customer_Type__c : 'C005'; 
        accountData.customer_group = accDataDefaultValue.Customer_Group__c != null ? accDataDefaultValue.Customer_Group__c : '16';
        accountData.sales_district = '';
        accountData.ref_customer_code = '';
        accountData.remark = accData.Remark__c;
        accountData.ref_code = accData.Id;
        accountData.ref_source = accDataDefaultValue.Ref_Source__c != null ? accDataDefaultValue.Ref_Source__c : 'Salesforce';

        String requestBodyJSONString = JSON.serialize(accountData, true);
        system.debug('Callout Update Account To SAP API Request Body: ' + requestBodyJSONString);
        return requestBodyJSONString;
    }

    public static response responseRequest(String body){
        response result = new response();
        String res = '';
        String message;
        Map<String, Object> mapResponse;
        Boolean isSuccess = false;
        try {
            WSAPICallout apicall = new WSAPICallout('Callout_Update_Account_To_SAP');
            AccountData data = (AccountData)JSON.deserialize(body, AccountData.class);
            if(data.cust_code != null) apicall.setCustCode(data.cust_code);
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
                    //Create Application Log Entry (Success)
                    ApplicationLogActivation__c logAPISetting = ApplicationLogActivation__c.getOrgDefaults();
                    if (logAPISetting.WS_Success_Log__c){
                        ApplicationLogUtils.createSuccessIntegrationLogUtils('WSCalloutUpdateAccountToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res);
                    }
                } else {
                    //Create Application Log Entry (Fail)
                    ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutUpdateAccountToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, 'Fail');
                }
            } else {
                // result.code = '' + apicall.getResponseCode();
                String error = apicall.getResponseStatus();
                message = error;
                System.debug(error);

                //Create Application Log Entry (Fail)
                ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutUpdateAccountToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, 'Fail');
            }
        } catch(Exception ex) {
            // result.code = '1000-Invalid Format';
            String error = !String.isBlank(res)? res : ex.getMessage();
            message = 'Invalid Format';
            System.debug('message : ' + error);

            //Create Application Log Entry (Fail)
            system.debug('ex: ' + String.valueOf(ex));
            system.debug('res: ' + String.valueOf(res));

            ApplicationLogUtils.createFailIntegrationLogUtils('WSCalloutUpdateAccountToSAP', Constant.APP_LOG_OUTBOUND_TYPE, body, res, ex.getMessage());
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
    }

    public class AccountRequestModel {
        @AuraEnabled
        public List<AccountData> data;
    }

    public class AccountData{
        public String cid;
        public String cust_code;
        public List<CustomerData> cust_name;
        public String passport_number;
        public String email;
        public String lattitude;
        public String longtitude;
        public String map_type;
        public String map_zoom;
        public String tax_number;
        public String tax_branch;
        public String customer_type;
        public String customer_group;
        public String sales_district;
        public String ref_customer_code;
        public String remark;
        public String ref_code;
        public String ref_source;
    }

    public class CustomerData {
        public String prefix;
        public String name;
        public String searchterm;
        public String address;
        public String street;
        public String subdistrict;
        public String district;
        public String province;
        public String zipcode;
        public String transport_zone;
        public String country_code;
        public List<String> mobs;
        public List<String> tels;
        public String fax;
    }
}
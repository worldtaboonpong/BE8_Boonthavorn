public without sharing class UpdateAccountToSAPController {

    @AuraEnabled
    public static WSCalloutGetAccountDetailFromSAP.response getcid( String accId){  
        WSCalloutGetAccountDetailFromSAP.response res = new WSCalloutGetAccountDetailFromSAP.response();
        try{
            Account accDataDefaultValue = [SELECT Id, TR_Zone__c, Country_Code__c, CID__c, Customer_ID__c, Tax_Branch__c, Customer_Type__c, Customer_Group__c, Ref_Source__c FROM Account WHERE Id = :accId];
            if(accDataDefaultValue.CID__c == null) {
                WSCalloutGetAccountDetailFromSAP.response resGetDetail = WSCalloutGetAccountDetailFromSAP.callout(accDataDefaultValue);
                System.debug('resGetDetail : ' + resGetDetail);
                res = resGetDetail;
                accDataDefaultValue.CID__c = res.cid;
                update(accDataDefaultValue);
            } else {
                res.isSuccess = true;
                res.cid = accDataDefaultValue.CID__c;
            }
        } catch(Exception e){
            // return 'Error';
            System.debug(e);
            System.debug('Stack trace: ' + e.getStackTraceString());    
            res.isSuccess = false;
            res.message = 'API Callout Error: Service timeout';
        }  
        return res;
    }

    @AuraEnabled
    public static SyncResponse calloutAndUpdateAccount(Account acc, String accId, String cid){  
        try{
            System.debug('cid : ' + cid);
            Account accDataDefaultValue = [SELECT Id, TR_Zone__c, Country_Code__c, CID__c, Customer_ID__c, Tax_Branch__c, Customer_Type__c, Customer_Group__c, Ref_Source__c FROM Account WHERE Id = :accId];
            acc.Id = accId;
            WSCalloutUpdateAccountToSAP.response res = WSCalloutUpdateAccountToSAP.callout(acc, accDataDefaultValue, cid);
            if(res.isSuccess){
                Database.SaveResult SR = Database.update(acc);
                if(!SR.isSuccess()){
                    for(Database.Error error : SR.getErrors()){
                        return new SyncResponse('Error',null,'Update Error: ' + error.getMessage());
                    }
                }    
            }else{
                String message = 'API Callout Error: ';
                String errorMessage = res.message != null ? res.message : String.valueOf(res);
                return new SyncResponse('Error',null, message + errorMessage);
            }
            return new SyncResponse('Success',new List<Account>{acc},'');
        }catch(Exception e){
            // return 'Error';
            System.debug(e);
            System.debug('Stack trace: ' + e.getStackTraceString());    
            return new SyncResponse('Error',null,'API Callout Error: Service timeout');
        }   
    }

    public class SyncResponse{

        @AuraEnabled public String status;
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String remark;
        
        public SyncResponse (){}

        public SyncResponse(String inputStatus, List<Object> inputData, String inputRemark){
            status = inputStatus;
            data = inputData;
            remark = inputRemark;
        }
    }

}
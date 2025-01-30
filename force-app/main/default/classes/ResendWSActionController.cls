public with sharing class ResendWSActionController {
    @AuraEnabled
    public static String resend(String logID){
        Abstract_RestResponseModel res;
        Application_Log__c log = [SELECT Id, Webservice_Name__c, Webservice_Body__c FROM Application_Log__c WHERE Id =: logID];
        if(log.Webservice_Name__c == 'WSCalloutCreateAccountToSAP') {
            res = WSCalloutCreateAccountToSAP.responseRequest(log.Webservice_Body__c);
        } else if(log.Webservice_Name__c == 'WSCalloutCreateContactToSAP') {
            res = WSCalloutCreateContactToSAP.responseRequest(log.Webservice_Body__c);
        } else if(log.Webservice_Name__c == 'WSCalloutUpdateAccountToSAP') {
            res = WSCalloutUpdateAccountToSAP.responseRequest(log.Webservice_Body__c);
        } else if(log.Webservice_Name__c == 'WSCalloutUpdateContactToSAP') {
            res = WSCalloutUpdateContactToSAP.responseRequest(log.Webservice_Body__c);
        }

        System.debug(res);
        System.debug(res.isSuccess);
        if(res.isSuccess) {
            return 'Success';
        }
        return null;
    }
}
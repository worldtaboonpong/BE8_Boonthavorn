global with sharing class ContractExpireNotificationBatch implements Database.Batchable<sObject>, Database.Stateful  {
    private Date todayDates = Date.today();
    private String status = 'Activated';
    private List<Contract__c> contractSendingList{get;set;}
    public ContractExpireNotificationBatch() {

    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryString = 'SELECT Id, Opportunity_Name__c, Contract_Start_Date__c, Contract_End_Date__c,Rental_Year__c, OwnerId,Will_expire_in__c FROM Contract__c WHERE Rental_Year__c > 0 AND Status__c =:status';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Contract__c> contractList){

        System.debug(contractList);
        List<Id> ownerContractList = new List<Id>();
        List<Id> oppContractList = new List<Id>();
        contractSendingList = new List<Contract__c>();
        String emailTemplateDeveloperName = 'Contract_A_Contract_Expiration_Reminder_Email';
        List<EmailTemplate> emailTemplateList  = [SELECT Id, Body, HtmlValue, Subject, BrandTemplateId from EmailTemplate where DeveloperName =: emailTemplateDeveloperName];

        for(Contract__c rec: contractList){
            if(rec.Rental_Year__c == 1 && rec.Will_expire_in__c == 60){
                contractSendingList.add(rec);
                ownerContractList.add(rec.OwnerId);
                oppContractList.add(rec.Opportunity_Name__c);
            }else if(rec.Rental_Year__c == 2 && rec.Will_expire_in__c == 90){
                contractSendingList.add(rec);
                ownerContractList.add(rec.OwnerId);
                oppContractList.add(rec.Opportunity_Name__c);
            }else if(rec.Rental_Year__c == 3 && rec.Will_expire_in__c == 120){
                contractSendingList.add(rec);
                ownerContractList.add(rec.OwnerId);
                oppContractList.add(rec.Opportunity_Name__c);
            }else if(rec.Rental_Year__c > 3 && rec.Will_expire_in__c == 365){
                contractSendingList.add(rec);
                ownerContractList.add(rec.OwnerId);
                oppContractList.add(rec.Opportunity_Name__c);
            }
        }

        // for(Contract__c rec: contractList){
        //     ownerContractList.add(rec.OwnerId);
        //     oppContractList.add(rec.Opportunity_Name__c);
        // }

        // System.debug(ownerContractList);

        //get contact email
        Map<Id,Opportunity> oppList = New Map<Id,Opportunity>();
        for(Opportunity rec: [SELECT Id, Name,Contact_Name__c, Contact_Name__r.email FROM Opportunity WHERE Id IN :oppContractList]){
            if(!oppList.containsKey(rec.Id)){
                oppList.put(rec.Id, rec);
            }
        }
        // System.debug(oppList.keySet());
        // System.debug(oppList.values());

        //get owner emails
        Map<Id,User> userList = New Map<Id,User>();
        for(User rec: [SELECT Id, Email, Name FROM User WHERE Id IN :ownerContractList]){
            if(!userList.containsKey(rec.Id)){
                userList.put(rec.Id, rec);
            }
        }
        // System.debug(userList.keySet());
        // System.debug(userList.values());

        for(Contract__c eachRec:contractSendingList){
            if((oppList.get(eachRec.Opportunity_Name__c).Contact_Name__r.email != NULL) && (userList.get(eachRec.OwnerId).Email != NULL)){
                List<String> addressList = new List<String>{oppList.get(eachRec.Opportunity_Name__c).Contact_Name__r.email};
                List<String> ccList = new List<String>{userList.get(eachRec.OwnerId).Email};

                EmailUtility.sendEmail(emailTemplateList.get(0),addressList,ccList,null,eachRec.Id);
            }
        }


        // List<User> userList = [Select Id, Email, Name FROM User Where Id IN :ownerContractList];


        // List<Id> ownerContractList = new List<Id>();
        // List<Id> oppContractList = new List<Id>();
        // for(Contract__c rec :contractSendingList){
        //     ownerContractList.add(rec.OwnerId);
        //     oppContractList.add(rec.Opportunity_Name__c);
        // }
        
        
        // Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        // mail.setTargetObjectIds(contactids);
        // mail.setTemplateId('00X90000000QHUD');
        // Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });


    }
    global void finish(Database.BatchableContext BC) {
        
    }
}
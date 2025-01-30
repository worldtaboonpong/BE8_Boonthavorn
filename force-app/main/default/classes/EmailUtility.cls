public without sharing class EmailUtility {

    public static List<EmailTemplate> getEmailTemplate(String eachEmailDeveloperName){
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        emailTemplateList = [SELECT Id, Body, HtmlValue, Subject, BrandTemplateId from EmailTemplate where DeveloperName = : eachEmailDeveloperName];
        return emailTemplateList;
    }

    public static void sendEmail(EmailTemplate emailTemplate, List<String> addressList,List<String> ccList, Id whoId,Id whatId) {
        System.debug('sendEmail ');
        System.debug(emailTemplate.Id);
        System.debug(whoId);
        System.debug(whatId);
        System.debug(ccList);
        System.debug(addressList);

        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, whoId,whatId);
        mail.setTemplateId(emailTemplate.Id);
        mail.setToAddresses(addressList);
        mail.setCcAddresses(ccList);
        // mail.setTargetObjectId(whatId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setSaveAsActivity(false);
        sendAllEmailMessage(new List<Messaging.SingleEmailMessage>{mail});
    }

    public static void sendAllEmailMessage(List<Messaging.SingleEmailMessage> allmsg ){
        if(allmsg.isEmpty()) return;
        Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg,false);
        for(Messaging.SendEmailResult result : results) {
            if(!result.isSuccess()) {}
        }
    }
}
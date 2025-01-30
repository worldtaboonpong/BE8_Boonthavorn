global class sendEmailClosedWONOpp {
    @InvocableMethod(label='Send Email for Closed WON')  
    public static List<Response> sendClosedWONEmail(List<Id> oppIds) {
        List<Response> output = new List<Response>();

        if(oppIds.size() > 0) {
            Id oppId = oppIds.get(0);
            Opportunity opp = [SELECT Id, ContactId, Contact_Name__c, Building__c, Building__r.Email_of_Accountant__c, Rental_Type__c, OwnerId, Owner.Email FROM Opportunity WHERE ID =: oppId LIMIT 1];
            //Contact con = [SELECT Id FROM Contact WHERE Id =: opp.Contact_Name__c limit 1];
            Contact con = [SELECT Id FROM Contact WHERE Name = 'Dummy' limit 1];
            String templateName = 'Invoice_Notify_Accounting';
            if(opp.Rental_Type__c == 'Billboard_Rental') templateName = 'Invoice_Notify_Accounting_Billboard';
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: templateName LIMIT 1];
            
            Messaging.EmailFileAttachment efa;
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :oppId];
            if(!cdlList.isEmpty()) {
                List<ContentVersion> cvList = [SELECT Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId = :cdlList[0].ContentDocumentId AND IsLatest = true];
                String filename = cvList[0].Title+'.'+cvList[0].FileExtension;
                Blob fileData = cvList[0].VersionData;
                
                efa = new Messaging.EmailFileAttachment();
                efa.setFileName(filename);
                efa.setBody(fileData); 
            }

            //String[] sendingTo = new String[]{'yingyong.t@beryl8.com', opp.Building__r.Email_of_Accountant__c};
            String[] sendingTo = new String[]{opp.Building__r.Email_of_Accountant__c, opp.Owner.Email};
            
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId(template.Id);
            msg.setTargetObjectId(con.Id); 
            //msg.setSaveAsActivity(false);
            msg.setWhatId(oppId); 
            msg.setToAddresses(sendingTo);
            msg.setTreatTargetObjectAsRecipient(false);

            if(efa != null) msg.setFileAttachments(new Messaging.EmailFileattachment[]{efa});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg }, false);
        }

        return output;
    }

    public class Response {
        @InvocableVariable
        public String oppId;
        @InvocableVariable
        public Boolean isSuccess;
    }
}
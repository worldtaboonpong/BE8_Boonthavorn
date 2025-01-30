@isTest
private class EmailUtility_Test {
    
    @TestSetup
    static void setupData(){
        Folder existingFolder = [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1];

        EmailTemplate emailTemplate = new EmailTemplate (developerName = 'testEmail', FolderId = existingFolder.Id, TemplateType= 'Text', Name = 'test');
        insert emailTemplate;
    }

    @isTest
    public static void testSendEmail() {
        Units__c unit = new Units__c(
            Usage_Type__c = 'Office Rental'
        ); 
        insert(unit);

        Test.startTest();
        List<EmailTemplate> emailTemplateList  = EmailUtility.getEmailTemplate('testEmail');
        EmailUtility.sendEmail(emailTemplateList.get(0), new List<String>{'spwg@beryl8.com'}, new List<String>(), null, unit.Id);
        Test.stopTest();
    }
}
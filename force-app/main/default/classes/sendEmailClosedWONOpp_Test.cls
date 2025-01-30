@isTest
public with sharing class sendEmailClosedWONOpp_Test {
    @TestSetup
    static void makeData(){
        Contact con = new Contact();
        con.LastName = 'Dummy';
        con.Email = 'test@gmail.com';
        insert(con);

        Account acc = new Account(Name = 'Test');
        acc.Address__c = 'Address';
        acc.Subdistrict__c = 'Subdistrict';
        acc.District__c = 'District';
        acc.Province__c = 'Province';
        acc.ZipCode__c = 'ZipCode';
        acc.Mobile_Phone__c = '091111111';
        insert(acc);

        Opportunity opp = new Opportunity(Name = 'Test');
        opp.AccountId = acc.Id;
        opp.StageName = 'Quotation Preparation';
        opp.CloseDate = System.today();
        opp.OpportunityGrading__c = '[{}]';
        opp.OpportunityLeaseholdFloor__c = '[{}]';
        opp.DepositMeasurement__c = '[{}]';
        insert(opp);

        ContentVersion contentVersion = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
        insert(contentVersion); 

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = opp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.visibility = 'AllUsers';
        insert(cdl);

        Units__c units = new Units__c(
            //Building__c = building.Id,
            //Floor__c = myFloor.Id,
            Usage_Type__c = 'Office Rental'
        ); 
        insert(units);

        OpportunityLineItem__c oppLine = new OpportunityLineItem__c();
        oppLine.Opportunity__c = opp.Id;
        oppLine.Unit__c = units.Id;
        insert(oppLine);

        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c();
        oppPeriod.Opportunity__c = opp.Id;
        insert(oppPeriod);

        OpportunityDepositExpense__c oppExp = new OpportunityDepositExpense__c();
        oppExp.Opportunity__c = opp.Id;
        oppExp.Type__c = 'Security Deposit';
        oppExp.TypeGroup__c = 'Deposit';
        insert(oppExp);

        OpportunityPrice__c oppPrice = new OpportunityPrice__c();
        oppPrice.Opportunity__c = opp.Id;
        oppPrice.From__c = System.today();
        oppPrice.Price__c = 0;
        oppPrice.OpportunityPeriod__c = oppPeriod.Id;
        oppPrice.OpportunityDepositExpense__c = oppExp.Id;
        insert(oppPrice);

    }

    @isTest
    public static void test_sendClosedWONEmail() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<sendEmailClosedWONOpp.Response> res = sendEmailClosedWONOpp.sendClosedWONEmail(new List<Id>{opp.Id});
        Test.stopTest();
    }
}
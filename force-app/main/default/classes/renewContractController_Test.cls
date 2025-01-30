@isTest
public with sharing class renewContractController_Test {
    @TestSetup
    static void makeData(){
        MockUpDataFor_Test.generateOppSetting();

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

        ContractGradingModel.Data conGrade = new ContractGradingModel.Data();
        conGrade.Id = 'xx';
        conGrade.GradingPeriodForm = System.today();
        conGrade.GradingPeriodTo = System.today().addYears(1);
        ContractLeaseholdFloorModel.Data conLease = new ContractLeaseholdFloorModel.Data();
        conLease.Id = 'xx';
        ContractDepositMeasurementModel.Data conDepM = new ContractDepositMeasurementModel.Data();
        conDepM.Id = 'xx';

        List<Contract__c> listCon = new List<Contract__c>();
        Contract__c contract = new Contract__c(Name = 'Test', Status__c = 'Activated', Contract_Start_Date__c = System.today(), Contract_End_Date__c = System.today().addYears(1));
        contract.Actual_of_Billing_Rent_Service__c = contract.Actual_of_Billing_Insurance__c = contract.Actual_of_Decorate_the_Space__c = contract.Actual_of_Delivery_the_Area__c = System.today();
        contract.Actual_of_Design_Guideline__c = contract.Actual_of_Signed_Contract__c = contract.Actual_of_Shop_Open__c = System.today();
        contract.Rental_Year__c = 1;
        contract.Rental_Period_Month__c = contract.Rental_day__c = 0;
        contract.Opportunity_Name__c = opp.Id;
        contract.ContractGrading__c = ContractGradingModel.toString(new List<ContractGradingModel.Data>{conGrade});
        System.debug('ContractGrading: '+contract.ContractGrading__c);
        contract.ContractLeaseholdFloor__c = ContractLeaseholdFloorModel.toString(new List<ContractLeaseholdFloorModel.Data>{conLease});
        System.debug('ContractLeaseholdFloor: '+contract.ContractLeaseholdFloor__c);
        contract.DepositMeasurement__c = ContractDepositMeasurementModel.toString(new List<ContractDepositMeasurementModel.Data>{conDepM});
        System.debug('DepositMeasurement: '+contract.DepositMeasurement__c);
        listCon.add(contract);
        insert(listCon);

        List<ContractLineItem__c> listConLine = new List<ContractLineItem__c>();
        ContractLineItem__c conLine = new ContractLineItem__c(Contract__c = contract.Id, Unit__c = units.Id);
        listConLine.add(conLine);
        insert(listConLine);

        ContractPeriod__c conPeriod = new ContractPeriod__c(Contract__c = contract.Id, PeriodFrom__c = System.today(), PeriodTo__c = System.today());
        insert(conPeriod);

        ContractPrice__c conPrice = new ContractPrice__c(Contract__c = contract.Id, From__c = System.today(), To__c = System.today(), Price__c = 0);
        insert(conPrice);

        ContractDepositExpense__c conDep = new ContractDepositExpense__c(Contract__c = contract.Id, TypeGroup__c = 'Deposit');
        insert(conDep);
    }

    @isTest
    public static void test_renew() {
        Contract__c con = [SELECT Id FROM Contract__c WHERE Name = 'Test' LIMIT 1];
        Test.startTest();
        renewContractController.Response res = renewContractController.renew(con.Id);
        Test.stopTest();
    }
}
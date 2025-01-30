@isTest
public with sharing class ContractExpireNotificationBatch_Test {
    @isTest
    public static void test_execute() {
        Contact contract = new Contact();
        contract.LastName = 'Dummy';
        contract.Email = 'test@gmail.com';
        insert(contract);

        Opportunity opp = new Opportunity(Name = 'Test');
        opp.StageName = 'Quotation Preparation';
        opp.CloseDate = System.today();
        opp.Contact_Name__c = contract.Id;
        insert(opp);

        Date today = System.today();
        List<Contract__c> listCon = new List<Contract__c>();
        Contract__c con = new Contract__c(Name = 'Test', Status__c = 'Activated', Contract_Start_Date__c = today.addYears(-1).addDays(60), Contract_End_Date__c = today.addDays(60));
        con.Actual_of_Billing_Rent_Service__c = con.Actual_of_Billing_Insurance__c = con.Actual_of_Decorate_the_Space__c = con.Actual_of_Delivery_the_Area__c = today;
        con.Actual_of_Design_Guideline__c = con.Actual_of_Signed_Contract__c = con.Actual_of_Shop_Open__c = today;
        con.Rental_Year__c = 1;
        con.Opportunity_Name__c = opp.Id;
        listCon.add(con);

        Contract__c con2 = new Contract__c(Name = 'Test', Status__c = 'Activated', Contract_Start_Date__c = today.addYears(-2).addDays(90), Contract_End_Date__c = today.addDays(90));
        con2.Actual_of_Billing_Rent_Service__c = con2.Actual_of_Billing_Insurance__c = con2.Actual_of_Decorate_the_Space__c = con2.Actual_of_Delivery_the_Area__c = today;
        con2.Actual_of_Design_Guideline__c = con2.Actual_of_Signed_Contract__c = con2.Actual_of_Shop_Open__c = today;
        con2.Rental_Year__c = 2;
        con2.Opportunity_Name__c = opp.Id;
        listCon.add(con2);

        Contract__c con3 = new Contract__c(Name = 'Test', Status__c = 'Activated', Contract_Start_Date__c = today.addYears(-3).addDays(120), Contract_End_Date__c = today.addDays(120));
        con3.Actual_of_Billing_Rent_Service__c = con3.Actual_of_Billing_Insurance__c = con3.Actual_of_Decorate_the_Space__c = con3.Actual_of_Delivery_the_Area__c = today;
        con3.Actual_of_Design_Guideline__c = con3.Actual_of_Signed_Contract__c = con3.Actual_of_Shop_Open__c = today;
        con3.Rental_Year__c = 3;
        con3.Opportunity_Name__c = opp.Id;
        listCon.add(con3);

        Contract__c con4 = new Contract__c(Name = 'Test', Status__c = 'Activated', Contract_Start_Date__c = today.addYears(-3), Contract_End_Date__c = today.addYears(1));
        con4.Actual_of_Billing_Rent_Service__c = con4.Actual_of_Billing_Insurance__c = con4.Actual_of_Decorate_the_Space__c = con4.Actual_of_Delivery_the_Area__c = today;
        con4.Actual_of_Design_Guideline__c = con4.Actual_of_Signed_Contract__c = con4.Actual_of_Shop_Open__c = today;
        con4.Rental_Year__c = 4;
        con4.Opportunity_Name__c = opp.Id;
        listCon.add(con4);

        insert(listCon);

        ContractExpireNotificationBatch batch = new ContractExpireNotificationBatch();
        Test.startTest();
        Id jobId = Database.executeBatch(batch);
        Test.stopTest();
    }
}
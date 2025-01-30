@isTest
public with sharing class ContractController_Test {

    @TestSetup
    static void makeData(){
        Units__c units = new Units__c(
            Usage_Type__c = 'Office Rental'
        ); 
        insert(units);

        List<Contract__c> listCon = new List<Contract__c>();
        Contract__c con = new Contract__c(Name = 'Test', ContractGrading__c = '[{}]');
        listCon.add(con);
        Contract__c con2 = new Contract__c(Name = 'Test 2', Status__c = 'Activated', Contract_Start_Date__c = date.parse('14/12/2021'), Contract_End_Date__c = date.parse('14/12/2023'));
        con2.Actual_of_Billing_Rent_Service__c = con2.Actual_of_Billing_Insurance__c = con2.Actual_of_Decorate_the_Space__c = con2.Actual_of_Delivery_the_Area__c = System.today();
        con2.Actual_of_Design_Guideline__c = con2.Actual_of_Signed_Contract__c = con2.Actual_of_Shop_Open__c = System.today();
        listCon.add(con2);
        insert(listCon);

        List<ContractLineItem__c> listConLine = new List<ContractLineItem__c>();
        ContractLineItem__c conLine = new ContractLineItem__c(Contract__c = con.Id, Unit__c = units.Id);
        listConLine.add(conLine);
        ContractLineItem__c conLine2 = new ContractLineItem__c(Contract__c = con2.Id, Unit__c = units.Id);
        listConLine.add(conLine2);
        insert(listConLine);

        ContractPeriod__c conPeriod = new ContractPeriod__c(Contract__c = con.Id, PeriodFrom__c = System.today(), PeriodTo__c = System.today());
        insert(conPeriod);

        ContractPrice__c conPrice = new ContractPrice__c(Contract__c = con.Id, From__c = System.today(), To__c = System.today());
        insert(conPrice);
    }

    @isTest
    public static void test_getAvaliableDate() {
        Test.startTest();
        List<String> res = ContractController.getAvaliableDate(TestUtility.getFakeId(Contract__c.SObjectType));
        Test.stopTest();
    }

    @isTest
    public static void test_checkAvaliable() {
        Contract__c con = [SELECT Id FROM Contract__c WHERE Name = 'Test'];

        Test.startTest();
        String res = ContractController.checkAvaliable(con.Id, '2022-12-15', '2023-12-15');
        Test.stopTest();
    }

    @isTest
    public static void test_changePeriodDetail() {
        Contract__c con = [SELECT Id FROM Contract__c WHERE Name = 'Test'];

        Test.startTest();
        Boolean res = ContractController.changePeriodDetail(con.Id, 1);
        Test.stopTest();
    }
}
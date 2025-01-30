@isTest
public class ContractTrigger_Test {

    @isTest
    public static void test_contractTrigger() {
        TriggerActivation__c customSetting = new TriggerActivation__c(ContractTrigger__c = true);
        insert(customSetting);

        Branch__c branch = new Branch__c(
        	Name = 'Branch',
            Branch_Code__c = 'b001'
        );
        insert branch;

        Building__c building = new Building__c(
            Name = 'buildingName',
            Building_Name_TH__c = 'Building Name TH',
            Building_Abbreviated__c = 'Abbr',
            Active__c = false,
            Branch__c = branch.Id
        );
        insert building;

        Units__c units = new Units__c(
            Usage_Type__c = 'Office Rental'
        ); 
        insert(units);

        Account acc = new Account(Name = 'Test');
        acc.Address__c = 'Address';
        acc.Subdistrict__c = 'Subdistrict';
        acc.District__c = 'District';
        acc.Province__c = 'Province';
        acc.ZipCode__c = 'ZipCode';
        acc.Mobile_Phone__c = '091111111';
        insert(acc);

        RecordType eventType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Rent_Event' AND SobjectType = 'Opportunity'];
        RecordType billboardType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Rent_a_Billboard' AND SobjectType = 'Opportunity'];

        List<Opportunity> listOpp = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name = 'Test');
        opp.AccountId = acc.Id;
        opp.StageName = 'Quotation Preparation';
        opp.CloseDate = System.today();
        opp.Rental_Type__c = 'Space_Rental';
        listOpp.add(opp);
        Opportunity opp2 = new Opportunity(Name = 'Test');
        opp2.AccountId = acc.Id;
        opp2.StageName = 'Quotation Preparation';
        opp2.CloseDate = System.today();
        opp2.Rental_Type__c = 'OP_Rental';
        listOpp.add(opp2);
        Opportunity opp3 = new Opportunity(Name = 'Test');
        opp3.AccountId = acc.Id;
        opp3.StageName = 'Quotation Preparation';
        opp3.CloseDate = System.today();
        opp3.Rental_Type__c = 'Event_Rental';
        opp3.RecordTypeId = eventType.Id;
        opp3.Description_for_Event_Quotation__c = 'Test';
        listOpp.add(opp3);
        Opportunity opp4 = new Opportunity(Name = 'Test');
        opp4.AccountId = acc.Id;
        opp4.StageName = 'Quotation Preparation';
        opp4.CloseDate = System.today();
        opp4.Rental_Type__c = 'Billboard_Rental';
        opp4.RecordTypeId = billboardType.Id;
        opp4.No_CAM__c = true;
        listOpp.add(opp4);
        insert(listOpp);

        OpportunityLineItem__c oppLine = new OpportunityLineItem__c();
        oppLine.Opportunity__c = opp3.Id;
        oppLine.Unit__c = units.Id;
        insert(oppLine);

        List<Contract__c> listCon = new List<Contract__c>();
        Contract__c con = new Contract__c();
        con.Building__c = building.Id;
        con.Year_1_Monthly_Rental__c = con.Year_1_Monthly_Rent_Sq_m__c = con.Year_1_Monthly_Service__c = con.Year_1_Monthly_Service_Sq_m__c = 1;
        con.Year_1_Monthly_CAM__c = con.Year_1_Monthly_CAM_Sq_m__c = con.Year_Last_Monthly_Rental__c = con.Year_Last_Monthly_Rent_Sq_m__c = 1;
        con.Year_Last_Monthly_Service__c = con.Year_Last_Monthly_Service_Sq_m__c = con.Year_Last_Monthly_CAM__c = con.Year_Last_Monthly_CAM_Sq_m__c = 1;
        con.Other_Fines_and_Fees__c = 1;
        con.Opportunity_Name__c = opp.Id;
        listCon.add(con);
        Contract__c con2 = new Contract__c();
        con2.Building__c = building.Id;
        con2.Opportunity_Name__c = opp2.Id;
        listCon.add(con2);
        Contract__c con3 = new Contract__c();
        con3.Building__c = building.Id;
        con3.Opportunity_Name__c = opp3.Id;
        listCon.add(con3);
        Contract__c con4 = new Contract__c();
        con4.Building__c = building.Id;
        con4.Opportunity_Name__c = opp4.Id;
        listCon.add(con4);

        Test.startTest();
        insert(listCon);
        con.Other_Fines_and_Fees__c = 2;
        update(con);
        Test.stopTest();
    }
}
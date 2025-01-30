@isTest
public with sharing class OpportunityLeaseholdFloorModel_Test {
    @isTest
    public static void test_parse() {
        Test.startTest();
        List<OpportunityLeaseholdFloorModel.Data> res = OpportunityLeaseholdFloorModel.parse('[{}]');
        Test.stopTest();
    }

    @isTest
    public static void test_toString() {
        List<OpportunityLeaseholdFloorModel.Data> data = new List<OpportunityLeaseholdFloorModel.Data>();
        Test.startTest();
        OpportunityLeaseholdFloorModel.Data temp = new OpportunityLeaseholdFloorModel.Data();
        temp.Id = temp.Name = temp.Floor = temp.OpportunityDepositExpense = temp.Measurement = temp.BuildingFloor = temp.Opportunity = 'x';
        temp.TotalPrice = temp.PricePerSqm = temp.Area = 0;
        data.add(temp);
        String res = OpportunityLeaseholdFloorModel.toString(data);
        Test.stopTest();
    }
}
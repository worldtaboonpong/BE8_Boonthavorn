@isTest
public with sharing class BuildingSelector_Test {
    @isTest
    public static void test_query(){
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

        Test.startTest();
        List<Building__c> output = BuildingSelector.getBuildingInfoById(new Set<Id>{building.Id});
        Test.stopTest();
        System.assertEquals(false, output.isEmpty());
    }
}
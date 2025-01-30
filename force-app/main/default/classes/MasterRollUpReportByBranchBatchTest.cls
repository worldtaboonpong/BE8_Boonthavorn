@isTest
private with sharing class MasterRollUpReportByBranchBatchTest {

    @TestSetup
    static void makeData(){
        Branch__c branch = new Branch__c(
        	Name = 'Design Village บางนา',
            Branch_Code__c = 'b001'
        );
        insert branch;

        Building__c building = new Building__c(
            Name = 'Design Village - บางนา_A',
            Building_Name_TH__c = 'ดีไซน์ วิลเลจ บางนา',
            Building_Abbreviated__c = 'Abbr',
            Active__c = true,
            Branch__c = branch.Id
        );
        insert building;
    }

    @isTest
    private static void testNormalSchedule(){
        Test.startTest();
        Database.executeBatch(new MasterRollUpReportByBranchBatch(), 100);
        Test.stopTest();
        Roll_Up_Area_Building__c checkMasterLookup = [SELECT Id, Roll_up_Area_Branch__c, Branch__c, Roll_up_Area_Branch__r.Branch__c FROM Roll_Up_Area_Building__c LIMIT 1];
        System.assertNotEquals(null, checkMasterLookup.Roll_up_Area_Branch__c, 'Master Rollup must not be null');
        System.assertEquals(checkMasterLookup.Branch__c, checkMasterLookup.Roll_up_Area_Branch__r.Branch__c, 'Category should match between child and parent');

        AggregateResult[] aggregatedResult = [SELECT COUNT(Id) totalRecords FROM Roll_Up_Area_Building__c WHERE Branch__r.Name = 'Design Village บางนา' GROUP BY Building__c LIMIT 1];
        Integer totalRecordsCount = 0;
        for(AggregateResult ar : aggregatedResult) {
            totalRecordsCount = (Integer)ar.get('totalRecords');
        }
        System.assertEquals(50, totalRecordsCount, '1 Building should create 50 months records');
    }

    @isTest
    private static void testManualDate(){
        Test.startTest();
        Database.executeBatch(new MasterRollUpReportByBranchBatch(-1,1), 100);
        Test.stopTest();
        Roll_Up_Area_Building__c checkMasterLookup = [SELECT Id, Roll_up_Area_Branch__c, Branch__c, Roll_up_Area_Branch__r.Branch__c FROM Roll_Up_Area_Building__c LIMIT 1];
        System.assertNotEquals(null, checkMasterLookup.Roll_up_Area_Branch__c, 'Master Rollup must not be null');
        System.assertEquals(checkMasterLookup.Branch__c, checkMasterLookup.Roll_up_Area_Branch__r.Branch__c, 'Category should match between child and parent');

        AggregateResult[] aggregatedResult = [SELECT COUNT(Id) totalRecords FROM Roll_Up_Area_Building__c WHERE Branch__r.Name = 'Design Village บางนา' GROUP BY Building__c LIMIT 1];
        Integer totalRecordsCount = 0;
        for(AggregateResult ar : aggregatedResult) {
            totalRecordsCount = (Integer)ar.get('totalRecords');
        }
        System.assertEquals(2, totalRecordsCount, '1 Building should create 2 months records');
    }
}
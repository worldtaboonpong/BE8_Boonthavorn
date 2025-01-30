@isTest
private with sharing class MasterRollupTrafficBatchTest {

    @TestSetup
    static void makeData(){
        List<Branch__c> branches = new List<Branch__c>();
        Branch__c branchBNA = new Branch__c(
        	Name = 'Design Village บางนา',
            Branch_Code__c = 'b001'
        );
        branches.add(branchBNA);

        Branch__c branchPUT = new Branch__c(
        	Name = 'Design Village พุทธมณฑล',
            Branch_Code__c = 'b002'
        );
        branches.add(branchPUT);
        insert branches;
    }

    @isTest
    private static void testRunBatch(){
        Test.startTest();
        Database.executeBatch(new MasterRollupTrafficBatch(), 100);
        Test.stopTest();
        Date checkDate = Date.today();
        List<Roll_up_Traffic__c> checkResult = [SELECT Id, Date__c, Branch__r.Branch_Code__c, Is_Active__c FROM Roll_up_Traffic__c ORDER BY Branch__r.Branch_Code__c];
        System.assertEquals(4, checkResult.size(), 'Roll-up Traffic record should be created 4 records');
        System.assertEquals(checkDate, checkResult[0].Date__c, 'Date should be today');
        System.assertEquals(false, checkResult[0].Is_Active__c, 'Not Active until has traffic record');
    }

    @isTest
    private static void testDateFilter(){
        Date yesterday = Date.today().addDays(-1);
        Date today = Date.today();
        Test.startTest();
        Database.executeBatch(new MasterRollupTrafficBatch(yesterday, today), 100);
        Test.stopTest();
        List<Roll_up_Traffic__c> checkResult = [SELECT Id, Date__c, Branch__r.Branch_Code__c, Is_Active__c FROM Roll_up_Traffic__c ORDER BY Branch__r.Branch_Code__c];
        System.assertEquals(8, checkResult.size(), 'Roll-up Traffic record should be created 4 records');
        System.assertEquals(false, checkResult[0].Is_Active__c, 'Not Active until has traffic record');
    }
}
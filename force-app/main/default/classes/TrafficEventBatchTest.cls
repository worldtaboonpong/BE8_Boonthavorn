@isTest
private with sharing class TrafficEventBatchTest {

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

        TriggerActivation__c customSetting = new TriggerActivation__c(TrafficTrigger__c = true);
        insert(customSetting);
        Date mockDate = Date.today();
        MockUpDataFor_Test.createRollUpTraffic(mockDate, mockDate.addDays(5), branches[0].Id);
        MockUpDataFor_Test.createRollUpTraffic(mockDate, mockDate.addDays(5), branches[1].Id);
        List<Traffic__c> trafficsBNA = MockUpDataFor_Test.createTraffics(mockDate, mockDate.addDays(5), branches[0].Id);
        List<Traffic__c> trafficsPUT = MockUpDataFor_Test.createTraffics(mockDate, mockDate.addDays(5), branches[1].Id);
        trafficsBNA.addAll(trafficsPUT);
        insert trafficsBNA;
        Event_and_Special_Holiday__c event = MockUpDataFor_Test.createEvent(mockDate, mockDate.addDays(2), branches[0].Id);
        insert event;
        Event_and_Special_Holiday__c holiday = MockUpDataFor_Test.createSpecialHoliday(mockDate);
        insert holiday;
        List<Traffic_and_Event__c> oldJuctions = new List<Traffic_and_Event__c>();
        Traffic_and_Event__c toDeleteJunc = new Traffic_and_Event__c();
        toDeleteJunc.Traffic__c = trafficsBNA[6].Id;
        toDeleteJunc.Event__c = event.Id;
        oldJuctions.add(toDeleteJunc);
        Traffic_and_Event__c notChangeJunc = new Traffic_and_Event__c();
        notChangeJunc.Traffic__c = trafficsBNA[2].Id;
        notChangeJunc.Event__c = event.Id;
        oldJuctions.add(notChangeJunc);
        insert oldJuctions;
    }

    @isTest
    private static void testRunBatch(){
        Test.startTest();
        Database.executeBatch(new TrafficEventBatch(), 500);
        Test.stopTest();
        Date checkDate = Date.today();
        List<Traffic__c> checkResult = [SELECT Id, Event__c, Special_Holiday__c FROM Traffic__c WHERE Date__c = :checkDate ORDER BY Branch__r.Branch_Code__c];
        System.assertEquals(true, checkResult[0].Event__c, 'BNA Branch has an Event today');
        System.assertEquals(false, checkResult[1].Event__c, 'PUT Branch has an Event today');
        System.assertEquals(true, checkResult[0].Special_Holiday__c, 'Special Holiday should be true');
        List<Traffic_and_Event__c> checkJunc = [SELECT Id, Traffic__c, Event__c FROM Traffic_and_Event__c];
        System.assertEquals(3, checkJunc.size(), 'Should have 3 junction records');
    }

    @isTest
    private static void testDateFilter(){
        Test.startTest();
        Database.executeBatch(new TrafficEventBatch(Date.today()), 500);
        Test.stopTest();
        Date checkDate = Date.today();
        List<Traffic__c> checkResult = [SELECT Id, Event__c, Special_Holiday__c FROM Traffic__c WHERE Date__c = :checkDate ORDER BY Branch__r.Branch_Code__c];
        System.assertEquals(true, checkResult[0].Event__c, 'BNA Branch has an Event today');
        System.assertEquals(false, checkResult[1].Event__c, 'PUT Branch has an Event today');
        System.assertEquals(true, checkResult[0].Special_Holiday__c, 'Special Holiday should be true');
        List<Traffic_and_Event__c> checkJunc = [SELECT Id, Traffic__c, Event__c FROM Traffic_and_Event__c];
        System.assertEquals(3, checkJunc.size(), 'Should have 3 junction records');
    }
}
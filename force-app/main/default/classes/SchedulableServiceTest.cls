@isTest
public class SchedulableServiceTest {

    //TODO Uncomment after a schedulable class is created
  @isTest static void testCreateSchedule() {
        Test.startTest();
        System.schedule('Purge_Batch_Schedulable' , '1 1 1 1 1 ? 2050', new SchedulableService('Purge_Batch'));
        Test.stopTest();
    }
    
    @isTest static void testCreateSchedule2() {
        Test.startTest();
        System.schedule('Purge_Batch_Schedulable' , '1 1 1 1 1 ? 2050', new SchedulableService('Purge_Batch', 5));
        Test.stopTest();
    }
    
    @isTest static void testCreateSchedule3() {
        Test.startTest();
        System.schedule('Purge_Batch_Schedulable' , '1 1 1 1 1 ? 2050', new SchedulableService(new Purge_Batch(), 5));
        Test.stopTest();
    }
}
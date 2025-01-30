@isTest
public class ManualBatch_Controller_Test {

    // TODO Uncomment this after a schedulable class is created
    // @isTest static void testCreateSchedule() { 
    //     Test.startTest();
    //         System.schedule('Purge_Batch_Schedulable', '1 1 1 1 1 ? 2050', new Purge_Batch_Schedulable());
    //     Test.stopTest();
    //     System.assertNotEquals(null, [SELECT Id FROM CronTrigger]);
    // }

    @isTest static void testRunNegativeBatchJob() {
        ManualBatch_Controller manualOperationCon = new ManualBatch_Controller();
        manualOperationCon.getHourList();
        manualOperationCon.getMinuteList();
        manualOperationCon.getDayList();
        manualOperationCon.getWeeklyValue();
        manualOperationCon.getDailyTypeValue();
        manualOperationCon.getFieldValue();
        manualOperationCon.getScheduleTypeValue();
        manualOperationCon.batchName = 'Purge_Batch';
        manualOperationCon.batchSize = 2;
        manualOperationCon.scheduleType = 'One Time';
        manualOperationCon.oneTimeValue = '1022/1022/2560';
        Test.startTest();
            manualOperationCon.runBatch();
        Test.stopTest();
    }

    @isTest static void testRunNegativeBatchSize() {
        ManualBatch_Controller manualOperationCon = new ManualBatch_Controller();
        manualOperationCon.batchName = 'Purge_Batch';
        manualOperationCon.batchSize = 201;
        manualOperationCon.scheduleType = 'Daily';
        manualOperationCon.dailyType = 'EVERY_WEEKDAY';
        Test.startTest();
            manualOperationCon.runBatch();
        Test.stopTest();
    }

    @isTest static void testRunBatchJob() {
        ManualBatch_Controller manualOperationCon = new ManualBatch_Controller();
        manualOperationCon.batchName = 'PointCalculationBatch';
        manualOperationCon.batchSize = 5;
        Datetime beforeRunbatch = System.now();
        Test.startTest();
            manualOperationCon.runBatch();
        Test.stopTest();
        //AsyncApexJob asyncJob = [SELECT CreatedDate, CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = :manualOperationCon.batchName];
    }
    
    @isTest static void testRunScheduleJobOneTime() {
        ManualBatch_Controller manualOperationCon = new ManualBatch_Controller();
        manualOperationCon.batchName = 'Purge_Batch';
        manualOperationCon.hoursInput = '0';
        manualOperationCon.minInput = '0';
        manualOperationCon.scheduleType = 'One Time';
        manualOperationCon.oneTimeValue = '10/10/2560';
        Test.startTest();
            manualOperationCon.runSchedule();
        Test.stopTest();
        String jobName = manualOperationCon.batchName + ', ' + manualOperationCon.scheduleType;
        System.assertNotEquals(null, [SELECT CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
    }

    @isTest static void testRunScheduleJobDaily() {
        ManualBatch_Controller manualOperationCon = new ManualBatch_Controller();
        manualOperationCon.batchName = 'Purge_Batch';
        manualOperationCon.hoursInput = '0';
        manualOperationCon.minInput = '0';
        manualOperationCon.scheduleType = 'Daily';
        manualOperationCon.dailyType = 'EVERY_DAY';
        Test.startTest();
            manualOperationCon.runSchedule();
        Test.stopTest();
        String jobName = manualOperationCon.batchName + ', ' + manualOperationCon.scheduleType;
        System.assertNotEquals(null, [SELECT CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
    }

    @isTest static void testRunScheduleJobWeekly() {
        ManualBatch_Controller manualOperationCon = new ManualBatch_Controller();
        manualOperationCon.batchName = 'Purge_Batch';
        manualOperationCon.hoursInput = '0';
        manualOperationCon.minInput = '0';
        manualOperationCon.scheduleType = 'Weekly';
        manualOperationCon.weeklyType.add('SUN');
        manualOperationCon.weeklyType.add('MON');
        Test.startTest();
            manualOperationCon.runSchedule();
        Test.stopTest();
        String jobName = manualOperationCon.batchName + ', ' + manualOperationCon.scheduleType;
        System.assertNotEquals(null, [SELECT CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
    }
    
    @isTest static void testRunScheduleJobMonthly() {
        ManualBatch_Controller manualOperationCon = new ManualBatch_Controller();
        manualOperationCon.batchName = 'Purge_Batch';
        manualOperationCon.hoursInput = '10';
        manualOperationCon.minInput = '0';
        manualOperationCon.scheduleType = 'Monthly';
        manualOperationCon.monthlyType = '28';
        Test.startTest();
            manualOperationCon.runSchedule();
        Test.stopTest();
        String jobName = manualOperationCon.batchName + ', ' + manualOperationCon.scheduleType;
        System.assertNotEquals(null, [SELECT CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
    }
}
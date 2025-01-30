@isTest
private class Purge_Batch_Schedulable_Test
{
    @isTest
    static void testExecute() {
        String CRON_EXP = '0 0 0 15 3 ? 2030';
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new Purge_Batch_Schedulable());
         
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Integer yr = 2030;
        if (UserInfo.getLocale() == 'th_TH') yr += 543;
        System.assertEquals(yr+'-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}
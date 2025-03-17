@isTest
private class PS_ShareRecordsToAccountTMScheduledTest {

    @IsTest
    static void shouldScheduleJob() {
        //GIVEN
        String CRON_EXP = '0 0 * * * ?';

        //WHEN
        Test.startTest();
        String jobId = System.schedule(
            'Test Share Records to Account Team Members',
            CRON_EXP,
            new PS_ShareRecordsToAccountTMScheduled()
        );
        Test.stopTest();

        //THEN
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE id = :jobId];
        System.assert(cronTrigger != null, 'Job should be scheduled');
        System.assertEquals(CRON_EXP, cronTrigger.CronExpression);
        System.assertEquals(0, cronTrigger.TimesTriggered);
    }

}
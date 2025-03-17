@isTest
private class PS_ShareRecordsToAtmFullRecalcSchedTest {

    @IsTest
    static void shouldScheduleJob() {
        //GIVEN
        String CRON_EXP = '0 0 0 ? * SUN';

        //WHEN
        Test.startTest();
        String jobId = System.schedule(
            'Test Share Records to Account Team Members with Full Recalculation',
            CRON_EXP,
            new PS_ShareRecordsToAtmFullRecalcSched()
        );
        Test.stopTest();

        //THEN
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE id = :jobId];
        System.assert(cronTrigger != null, 'Job should be scheduled');
        System.assertEquals(CRON_EXP, cronTrigger.CronExpression);
        System.assertEquals(0, cronTrigger.TimesTriggered);
    }

}
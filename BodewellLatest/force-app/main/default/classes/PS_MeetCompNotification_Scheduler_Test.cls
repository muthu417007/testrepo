@IsTest
public class PS_MeetCompNotification_Scheduler_Test {
	static testmethod void execute_ShouldScheduleJob() {
        
		//GIVEN        
		Test.startTest();
		String CRON_EXP = '0 0 0 3 9 ? 2031';

        //WHEN
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP,  new PS_MeetCompNotification_Dispatcher());

		//THEN
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2031-09-03 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();    
	}
}
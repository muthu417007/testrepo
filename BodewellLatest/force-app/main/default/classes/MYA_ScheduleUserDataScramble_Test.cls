/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        22.09.2022
 * @description    For user data scramble schedule method test
 */
@isTest
public class MYA_ScheduleUserDataScramble_Test {
    //First test method
    @isTest
    static void testScheduleUserDataScramble(){
        String cronExp = '0 6 * * * ?';
        Test.startTest();
        String jobId = System.schedule('User Data Scramble', cronExp, new MYA_ScheduleUserDataScramble()); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
   }
}
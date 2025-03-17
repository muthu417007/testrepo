/**
*@description : Class has been created to Test scheduled Batch Apex for Record Deletion created for MYA project.
Name: Kanishtika Gupta
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
Task :- IDMSF-1483
**********************************************
Purpose: Class has been created to Test scheduled Batch Apex for Record Deletion created for MYA project.
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 08/08/2022   Created
**********************************************
**********************************************/
@isTest
public class MYA_BatchMassDeleteRecSchedule_Test {
  @isTest
    static void testMya_BatchMassDelete(){
        String CRON_EXP = '0 6 * * * ?';
        Test.startTest();
        String jobId = System.schedule('Delete Records', CRON_EXP, new MYA_BatchMassDeleteRecSchedule()); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
   }
 }
@istest
public class MedalliaBatchProcessTest {
    public static testmethod void testMethodScheduler(){
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('Sample_Heading', CRON_EXP, new MedalliaBatchProcess() );   
        Test.stopTest();
    }  

}
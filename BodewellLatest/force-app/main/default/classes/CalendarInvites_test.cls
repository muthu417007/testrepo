@isTest(seeAllData=true)
public class CalendarInvites_test {
	public static testMethod void CreateServiceAppointments(){
        Test.startTest();
        CalendarInvites.sendinvite('gowsic.s@geappliances.com', Datetime.now().format('MM-dd-yyyy HH:mm:ss', 'GMT'), Datetime.now().format('MM-dd-yyyy HH:mm:ss', 'GMT'), 'SA-0280','Phone', 'Test Subject', 'America/New_York','Please add the attached meeting invition in our calendar as reminder. Thanks!');
        Test.stopTest();
    }
}
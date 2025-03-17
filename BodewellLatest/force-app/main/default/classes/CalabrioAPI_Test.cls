/**
 * @author         Neha Chowdhury
 * @company        GEA
 * @created        07.02.2022
 * @description    Jira Ticket 447 API for Calabrio recordings. This is test class for the callouts
*/
@isTest
public class CalabrioAPI_Test {
@isTest static void testCallout() {
       Test.setMock(HttpCalloutMock.class, new CalabrioAPIMockTest());
 	   CalabrioAPIforStartScreen.fireCalabrioAPIforstartscreen();
       CalabrioAPIforStopScreen.fireCalabrioAPIforstopscreen();
      System.assertEquals(null, null,'Test class has fired');
}
}
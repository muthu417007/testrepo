@isTest
public with sharing class TwilioTest {

    @isTest
    public static void setTwilioMessageTest(){

        Twilio_Message__c tm = new Twilio_Message__c(
            To__c = '8645551234',
            From__c = '',
            Message__c = 'Border collies are the best :)',
            Response__c = 'The best!'
        );

        Twilio.setTwilioMessage(tm);
    }

    @isTest
    public static void sendTwilioMessageTest(){

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Tester',
            Phone = '8645551234'
        );
        insert con;

        Case cs = new Case(
            ContactId = con.Id,
            Subject = 'Test'
        );
        insert cs;

        Twilio.sendTwilioMessages(new List<Id>{cs.Id});
    }
}
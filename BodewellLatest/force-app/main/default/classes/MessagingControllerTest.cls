@isTest
public with sharing class MessagingControllerTest {

    @TestSetup
    static void dataFactory(){
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.BillingCity = 'New York';
        testAccount.BillingCountry = 'United States';
        testAccount.BillingPostalCode = '91210';
        testAccount.BillingStreet = '5th Avenue';
        testAccount.BillingState = 'New York';
        insert testAccount;

        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.FirstName = 'TestName';
        testContact.LastName = 'TestLastname';
        testContact.email = 'test@test.com';
        insert testContact;
    }

    @isTest
    static void getMessagingSeesionsTest(){
        Case caseRecord = new Case();
        Schema.RecordTypeInfo rtInfo = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General');
        if(rtInfo != null && rtInfo.getRecordTypeId() != null){
            caseRecord.RecordTypeId = rtInfo.getRecordTypeId();
        }
        caseRecord.Subject = 'test subject';
        caseRecord.AccountId = [SELECT Id FROM Account LIMIT 1].get(0).Id;
        caseRecord.ContactId = [SELECT Id FROM Contact LIMIT 1].get(0).Id;
        insert caseRecord;

        List<MessagingController.MessageSession> msList = new List<MessagingController.MessageSession>();
        Test.startTest();
            msList = MessagingController.getMessagingSeesions(caseRecord.Id);
        Test.stopTest();

        System.assertEquals(1, msList.size());
    }

}
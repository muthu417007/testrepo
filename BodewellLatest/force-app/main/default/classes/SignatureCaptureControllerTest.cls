@isTest
public with sharing class SignatureCaptureControllerTest {

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
    static void updateOwnerConsentTest(){
        Case caseRecord = new Case();
        Schema.RecordTypeInfo rtInfo = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General');
        if(rtInfo != null && rtInfo.getRecordTypeId() != null){
            caseRecord.RecordTypeId = rtInfo.getRecordTypeId();
        }
        caseRecord.Subject = 'test subject';
        caseRecord.AccountId = [SELECT Id FROM Account LIMIT 1].get(0).Id;
        caseRecord.ContactId = [SELECT Id FROM Contact LIMIT 1].get(0).Id;
        insert caseRecord;

        Test.startTest();
            SignatureCaptureController.updateOwnerConsent(caseRecord);
        Test.stopTest();

        Case caseAfterSave = [SELECT Owner_Consent__c FROM Case WHERE Id =: caseRecord.Id];
        System.assertEquals(true, caseAfterSave.Owner_Consent__c);
    }
}
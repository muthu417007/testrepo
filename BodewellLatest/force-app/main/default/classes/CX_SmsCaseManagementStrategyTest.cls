/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        09.06.2021
 * @description    Class used to test the CX_SmsCaseManagementStrategy class.
 */
@isTest
public with sharing class CX_SmsCaseManagementStrategyTest {
  static Case testCase;
  static MessagingSession testSms;
  static Contact testContact;
  static CX_ICaseManagementStrategy strategy;
  static MessagingChannel newChannel;

  @future
  static void makeMessagingChannel() {
    newChannel = new MessagingChannel(
      MasterLabel = '1234567890',
      MessagingPlatformKey = '1234asdf',
      MessageType = 'Text',
      DeveloperName = 'Text_1234asdf'
    );
    insert newChannel;
  }

  static void makeData() {
    MessagingEndUser newEnduser = new MessagingEndUser(
      Name = '1234567890',
      MessagingChannelId = newChannel.Id,
      MessageType = 'Text',
      MessagingPlatformKey = '1234asdf'
    );
    insert newEnduser;

    testSms = new MessagingSession(
      MessagingEndUser = newEnduser,
      MessagingEndUserId = newEnduser.Id,
      MessagingChannelId = newChannel.Id,
      Status = 'Ended'
    );
    insert testSms;

    Contact newContact = new Contact(
      LastName = 'Test',
      Phone = testSms.MessagingEndUser.Name.right(10)
    );
    insert newContact;
    testContact = newContact;

    Case newCase = new Case(Subject = 'Test case', ContactId = testContact.Id);
    insert newCase;
    testCase = newCase;

    strategy = new CX_SmsCaseManagementStrategy();
  }

  static void flushData() {
    delete testCase;
    delete testContact;
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        09.06.2021
   * @description    Class used to test the attachCase method.
   */
  @IsTest
  static void attachCaseTest() {
    //Workaround: Inserting the MessagingChannel in a different transaction by running Test.stupTest() to prevent Mixed DML Exception
    Test.startTest();
    makeMessagingChannel();
    Test.stopTest();
    //Finish workaround
    makeData();

    strategy.attachCase(testSms.Id, testCase.Id);
    List<CX_Voice_Call_Case__c> attachment = [
      SELECT Id, CX_Case__c, CX_Messaging_Session__c
      FROM CX_Voice_Call_Case__c
      WHERE CX_Messaging_Session__c = :testSms.Id AND CX_Case__c = :testCase.Id
      ORDER BY CreatedDate DESC
    ];

    System.assert(attachment.size() == 1);
    System.assert(attachment[0].CX_Case__c == testCase.Id);
    System.assert(attachment[0].CX_Messaging_Session__c == testSms.Id);

    delete attachment;
    flushData();
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        09.06.2021
   * @description    Class used to test the createCase method.
   */
  @IsTest
  static void createCaseTest() {
    //Workaround: Inserting the MessagingChannel in a different transaction by running Test.stupTest() to prevent Mixed DML Exception
    Test.startTest();
    makeMessagingChannel();
    Test.stopTest();
    //Finish workaround
    makeData();

    Case createdCase = strategy.createCase(testSms.Id, testContact.Id);
    List<CX_Voice_Call_Case__c> attachment = [
      SELECT Id, CX_Case__c, CX_Messaging_Session__c
      FROM CX_Voice_Call_Case__c
      WHERE
        CX_Messaging_Session__c = :testSms.Id
        AND CX_Case__c = :createdCase.Id
      ORDER BY CreatedDate DESC
    ];

    System.assert(createdCase.ContactId == testContact.Id);
    System.assert(attachment.size() == 1);
    System.assert(attachment[0].CX_Case__c == createdCase.Id);
    System.assert(attachment[0].CX_Messaging_Session__c == testSms.Id);

    delete attachment;
    delete createdCase;
    flushData();
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        09.06.2021
   * @description    Class used to test the getCases method.
   */
  @IsTest
  static void getCasesTest() {
    //Workaround: Inserting the MessagingChannel in a different transaction by running Test.stupTest() to prevent Mixed DML Exception
    Test.startTest();
    makeMessagingChannel();
    Test.stopTest();
    //Finish workaround
    makeData();
    List<Case> cases = strategy.getCases(testContact.Id);

    System.assert(cases[0].Subject.equals('Test case'));

    flushData();
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        09.06.2021
   * @description    Class used to test the getMatchingContacts method.
   */
  @IsTest
  static void getMatchingContactsTest() {
    //Workaround: Inserting the MessagingChannel in a different transaction by running Test.stupTest() to prevent Mixed DML Exception
    Test.startTest();
    makeMessagingChannel();
    Test.stopTest();
    //Finish workaround
    makeData();

    List<Contact> matchingContacts = strategy.getMatchingContacts(testSms.Id);

    flushData();
  }
}
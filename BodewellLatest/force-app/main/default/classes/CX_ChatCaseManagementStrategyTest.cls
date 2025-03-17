/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        09.06.2021
 * @description    Class used to test the CX_ChatCaseManagementStrategy class.
 */
@isTest
public with sharing class CX_ChatCaseManagementStrategyTest {
  static Case testCase;
  static LiveChatTranscript testChat;
  static Contact testContact;
  static CX_ICaseManagementStrategy strategy;

  static void makeData() {
    LiveChatVisitor chatVisitor = new LiveChatVisitor();
    insert chatVisitor;

    testChat = new LiveChatTranscript(
      LiveChatVisitorId = chatVisitor.id
    );
    insert testChat;

    Contact newContact = new Contact(
      LastName = 'Test'
    );
    insert newContact;
    testContact = newContact;

    Case newCase = new Case(Subject = 'Test case', ContactId = testContact.Id);
    insert newCase;
    testCase = newCase;

    strategy = new CX_ChatCaseManagementStrategy();
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
    makeData();

    strategy.attachCase(testChat.Id, testCase.Id);
    List<CX_Voice_Call_Case__c> attachment = [
      SELECT Id, CX_Case__c, CX_Chat_Transcript__c
      FROM CX_Voice_Call_Case__c
      WHERE CX_Chat_Transcript__c = :testChat.Id AND CX_Case__c = :testCase.Id
    ];

    System.assert(attachment.size() == 1);
    System.assert(attachment[0].CX_Case__c == testCase.Id);
    System.assert(attachment[0].CX_Chat_Transcript__c == testChat.Id);

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
    makeData();

    Case createdCase = strategy.createCase(testChat.Id, testContact.Id);
    List<CX_Voice_Call_Case__c> attachment = [
      SELECT Id, CX_Case__c, CX_Chat_Transcript__c
      FROM CX_Voice_Call_Case__c
      WHERE
        CX_Chat_Transcript__c = :testChat.Id
        AND CX_Case__c = :createdCase.Id
    ];

    System.assert(createdCase.ContactId == testContact.Id);
    System.assert(attachment.size() == 1);
    System.assert(attachment[0].CX_Case__c == createdCase.Id);
    System.assert(attachment[0].CX_Chat_Transcript__c == testChat.Id);

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
    makeData();

    List<Contact> matchingContacts = strategy.getMatchingContacts(
      testChat.Id
    );

    flushData();
  }
}
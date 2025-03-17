/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        09.06.2021
 * @description    Class used to test the CX_CaseManagementController class.
 */
@isTest
public with sharing class CX_CaseManagementControllerTest {
  static Case testCase;
  static VoiceCall testVoiceCall;
  static Contact testContact;
  static LiveChatTranscript testChat;

  static void makeData() {
    testVoiceCall = new VoiceCall(
      FromPhoneNumber = '1234567890'
    );

    LiveChatVisitor chatVisitor = new LiveChatVisitor();
    insert chatVisitor;

    testChat = new LiveChatTranscript(
      LiveChatVisitorId = chatVisitor.id
    );
    insert testChat;

    Contact newContact = new Contact(
      LastName = 'Test',
      Phone = testVoiceCall.FromPhoneNumber.right(10)
    );
    insert newContact;
    testContact = newContact;

    Case newCase = new Case(Subject = 'Test case', ContactId = testContact.Id);
    insert newCase;
    testCase = newCase;
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

    CX_CaseManagementController.attachCase(
      'Voice Call',
      testVoiceCall.Id,
      testCase.Id
    );
    List<CX_Voice_Call_Case__c> attachment = [
      SELECT Id, CX_Case__c, CX_Voice_Call__c
      FROM CX_Voice_Call_Case__c
      WHERE CX_Voice_Call__c = :testVoiceCall.Id AND CX_Case__c = :testCase.Id
    ];

    System.assert(attachment.size() == 1);
    System.assert(attachment[0].CX_Case__c == testCase.Id);
    System.assert(attachment[0].CX_Voice_Call__c == testVoiceCall.Id);

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

    Case createdCase = CX_CaseManagementController.createCase(
      'Voice Call',
      testVoiceCall.Id,
      testContact.Id
    );
    List<CX_Voice_Call_Case__c> attachment = [
      SELECT Id, CX_Case__c, CX_Voice_Call__c
      FROM CX_Voice_Call_Case__c
      WHERE
        CX_Voice_Call__c = :testVoiceCall.Id
        AND CX_Case__c = :createdCase.Id
    ];

    System.assert(createdCase.ContactId == testContact.Id);
    System.assert(attachment.size() == 1);
    System.assert(attachment[0].CX_Case__c == createdCase.Id);
    System.assert(attachment[0].CX_Voice_Call__c == testVoiceCall.Id);

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
    List<Case> cases = CX_CaseManagementController.getCases(
      'SMS',
      testContact.Id
    );

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

    List<Contact> matchingContacts = CX_CaseManagementController.getMatchingContacts(
      'Chat',
      testChat.Id
    );

    flushData();
  }
}
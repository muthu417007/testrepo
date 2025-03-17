/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        07.06.2021
 * @description    Class implement the chat case management strategy.
 * @testClass      CX_ChatCaseManagementStrategyTest
 */
public with sharing class CX_ChatCaseManagementStrategy extends CX_CaseManagementAbstractStrategy {
  public CX_ChatCaseManagementStrategy() {
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Creates a case and associates it to the record.
   * @param  recordId    Record id to associate
   * @param  contactId   Contact id to associate
   * @return             Created case
   */
  public Case createCase(Id recordId, Id contactId) {
    Case newCase = new Case(Subject = 'New case', ContactId = contactId);
    insert newCase;
    CX_Voice_Call_Case__c newRecord = new CX_Voice_Call_Case__c(
      CX_Case__c = newCase.Id,
      CX_Chat_Transcript__c = recordId
    );
    insert newRecord;
    return newCase;
  }
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Attaches an existing case to the provided record.
   * @param  recordId    Record id to associate
   * @param  caseId      Case id to associate
   */
  public void attachCase(Id recordId, Id caseId) {
    CX_Voice_Call_Case__c newRecord = new CX_Voice_Call_Case__c(
      CX_Case__c = caseId,
      CX_Chat_Transcript__c = recordId
    );
    insert newRecord;
  }
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the matching contact for the provided record.
   * @param  recordId chat session id to get contact
   * @return          Matching contact.
   */
  public List<Contact> getMatchingContacts(Id recordId) {
    LiveChatTranscript chat = [
      SELECT Contact_Email__c
      FROM LiveChatTranscript
      WHERE id = :recordId
      LIMIT 1
    ];
    string email = chat.Contact_Email__c;
    System.debug(email);
    List<Contact> contacts = [
      SELECT Id
      FROM Contact
      WHERE
        Secondary_Email__c = :email
        OR Alternative_Email_2__c = :email
        OR Email = :email
    ];
    return contacts;
  }
}
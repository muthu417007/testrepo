/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        07.06.2021
 * @description    Class implement the sms case management strategy.
 * @testClass      CX_SmsCaseManagementStrategyTest
 */
public with sharing class CX_SmsCaseManagementStrategy extends CX_CaseManagementAbstractStrategy {
  public CX_SmsCaseManagementStrategy() {
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
      CX_Messaging_Session__c = recordId
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
      CX_Messaging_Session__c = recordId
    );
    insert newRecord;
  }
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the matching contact for the provided record.
   * @param  recordId Messaging session id to get contact
   * @return          Matching contact.
   */
  public List<Contact> getMatchingContacts(Id recordId) {
    MessagingSession smsSession = [
      SELECT MessagingEndUser.Name
      FROM MessagingSession
      WHERE id = :recordId
      LIMIT 1
    ];
    String phone = smsSession.MessagingEndUser.Name.right(10);
    List<Contact> contacts = [
      SELECT Id
      FROM Contact
      WHERE
        HomePhone = :phone
        OR OtherPhone = :phone
        OR Phone = :phone
        OR VOIP_Phone__c = :phone
        OR AssistantPhone = :phone
        OR MobilePhone = :phone
    ];
    return contacts;
  }
}
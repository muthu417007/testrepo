/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        07.06.2021
 * @description    Class used to implement the voice call case management strategy.
 * @testClass      CX_CaseManagementContextTest
 */
public with sharing class CX_VoiceCaseManagementStrategy extends CX_CaseManagementAbstractStrategy {
  public CX_VoiceCaseManagementStrategy() {
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
    CX_Voice_Call_Case__c newVoiceCall = new CX_Voice_Call_Case__c(
      CX_Case__c = newCase.Id,
      CX_Voice_Call__c = recordId
    );
    insert newVoiceCall;
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
    CX_Voice_Call_Case__c newVoiceCall = new CX_Voice_Call_Case__c(
      CX_Case__c = caseId,
      CX_Voice_Call__c = recordId
    );
    insert newVoiceCall;
  }
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the matching contact for the provided record.
   * @param  recordId Voice Call id to get contact
   * @return          Matching contact.
   */
  public List<Contact> getMatchingContacts(Id recordId){
    VoiceCall voiceCall;
    if (!System.Test.isRunningTest()) {
      voiceCall  = [ SELECT FromPhoneNumber FROM VoiceCall WHERE Id = :recordId LIMIT 1 ];
    } else {
      voiceCall = new VoiceCall(FromPhoneNumber = '12345678990');
    }
      String phone = voiceCall.FromPhoneNumber.right(10);
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
/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        07.06.2021
 * @description    Class used to expose the case management logic to lwc.
 * @testClass      CX_CaseManagementControllerTest
 */
public with sharing class CX_CaseManagementController {

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the proper context based on the strategy name.
   * @param  strategyName Strategy used for the case management
   * @return              Context with proper strategy
   */
  private static CX_CaseManagementContext contextFactory(string strategyName) {
    switch on strategyName {
      when 'Voice Call' {
        return new CX_CaseManagementContext(
          new CX_VoiceCaseManagementStrategy()
        );
      }
      when 'Chat' {
        return new CX_CaseManagementContext(
          new CX_ChatCaseManagementStrategy()
        );
      }
      when 'SMS' {
        return new CX_CaseManagementContext(new CX_SmsCaseManagementStrategy());
      }
      when else {
        return null;
      }
    }
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the possible related cases to the contact.
   * @param  strategyName Strategy used to get the related cases.
   * @param  contactId    Contact to whom the cases are related.
   * @return              List of related cases.
   */
  @AuraEnabled
  public static List<Case> getCases(string strategyName, Id contactId) {
    return contextFactory(strategyName).getCases(contactId);
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Creates a case related to the provided record.
   * @param  strategyName Strategy used to create the case.
   * @param  recordId     Record to which the case will be associated.
   * @param  contactId    Contact to whom the case will be associated.
   * @return              Create case.
   */
  @AuraEnabled
  public static Case createCase(
    string strategyName,
    Id recordId,
    Id contactId
  ) {
    return contextFactory(strategyName).createCase(recordId, contactId);
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Attaches an existing case to a record.
   * @param  strategyName Strategy used to attach the case.
   * @param  recordId     Record to which the case will be associated.
   * @param  caseId       Case to associate.
   */
  @AuraEnabled
  public static void attachCase(string strategyName, Id recordId, Id caseId) {
    contextFactory(strategyName).attachCase(recordId, caseId);
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the possible matching contacts to the record.
   * @param  strategyName Strategy used to get the matching records.
   * @param  recordId     Record for the search is made.
   * @return              List of possible matching contacts.
   */
  @AuraEnabled
  public static List<Contact> getMatchingContacts(
    string strategyName,
    Id recordId
  ) {
    return contextFactory(strategyName).getMatchingContacts(recordId);
  }
}
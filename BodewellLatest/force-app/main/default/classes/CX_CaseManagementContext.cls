/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        07.06.2021
 * @description    Class used to set the case management strategy.
 * @testClass      CX_CaseManagementContextTest
 */
public with sharing class CX_CaseManagementContext {
  private CX_ICaseManagementStrategy strategy;

  public CX_CaseManagementContext(CX_ICaseManagementStrategy strategy) {
    this.strategy = strategy;
  }

  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the cases associated to a contact
   * @param  contactId Contact id related to the cases.
   * @return           List of associated cases
   */
  public List<Case> getCases(Id contactId) {
    return this.strategy.getCases(contactId);
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
    return this.strategy.createCase(recordId, contactId);
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
    this.strategy.attachCase(recordId, caseId);
  }
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the matching contact for the provided record.
   * @param  recordId Voice Call id to get contact
   * @return          Matching contact.
   */
  public List<Contact> getMatchingContacts(Id recordId) {
    return this.strategy.getMatchingContacts(recordId);
  }
}
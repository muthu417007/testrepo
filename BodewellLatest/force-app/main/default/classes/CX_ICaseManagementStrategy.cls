/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        07.06.2021
 * @description    Interface used to define the case management strategies.
 */
global interface CX_ICaseManagementStrategy {
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the cases associated to a contact
   * @param  contactId Contact id related to the cases.
   * @return           List of associated cases
   */
  List<Case> getCases(Id contactId);
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Creates a case and associates it to the record.
   * @param  recordId    Record id to associate
   * @param  contactId   Contact id to associate
   * @return             Created case
   */
  Case createCase(Id recordId, Id contactId);
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Attaches an existing case to the provided record.
   * @param  recordId    Record id to associate
   * @param  caseId      Case id to associate
   */
  void attachCase(Id recordId, Id caseId);
  /**
   * @author         Karlo Lorenzana
   * @company        GE Appliances
   * @created        07.06.2021
   * @description    Gets the matching contacts for the provided record.
   * @param  recordId Record id to get contact
   * @return          Matching contacts.
   */
  List<Contact> getMatchingContacts(Id recordId);
}
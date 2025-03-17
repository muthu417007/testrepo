/**
 * @author         Karlo Lorenzana
 * @company        GE Appliances
 * @created        07.06.2021
 * @description    Class used to implement the default behavior for the case management strategies.
 */
public with sharing abstract class CX_CaseManagementAbstractStrategy implements CX_ICaseManagementStrategy {
  public CX_CaseManagementAbstractStrategy() {
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
    List<Case> cases = [
      SELECT Id, CaseNumber, Subject, Status, CreatedDate, ClosedDate, Owner.Name
      FROM Case
      WHERE Contact.Id = :contactId
      ORDER BY CreatedDate DESC
    ];
    return cases;
  }
}
/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        25.05.2021
 * @description    Class used to handle Web To Case logic
 * @testClass      CX_WebToCaseTest
 */
public with sharing class CX_WebToCase {
    private static final CX_WebToCase INSTANCE = new CX_WebToCase();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    Returns the singleton instance
     * @return         CX_WebToCase - a CX_WebToCase singleton instance
     */
	public static CX_WebToCase getInstance() {
		return INSTANCE;
	}

    private CX_WebToCase() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    Calls a queueable class that handles the logic to match contacts to cases using Email AND/OR Phone
     * @param          List<Case> - a list of cases
     */
    public void handleContactMatch(List<Case> cases) {
        List<Case> filteredCases = filterCases(cases);

        if(filteredCases.isEmpty()) {
            return;
        }

        List<List<Case>> caseExecutionList = (List<List<Case>>) CX_CollectionUtils.splitToSubList(filteredCases, Limits.getLimitFutureCalls());
        for(List<Case> subList : caseExecutionList) {
            System.enqueueJob(new CX_ContactMatchQueueable(subList, 'CX_ContactSearchRetrieverGraphQL'));
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    Returns a new list of filtered cases, looking if the Case is from Web or Email to Case and other parameters
     * @param          List<Case> - a list of cases
     * @return         List<Case> - a list of filtered cases
     */
    private List<Case> filterCases(List<Case> cases) {
        List<Case> filteredCases = new List<Case>();

        for(Case record : cases) {
            Boolean isCaseOriginValid = record.Origin == 'WebToCase' || record.CX_EmailToCaseCreated__c;
            Boolean hasEmailOrPhone = String.isNotBlank(record.SuppliedEmail) || String.isNotBlank(record.Phone_Number__c);
            Boolean isContactEmpty = String.isBlank(record.ContactId);

            if(isCaseOriginValid && hasEmailOrPhone && isContactEmpty) {
                filteredCases.add(record);
            }
        }

        return filteredCases;
    }
}
/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        16.06.2021
 * @description    Class used to handle Task Relation Logic
 * @testClass      CX_TaskRelationHadlerTest
 */
public with sharing class CX_TaskRelationHandler {
    private static final CX_TaskRelationHandler INSTANCE = new CX_TaskRelationHandler();
     
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        16.06.2021
     * @description    Returns the singleton instance
     * @return         CX_TaskRelationHandler - a CX_TaskRelationHandler singleton instance
     */
    public static CX_TaskRelationHandler getInstance() {
        return INSTANCE;
    }

    public CX_TaskRelationHandler() {}

    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        16.06.2021
     * @param          transactionCases the cases that updated
     * @param          caseIds Set of the CaseIds that updated
     * @description    Updates the Case.CX_RelatedOpenTaskCount__c with the count of the open task
     *                  related to the Case
     */
    public void updateOpenTaskCount(List<Case> transactionCases,Set<Id> caseIds){
        
        Map<Id,Integer> taskCountMap = CX_TaskDAO.getInstance().getNonClosedTaskCount(caseIds);
        for(Case tCase:transactionCases){
            tcase.CX_RelatedOpenTaskCount__c = taskCountMap.get(tCase.Id);             
        }
    }

}
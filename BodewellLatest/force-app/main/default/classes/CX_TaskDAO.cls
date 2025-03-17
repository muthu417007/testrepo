/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        16.06.2021
 * @description    Class used to keep Task queries
 */
public inherited sharing class CX_TaskDAO {
    private static final CX_TaskDAO INSTANCE = new CX_TaskDAO();

    private CX_TaskDAO() {}
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        16.06.2021
     * @description    Returns the singleton instance
     * @return         CX_TaslDAO - a CX_TaskDAO singleton instance
     */
    public static CX_TaskDAO getInstance() {
		return INSTANCE;
	}

     /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        16.06.2021
     * @description    Returns the count of the case related 
     * @param          Id - Case Id
     * @return         Map<Id,Integer> - Number of the nonClosed related Tasks per Case
     */
    public Map<Id,Integer> getNonClosedTaskCount(Set<Id> caseIds) {
        
        Map<Id,Integer> returnMap = new Map<Id,Integer>(); 
        Set<String> closedStatuses = getTaskClosedTaskStatuses();
        
        AggregateResult[] groupedResults= [
            SELECT whatId, Count(Id)
            FROM Task
            WHERE whatId in :caseIds 
            AND Status not in :closedStatuses
            GROUP BY WhatId];

        for (AggregateResult ar : groupedResults)  {
            returnMap.put((Id)ar.get('WhatId'), (Integer)ar.get('expr0'));
        }
        
        return returnMap;
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        16.06.2021
     * @description    Returns the count of the case related 
     * @param          Id - Case Id
     * @return         Set<String> - A set that contains the Closed Task status APINames
     */
    public Set<String> getTaskClosedTaskStatuses(){
        List<TaskStatus> tStatuses = [SELECT Id,ApiName FROM TaskStatus WHERE IsClosed = true];
        Set<String> closedStatuses = new Set<String>();
        CX_CollectionUtils.loadSet(closedStatuses, 'ApiName', tStatuses);
        return closedStatuses; 
    }
}
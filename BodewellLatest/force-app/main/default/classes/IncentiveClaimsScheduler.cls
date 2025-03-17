/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/27/2022
 * @description    Class used to invoke IncentiveClaimsBatchable class
 */
global class IncentiveClaimsScheduler implements IncentiveClaimsScheduleDispatcher.IScheduleDispatched {
    global void executeTask(SchedulableContext sc) {// overriden method
        ProcessDefinition pd = [Select Id from ProcessDefinition where Name=:SOQL_filter__mdt.getInstance(System.label.Custom_Metadata_Developer_Name).filter__c];
        IncentiveClaimsBatchable batch = new IncentiveClaimsBatchable(pd.Id); 
        database.executebatch(batch, 50);
    }

}
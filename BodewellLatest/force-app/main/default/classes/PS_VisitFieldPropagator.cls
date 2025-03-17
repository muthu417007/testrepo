public class PS_VisitFieldPropagator {

    private static Set<String> accountRecordTypesToProcess = new Set<String> {
        GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT,
        GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR,
        GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL,
        GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL,
        GEA_Constants.RECORD_TYPE_ACCOUNT_PROSPECT,
        GEA_Constants.RECORD_TYPE_ACCOUNT_RESELLER_PROSPECT
    };

	public static void propagateToParentAccount(Map<Id, Visit> newVisits, Map<Id, Visit> oldVisits) {
        Visit[] updatedVisits = new List<Visit>();
        for (Id key : newVisits.keySet()) {
            if(newVisits.get(key).Status != oldVisits.get(key).Status) {
				updatedVisits.add(newVisits.get(key));
            }
        }
        propagateToParentAccount(updatedVisits);
    }

    public static void propagateToParentAccount(List<Visit> newVisits) {
        Map<Id, List<Visit>> visitsByParentId = new Map<Id, List<Visit>>();
        Map<Id, Account> parentAccountsById = new Map<Id, Account>();

        for (Visit v : newVisits) {
            if(visitsByParentId.containsKey(v.AccountId)) {
                visitsByParentId.get(v.AccountId).add(v);
            } else {
                visitsByParentId.put(v.AccountId, new List<Visit>{v});
            }
        }

        for (Account a : [SELECT Last_Visit_Date__c FROM Account WHERE Id IN :visitsByParentId.keySet() AND RecordType.DeveloperName IN :accountRecordTypesToProcess]) {
            DateTime latestLastVisitDate;
            for (Visit v : visitsByParentId.get(a.Id)) {
                if(v.Status == 'Completed' && v.ActualVisitEndTime != null
                  && (latestLastVisitDate == null || v.ActualVisitEndTime > latestLastVisitDate)) {
                    latestLastVisitDate = v.ActualVisitEndTime;
                    a.Last_Visit_Date__c = v.ActualVisitEndTime.date();
                    parentAccountsById.put(a.Id, a);
                }
            }
        }

        if(!parentAccountsById.IsEmpty()) {
            update parentAccountsById.values();
        }
    }

    public static void addVisitTasksWhenVisitsInProgress(Map<Id, Visit> visitNewMap, Map<Id, Visit> visitOldMap) {
        Map<Id, Visit> idToVisitMap = new Map<Id, Visit>();
        Set<Id> retailStoreIds = new Set<Id>();
        Datetime plannedVisitStartTimeMin;
        for (Id visitId : visitNewMap.keySet()) {
            Boolean addVisitToProceed = (
                visitNewMap.get(visitId).Status != visitOldMap.get(visitId).Status
                && visitNewMap.get(visitId).Status == 'InProgress'
                && visitNewMap.get(visitId).Showroom_Display_Location__c != null
            );
            if (addVisitToProceed) {
				idToVisitMap.put(visitId, visitNewMap.get(visitId));
                retailStoreIds.add(visitNewMap.get(visitId).Showroom_Display_Location__c);

                if (plannedVisitStartTimeMin == null) {
                    plannedVisitStartTimeMin = visitNewMap.get(visitId).PlannedVisitStartTime;
                }
                if (visitNewMap.get(visitId).PlannedVisitStartTime < plannedVisitStartTimeMin) {
                    plannedVisitStartTimeMin = visitNewMap.get(visitId).PlannedVisitStartTime;
                }
            }
        }

        if (idToVisitMap.isEmpty()) {
            return;
        }

        List<Visit_Task__c> visitTasksAlreadyAssigned = [
            SELECT Showroom_Display_Location_Action__c, Visit__c
            FROM Visit_Task__c
            WHERE Visit__c IN :idToVisitMap.keySet()
        ];

        Map<Visit, Set<Id>> visitToAssosiatedActionsMap = new Map<Visit, Set<Id>>();
        for (Visit_Task__c visitTaskRecord : visitTasksAlreadyAssigned) {
            if (visitTaskRecord.Showroom_Display_Location_Action__c != null) {
                if (visitToAssosiatedActionsMap.get(idToVisitMap.get(visitTaskRecord.Visit__c)) == null) {
                    visitToAssosiatedActionsMap.put(idToVisitMap.get(visitTaskRecord.Visit__c), new Set<Id>());
                }
                visitToAssosiatedActionsMap.get(
                    idToVisitMap.get(visitTaskRecord.Visit__c)
                ).add(visitTaskRecord.Showroom_Display_Location_Action__c);
            }
        }

        for (Id visitId : visitNewMap.keySet()) {
            if (visitToAssosiatedActionsMap.get(idToVisitMap.get(visitId)) == null) {
                visitToAssosiatedActionsMap.put(idToVisitMap.get(visitId), new Set<Id>());
            }
        }

        Date plannedVisitStartDateMin  = plannedVisitStartTimeMin.date();

        List<Showroom_Display_Location_Action__c> actions = [
            SELECT Id, Task_Name__c, Task_Description__c,
                Task_Type__c, IsRequired__c, Document__c,
                Start_Date__c, End_Date__c, Showroom_Display_Location__c
            FROM Showroom_Display_Location_Action__c
            WHERE Showroom_Display_Location__c IN :retailStoreIds
                AND (
                    (Complete__c = FALSE AND Recurrence__c = 'One Time')
                    OR Recurrence__c = 'Repeat While Active'
                ) AND (
                    (
                        Start_Date__c <= :plannedVisitStartDateMin
                        AND End_Date__c >= :plannedVisitStartDateMin
                    ) OR (
                        Start_Date__c >= :plannedVisitStartDateMin
                    )
                )
        ];

        insert getVisitTaskToCreateList(actions, visitToAssosiatedActionsMap);
    }

    private static List<Visit_Task__c> getVisitTaskToCreateList(
        List<Showroom_Display_Location_Action__c> actions, Map<Visit, Set<Id>> visitToAssosiatedActionsMap
    ) {
        List<Visit_Task__c> visitTasksToCreate = new List<Visit_Task__c>();

        for (Showroom_Display_Location_Action__c action : actions) {
            for (Visit visitRecord : visitToAssosiatedActionsMap.keySet()) {
                Boolean createTask = (
                    visitRecord.Showroom_Display_Location__c == action.Showroom_Display_Location__c
                    && !visitToAssosiatedActionsMap.get(visitRecord).contains(action.Id)
                    && action.Start_Date__c <= visitRecord.PlannedVisitStartTime
                    && action.End_Date__c >= visitRecord.PlannedVisitStartTime
                );
                if (createTask) {
                    visitTasksToCreate.add(
                        new Visit_Task__c(
                            Task_Name__c = action.Task_Name__c,
                            Task_Description__c = action.Task_Description__c,
                            Task_Type__c = action.Task_Type__c,
                            IsRequired__c = action.IsRequired__c,
                            Visit__c = visitRecord.Id,
                            Showroom_Display_Location_Action__c = action.Id,
                            Document__c = action.Document__c
                        )
                    );
                }
            }
        }

        return visitTasksToCreate;
    }

}
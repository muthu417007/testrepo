public class PS_ActivityFieldPropagator {

    private static Set<String> accountRecordTypesToProcess = new Set<String> {
        GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT,
        GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR,
        GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL,
        GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL,
        GEA_Constants.RECORD_TYPE_ACCOUNT_PROSPECT,
        GEA_Constants.RECORD_TYPE_ACCOUNT_RESELLER_PROSPECT
    };
        
    public static void propagateValuesToParent(Map<Id, Task> newTasks, Map<Id, Task> oldTasks) {
		
        Task[] updatedTasks = new List<Task>();
        for (String key : newTasks.keySet()) {
            if(newTasks.get(key).Status != oldTasks.get(key).Status) {
 				updatedTasks.add(newTasks.get(key));
            }
        }
        propagateValuesToParent(updatedTasks);
	}

    public static void propagateValuesToParent(List<Task> newTasks) {
        Map<Id, List<Task>> tasksByParentId = new Map<Id, List<Task>>();
        Map<Id, Account> parentAccountsById = new Map<Id, Account>();

        for (Task t : newTasks) {
            if(t.WhatId != null && String.valueOf(t.WhatId).StartsWith('001')) {
                if(tasksByParentId.containsKey(t.WhatId)) {
                    tasksByParentId.get(t.WhatId).add(t);
                } else {
                    tasksByParentId.put(t.WhatId, new List<Task>{t});
                }
            }
        }
        
        for (Account a : [SELECT Last_Call_Date__c FROM Account WHERE Id IN :tasksByParentId.keySet() AND RecordType.DeveloperName IN :accountRecordTypesToProcess]) {
            for (Task t : tasksByParentId.get(a.Id)) {
                if(t.Status == 'Complete' && t.TaskSubtype == 'Call') {
                    a.Last_Call_Date__c = System.today();
                    parentAccountsById.put(a.Id, a);
                }
            }
        }

        if(!parentAccountsById.IsEmpty()) {
            update parentAccountsById.values();
        }
    }
}
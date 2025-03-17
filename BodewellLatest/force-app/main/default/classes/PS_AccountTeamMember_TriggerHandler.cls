public class PS_AccountTeamMember_TriggerHandler implements PS_ITriggerHandler {
    
    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {}

    public void afterInsert(List<SObject> newItems) {}

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterDelete(Map<Id, SObject> oldItems) {
        new PS_ShareRecordsToAccountTeamMembers().deleteShares((List<AccountTeamMember>) oldItems.values());
    }
}
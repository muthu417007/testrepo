public class PS_AccountTriggerHandler implements PS_ITriggerHandler {
    
    public static Boolean TriggerDisabled = false;
    public static Boolean relatedAccountsPopulated = false;
    
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<SObject> newItems) {
        PS_AccountRecordTypeSetter.setRecordTypes((List<Account>) newItems);
        PS_AccountRecordTypeSetter PS_AccountRecordTypeSetter = new PS_AccountRecordTypeSetter();
        PS_AccountRecordTypeSetter.setContactsGlobalIds((List<Account>) newItems);
        PS_RelatedAccountsPropagator.populateCurrentAccounts((List<Account>) newItems);
        CX_LocationAccount.getInstance().fillAddressIndexedFields((List<Account>) newItems);
    }
    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        PS_AccountRecordTypeSetter.setRecordTypes((Map<Id, Account>) newItems, (Map<Id, Account>) oldItems);
        PS_RelatedAccountsPropagator.populateCurrentAccounts((Map<Id, Account>) newItems, (Map<Id, Account>) oldItems);
        new PS_AccountRecreateTeamMembers().findAndRecreateMembers((List<Account>) newItems.values(), (Map<Id, Account>) oldItems);
        CX_LocationAccount.getInstance().fillAddressIndexedFields((List<Account>) newItems.values());
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems) {
        PS_RelatedAccountsPropagator.handleAccountsOnBeforeDelete((Map<Id, Account>) oldItems);
    }
    
    public void afterInsert(List<SObject> newItems) {
        if (relatedAccountsShouldBePopulated()) {
            PS_RelatedAccountsPropagator.populateRelatedAccounts((List<Account>) newItems);
        }
        PS_AccountExternalIdSetter.setExternalId((List<Account>) newItems);
        
        CX_LocationAccount.getInstance().updateLocationZoneRegion((List<Account>) newItems);
    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        if (relatedAccountsShouldBePopulated()) {
            PS_RelatedAccountsPropagator.populateRelatedAccounts((Map<Id, Account>) newItems, (Map<Id, Account>) oldItems);
        }
        PS_AccountExternalIdSetter.setExternalId((List<Account>) newItems.values());
        
        CX_LocationAccount.getInstance().updateLocationZoneRegion((List<Account>)newItems.values());
    }
    
    public void afterDelete(Map<Id, SObject> oldItems) {
        PS_RelatedAccountsPropagator.populateRelatedAccounts((List<Account>) oldItems.values());
    }
    
    private Boolean relatedAccountsShouldBePopulated() {
        return (
            (
                Trigger.operationType == TriggerOperation.AFTER_INSERT ||
                Trigger.operationType == TriggerOperation.AFTER_UPDATE
            ) &&
            !relatedAccountsPopulated &&
            !System.isBatch() &&
            Trigger.newMap.size() <= 5
        );
    }
    
}
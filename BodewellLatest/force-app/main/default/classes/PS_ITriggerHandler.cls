public interface PS_ITriggerHandler {
    void beforeInsert(List<SObject> newItems);
    void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    void beforeDelete(Map<Id, SObject> oldItems);
    void afterInsert(List<SObject> newItems);
    void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    void afterDelete(Map<Id, SObject> oldItems);
    Boolean IsDisabled();
}
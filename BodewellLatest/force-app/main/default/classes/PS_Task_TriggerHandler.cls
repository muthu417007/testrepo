public class PS_Task_TriggerHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems) {      
    }

    public void afterInsert(List<SObject> newItems) {
        PS_ActivityFieldPropagator.propagateValuesToParent((List<Task>) newItems);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        PS_ActivityFieldPropagator.propagateValuesToParent((Map<Id, Task>) newItems, (Map<Id, Task>) oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
    }
}
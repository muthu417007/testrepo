public class PS_Visit_TriggerHandler implements PS_ITriggerHandler {

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
        PS_VisitFieldPropagator.propagateToParentAccount((List<Visit>) newItems);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        PS_VisitFieldPropagator.propagateToParentAccount((Map<Id, Visit>) newItems, (Map<Id, Visit>) oldItems);
        PS_VisitFieldPropagator.addVisitTasksWhenVisitsInProgress((Map<Id, Visit>) newItems, (Map<Id, Visit>) oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
    }

}
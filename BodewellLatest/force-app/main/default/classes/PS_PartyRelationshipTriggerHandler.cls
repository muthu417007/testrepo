public class PS_PartyRelationshipTriggerHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }
       
    public void beforeInsert(List<SObject> newItems) {
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void afterInsert(List<SObject> newItems) {
        PS_PartyRelationshipPropagator.propagateToPartyChildRecordsOnInsert(newItems);
    }
 
    public void beforeDelete(Map<Id, SObject> oldItems) {      
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        PS_PartyRelationshipPropagator.propagateToPartyChildRecordsOnUpdate((Map<Id, Party_Relationship__c>) newItems, (Map<Id, Party_Relationship__c>) oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
		PS_PartyRelationshipPropagator.propagateToPartyChildRecordsOnPartyDelete((List<Party_Relationship__c>) oldItems.values());
    }
}
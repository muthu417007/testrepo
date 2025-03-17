trigger PS_PartyRelationshipTrigger on Party_Relationship__c (after insert, after update, after delete) {
	if ((Trigger.isInsert || Trigger.isUpdate) 
        && Trigger.newMap.size() > 5) {
		return;
    }
	PS_TriggerDispatcher.run(new PS_PartyRelationshipTriggerHandler());
}
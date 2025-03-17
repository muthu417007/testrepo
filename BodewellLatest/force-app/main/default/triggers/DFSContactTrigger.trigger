trigger DFSContactTrigger on Contact_From_DFS__c (after update, before update, before insert, after insert) {
	PS_TriggerDispatcher.run(new DFSContactHandler());
}
trigger PS_RelatedItem on Related_Items__c (after insert, after update, after delete) {
	PS_TriggerDispatcher.run(new PS_RelatedItems_TriggerHandler());
}
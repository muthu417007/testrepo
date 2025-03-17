trigger PS_RetailStore on RetailStore (before delete, after delete) {
	PS_TriggerDispatcher.run(new PS_RetailStoreTriggerHandler());
}
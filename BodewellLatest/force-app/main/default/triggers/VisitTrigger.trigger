trigger VisitTrigger on Visit (after update, after insert) {
	PS_TriggerDispatcher.run(new PS_Visit_TriggerHandler());
}
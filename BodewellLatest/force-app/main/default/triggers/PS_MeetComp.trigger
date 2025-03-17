trigger PS_MeetComp on Meet_Comp__c (before insert, after insert, before update, before delete) {
	PS_TriggerDispatcher.run(new PS_MeetComp_TriggerHandler());
}
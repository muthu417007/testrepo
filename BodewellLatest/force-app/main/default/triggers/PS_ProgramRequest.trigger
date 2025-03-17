trigger PS_ProgramRequest on Program_Request__c (after insert, before delete) {
    PS_TriggerDispatcher.run(new PS_ProgramRequest_TriggerHandler());
}
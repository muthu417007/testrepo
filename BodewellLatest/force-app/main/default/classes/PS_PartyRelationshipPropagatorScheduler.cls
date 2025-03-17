global class PS_PartyRelationshipPropagatorScheduler implements PS_PartyRelationshipPropagatorDispatcher.IScheduleDispatched {
    global void execute(SchedulableContext SC) {
        PS_PartyRelationshipPropagatorBatchable batch = new PS_PartyRelationshipPropagatorBatchable(); 
        database.executebatch(batch, 50);
    }
}
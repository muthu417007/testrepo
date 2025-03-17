global class PS_PartyRelationshipPropagatorDispatcher Implements Schedulable {

    public Interface IScheduleDispatched {
        void execute(SchedulableContext sc);
    }

    global void execute(SchedulableContext sc) {
        Type targettype = Type.forName('PS_PartyRelationshipPropagatorScheduler');
        if (targettype != null) {
            IScheduleDispatched obj = (IScheduleDispatched)targettype.NewInstance();
            obj.execute(sc);
        }
    }
}
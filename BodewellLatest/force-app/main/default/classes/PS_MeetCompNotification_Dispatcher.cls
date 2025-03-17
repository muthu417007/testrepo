global class PS_MeetCompNotification_Dispatcher Implements Schedulable {

    public Interface IScheduleDispatched {
        void execute(SchedulableContext sc);
    }

    global void execute(SchedulableContext sc) {
        Type targettype = Type.forName('PS_MeetCompNotification_Scheduler');
        if (targettype != null) {
            IScheduleDispatched obj = (IScheduleDispatched)targettype.NewInstance();
            obj.execute(sc);
        }
    }
}
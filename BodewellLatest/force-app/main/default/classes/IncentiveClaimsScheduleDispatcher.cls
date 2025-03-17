/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/27/2022
 * @description    Dispatcher class used to separate main code from the schedulable class.
 */
global class IncentiveClaimsScheduleDispatcher implements Schedulable {
    public Interface IScheduleDispatched { // Interface to be implemented by the class having the logic.
        void executeTask(SchedulableContext sc); //method to be overriden by the class implementing the interface.
    }
    global void execute(SchedulableContext sc){
        Type targettype = Type.forName('IncentiveClaimsScheduler');
        if(targettype!=null){
            IScheduleDispatched obj = (IScheduleDispatched)targettype.newInstance();
            obj.executeTask(sc);
        }
    }

}
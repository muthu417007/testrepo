public class PS_ShareRecordsToAtmFullRecalcSched implements Schedulable {

    public void execute(SchedulableContext sc) {
        new PS_ShareRecordsToAtmBatchDispatcher().dispatch();
    }

}
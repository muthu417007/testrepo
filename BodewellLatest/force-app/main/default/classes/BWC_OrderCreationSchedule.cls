public class BWC_OrderCreationSchedule implements schedulable{
	public void execute(SchedulableContext sc) {
        Id jobId = Database.executeBatch(new BWC_OrderCreationBatch());
    }
}
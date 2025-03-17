public class BWC_ProducDataLoadBatch implements Database.Batchable<sObject> {
    private String query;
    private String target;
    private BWC_ProducDataLoadBatch nextBatchType;

    public void setNextBatch(BWC_ProducDataLoadBatch l_type){
        this.nextBatchType = l_type;
    }
    
    public BWC_ProducDataLoadBatch(String query, String target) {
        this.query = query;
        this.target = target;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        BWC_ProductDataLoadHelper.routeCalls(scope, target);
    }
    
    public void finish(Database.BatchableContext bc) {
        BWC_ProductDataLoadHelper.SendEmail(bc.getJobId());
        if (nextBatchType != null && target=='CommerceEntitlementProduct') {
      		Database.executeBatch(nextBatchType,Integer.valueOf(Label.BWC_CommerceEntitlementProduct_BatchSize));
        }
        else if (nextBatchType != null){
            Database.executeBatch(nextBatchType,Integer.valueOf(Label.BWC_ProductLoad_BatchSize));
        } 
    }
}
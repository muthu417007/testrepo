public class PS_PriorityActionsCreatorQueueable implements Queueable {
    public final List<Id> retailStoreIds;
    public final Id parentId;

    public PS_PriorityActionsCreatorQueueable(List<Id> retailStoreIds, Id parentId) {
        this.retailStoreIds = retailStoreIds;
        this.parentId = parentId;
    }

    public void execute(QueueableContext context) {
        try {
            Priority_and_Action__c paa = [
                SELECT Task_Name__c, Task_Description__c, Task_Type__c, IsRequired__c,
                    Start_Date__c, End_Date__c, Document__c, Recurrence__c
                FROM Priority_and_Action__c
                WHERE Id = :parentId
            ];

            List<Showroom_Display_Location_Action__c> actions = new List<Showroom_Display_Location_Action__c>();
            for (Id rsId : retailStoreIds) {
                Showroom_Display_Location_Action__c action = new Showroom_Display_Location_Action__c (
                    Showroom_Display_Location__c = rsId,
                    Priority_and_Action__c = parentId,
                    Task_Name__c = paa.Task_Name__c,
                    Task_Description__c = paa.Task_Description__c,
                    Task_Type__c = paa.Task_Type__c,
                    IsRequired__c = paa.IsRequired__c,
                    Start_Date__c = paa.Start_Date__c,
                    End_Date__c = paa.End_Date__c,
                    Document__c = paa.Document__c,
                    Recurrence__c = paa.Recurrence__c
                );
                actions.add(action);
            }
            insert actions;

        } catch (Exception ex) {
           	AsyncApexJob a = [SELECT Status, CreatedBy.Email FROM AsyncApexJob WHERE Id =:context.getJobId()];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Priority Actions Creation finished with the following status ' + a.Status);
            mail.setPlainTextBody(ex.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
    }
}
global class PS_PartyRelationshipPropagatorBatchable implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String queryFilter = !Test.isRunningTest() ? Label.PS_PrBatchQueryFilter : 'WHERE LastModifiedDate > YESTERDAY ORDER BY Party__c';
        return Database.getQueryLocator(
            'SELECT Id, Party__c FROM Party_Relationship__c ' + queryFilter);
    }

    global void execute(Database.BatchableContext bc, List<Party_Relationship__c> scope) {
        PS_PartyRelationshipPropagator.propagateToPartyChildRecordsOnInsert(scope);
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Scheduled Job: Party Relationship Propagator ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        Database.executebatch(new PS_RelatedAccountsPropagatorBatch(), 30);
    }
}
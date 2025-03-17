public class PS_RelatedAccountsPropagatorBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Set<Id> parentAccountIdsToProcessInAxularyBatch = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryFilter = !Test.isRunningTest()
            ? Label.PS_ACCOUNT_BATCH_QUERY_FILTER
            : 'WHERE LastModifiedDate > YESTERDAY';

        Set<String> accountPartyLogicFields = new Set<String>();
        for (PS_AccountPartyLogic__mdt apl : [SELECT FieldName__c FROM PS_AccountPartyLogic__mdt]) {
            accountPartyLogicFields.add(apl.FieldName__c);
        }
        String aplFeldsQueryPart = String.join(new List<String>(accountPartyLogicFields), ', ');

        String query = 'SELECT Id, ParentId, RecordTypeId';
        if (String.isNotBlank(aplFeldsQueryPart)) {
            query += ', ' + aplFeldsQueryPart;
        }

        Set<String> recordTypeNamesToSelect = new Set<String>{
            GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY,
            GEA_Constants.RECORD_TYPE_ACCOUNT_SITE
        };

        String wherePartRecordTypes = 'RecordType.DeveloperName IN :recordTypeNamesToSelect';
        if (String.isNotBlank(queryFilter)) {
            queryFilter += ' AND ' + wherePartRecordTypes;
        } else {
            queryFilter = 'WHERE ' + wherePartRecordTypes;
        }

        query += ' FROM Account ' + queryFilter;
        System.debug('QUERY ' + query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        PS_RelatedAccountsPropagator.populateRelatedAccounts(scope, parentAccountIdsToProcessInAxularyBatch);
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id = :BC.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Scheduled Job: Related Accounts Propagator ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        if (this.parentAccountIdsToProcessInAxularyBatch.size() > 0) {
            runRelatedAccountsAuxiliaryBatch(this.parentAccountIdsToProcessInAxularyBatch);
        }
    }

    public static void runRelatedAccountsAuxiliaryBatch(Set<Id> parentAccountIds) {
        Database.executeBatch(
            new PS_RelatedAccountsAuxiliaryBatch(parentAccountIds)
        );
    }

}
public with sharing class PS_SetCustomerIdPSessionIdBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
         String query = 'SELECT Id FROM User WHERE Customer_IdP_Session_Id__c = NULL AND IsPortalEnabled = TRUE '+(Test.isRunningTest()?' LIMIT 200':'');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext param1, List<SObject> users) {
        new PS_CustomerSessionIdService().generateSessionIdValue(
                (List<User>) users,
                true
        );
    }

    public void finish(Database.BatchableContext param1) {
    }
}
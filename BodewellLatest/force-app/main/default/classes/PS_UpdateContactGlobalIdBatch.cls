public with sharing class PS_UpdateContactGlobalIdBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Global_Customer_Id__c, CreatedDate FROM Contact WHERE Global_Customer_Id__c = NULL';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext param1, List<SObject> contacts) {
        PS_ContactTriggerHandlerHelper psContactTriggerHandlerHelper =
                new PS_ContactTriggerHandlerHelper(true);
        psContactTriggerHandlerHelper.setContactsGlobalIds((List<Contact>) contacts);
        update contacts;
    }

    public void finish(Database.BatchableContext param1) {
    }

}
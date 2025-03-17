trigger PS_CustomerAgreement on Customer_Agreement__c (after insert, after update, before delete, after delete) {
    PS_TriggerDispatcher.run(new PS_CustomerAgreement_TriggerHandler());
}
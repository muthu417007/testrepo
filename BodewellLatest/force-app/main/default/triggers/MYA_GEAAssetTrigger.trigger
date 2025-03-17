trigger MYA_GEAAssetTrigger on GEA_Asset__c (before insert) {
    PS_TriggerDispatcher.run(new MYA_GEATriggerHandler());
}
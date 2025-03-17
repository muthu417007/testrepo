trigger AccountTrigger on Account (before insert, after insert, before update, after update, after delete, before delete) {
    PS_TriggerDispatcher.run(new PS_AccountTriggerHandler());

    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            PA_SyncAccountAddressTriggerHandler.updateContactPointAddressOnAccountChanges(Trigger.new, Trigger.oldMap);
        }
    }
}
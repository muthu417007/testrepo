trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete) {
    PS_TriggerDispatcher.run(new PS_UserTriggerHandler());
}
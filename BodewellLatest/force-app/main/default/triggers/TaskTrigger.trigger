trigger TaskTrigger on Task (after insert, after update,before delete) {
    if(Trigger.isAfter && (Trigger.isInsert||Trigger.isUpdate))
    {
    
	PS_TriggerDispatcher.run(new PS_Task_TriggerHandler());
    }
     if(Trigger.isBefore) {
        System.debug('Inside the Trigger');
        TaskHelper.NoDeleteTask (Trigger.Old);
    }
       }
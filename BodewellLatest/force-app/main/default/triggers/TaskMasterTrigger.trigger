/*
Purpose: It is master trigger for the task object. All the task and related object custom automation should include here.
written by: Prasun Dixit
Developed on: June/17/2020
Handler: TaskMasterTriggerHandler
*/
trigger TaskMasterTrigger on Task (before insert, before update) {
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert))
    {
        TaskMasterTriggerHandler.markPublic(trigger.new);
    }
}
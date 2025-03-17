/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        25.05.2021
 * @description    Case trigger that calls a trigger handler if active on custom setting
 */
trigger CX_CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete) {
    if(CX_TriggerSwitch.isTriggerActive('CX_CaseTrigger')) {
        CX_TriggerHandler.execute(new CX_CaseTriggerHandler());
    }
    if(trigger.isBefore && (trigger.isInsert||trigger.isUpdate)){
    CaseHandler.phNum(Trigger.New);
    CaseHandler.AltphNum(Trigger.New);
    }
}
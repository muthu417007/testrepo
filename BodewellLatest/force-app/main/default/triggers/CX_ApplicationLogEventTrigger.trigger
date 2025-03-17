/**
 * Author:        Matheus Lopes
 * Company:       GE Appliances
 * Zone:          North America
 * Description:
 * History
 * 05.11.2021     Matheus Lopes     initial implementation
 */
 trigger CX_ApplicationLogEventTrigger on CX_ApplicationLogEvents__e (after insert) {
    //  TODO: Use a trigger handler framework
    CX_ApplicationLogEventTriggerHandler.afterInsert(Trigger.new);
}
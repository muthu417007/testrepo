/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/29/2022
 * @description    Trigger for Incentive Claim trigger. Used Trigger framework for separating the code.
 */
trigger IncentiveClaimTrigger on Incentive_Claim__c (before insert, after insert, before update, after update, before delete, after delete) {
    PS_TriggerDispatcher.run(new IncentiveClaim_TriggerHandler());

}
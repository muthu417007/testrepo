/**
 * Helper class for checking if trigger is active
 */
public with sharing class CX_TriggerSwitch {

    private CX_TriggerSwitch() {}

    /**
     * isTriggerActive is trigger active
     * @param  triggerName trigger name
     * @return             return boolean if trigger is active
     */
    public static Boolean isTriggerActive(String triggerName){
        Boolean isTriggerActive = (Boolean) TriggerSwitch__c.getInstance(UserInfo.getUserId()).get(triggerName + '__c');
        isTriggerActive = isTriggerActive == null ? true : isTriggerActive;
        return isTriggerActive;
    }
}
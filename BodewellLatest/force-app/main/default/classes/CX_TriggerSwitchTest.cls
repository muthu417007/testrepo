/**
 * Author:        Karlo Lorenzana
 * Company:       GE Appliances
 * Zone:          North America
 * Description:   Class responsible for testing trigger switch
 * History
 * 2021.05.18     Karlo Lorenzana     initial implementation
**/
@IsTest
public with sharing class CX_TriggerSwitchTest {

    @TestSetup
    static void setupData(){
        TriggerSwitch__c triggerSwitch = new TriggerSwitch__c(ContactTrigger__c = false);
        insert triggerSwitch;
    }

    /**
     * Test case:
     * 1. Check whether Trigger Switch of Account Trigger is active
     * 2. Should return true
     */
    @IsTest
    static void shouldCheckIfTriggerIsActive() {
        //WHEN
        Boolean isTriggerActive = CX_TriggerSwitch.isTriggerActive('AccountTrigger');
        //THEN
        System.assertEquals(true, isTriggerActive );
    }

    /**
     * Test case:
     * 1. Check whether Trigger Switch of Case Trigger is active
     * 2. Should return false
     */
    @IsTest
    static void shouldCheckIfTriggerIsInactive() {
        //WHEN
        Boolean isTriggerActive = CX_TriggerSwitch.isTriggerActive('ContactTrigger');
        //THEN
        System.assertEquals(false, isTriggerActive );
    }

    /**
     * Test case:
     * 1. Check whether Trigger Switch of random Trigger (not existed) is active
     * 2. Should return null
     */
    @IsTest
    static void shouldFailWhenNonExistingTriggerName() {
        //WHEN
        Boolean isTriggerActive;
        try {
            isTriggerActive = CX_TriggerSwitch.isTriggerActive('NotATrigger');
        }
        catch(SObjectException ex){
            System.debug(ex.getMessage());
        }
        //THEN
        System.assertEquals(null, isTriggerActive );
    }

    /**
     * Test case:
     * 1. Get SObjectType of 'TriggerSwitch__c'
     * 2. Get fields of 'TriggerSwitch__c' SObjectType
     * 3. Get the fields when FieldName contains 'Trigger__c' and not 'CaseTrigger'
     * 4. Check whether Trigger Switch is active in other trigger beside Case
     * 5. Case Trigger Switch should be deactivated, and other trigger should be active
     */
    @IsTest
    static void shouldDeactivateOnlyOneTrigger(){
        //GIVEN
        SObjectType triggerSwitchObjectType = Schema.getGlobalDescribe().get('TriggerSwitch__c');
        Map<String, SObjectField> fields = triggerSwitchObjectType.getDescribe().fields.getMap();

        Set<String> triggerNames = new Set<String>();
        for(String s : fields.keySet())
        {
            String fieldName = fields.get(s).getDescribe().getName();
            if(fieldName.contains('Trigger__c') && fieldName != 'ContactTrigger__c'){
                triggerNames.add(fieldName.removeEnd('__c'));
            }
        }
        //WHEN
        Boolean isContactTriggerActive = CX_TriggerSwitch.isTriggerActive('ContactTrigger');

        Set<Boolean> isOtherTriggersActive = new Set<Boolean>();
        for(String triggerName : triggerNames){
            isOtherTriggersActive.add(CX_TriggerSwitch.isTriggerActive(triggerName));
        }
        //THEN
        System.assertEquals(false, isContactTriggerActive);

        for(Boolean activeFlag : isOtherTriggersActive){
            System.assertEquals(true, activeFlag);
        }
    }
}
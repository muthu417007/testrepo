/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        25.05.2021
 * @description    Class used to organize the Case trigger using the Trigger Handler pattern
 */
public with sharing class CX_CaseTriggerHandler extends CX_TriggerHandler.DelegateBase {
    
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        16.06.2021
     * @description    Method to execute on the before update of a Case
     * @param          Map<Id, sObject> - a map containing old Cases
     * @param          Map<Id, sObject> - a map containing new Cases
    */
    public override void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        CX_TaskRelationHandler.getInstance().updateOpenTaskCount((List<Case>)newMap.values(),newMap.keySet());
        system.debug('@@@@ inside beforeUpdate - OldMap: '+oldMap.values());
        system.debug('@@@@ inside beforeUpdate - NewMap: '+newMap.values());
    }
    /**
     * @author         Gabriel Alves
     * @company        PolSource
     * @created        02.06.2021
     * @description    Method to execute on the after insert of a Case
     * @param          Map<Id, sObject> - a map containing new Cases
    */
    public override void afterInsert(Map<Id, sObject> newMap) {
        CX_WebToCase.getInstance().handleContactMatch((List<Case>)newMap.values());
        system.debug('@@@@ inside afterInsert: '+newMap.values()); 
        if (EmailToCaseContact.runOnce()) {
            system.debug('@@@@ inside afterInsert EmailToCaseContact: '+newMap.values());
            EmailToCaseContact handler = new EmailToCaseContact();
            handler.updatecase((List<Case>) newMap.values());
        }

        CX_WebToCaseContact webToCaseHandler = new CX_WebToCaseContact();
        // webToCaseHandler.updateWebCase((List<Case>) newMap.values());

        CX_LocationAccount.getInstance().updateCaseLocationZoneRegion((List<Case>)newMap.values());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Method to execute on the after update of a Case
     * @param          Map<Id, sObject> - a map containing old Cases
     * @param          Map<Id, sObject> - a map containing new Cases
    */
    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        CX_LocationAccount.getInstance().updateCaseLocationZoneRegion((List<Case>)newMap.values());
        system.debug('@@@@ inside afterUpdate - OldMap: '+oldMap.values());
         system.debug('@@@@ inside afterUpdate - NewMap: '+newMap.values()); 
    }
}
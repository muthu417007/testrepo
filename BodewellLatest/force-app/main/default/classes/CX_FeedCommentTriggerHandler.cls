/**
 * @author         Karlo Lorenzana
 * @company        PolSource
 * @created        22.06.2021
 * @description    Class used to organize the Feed comments trigger using the Trigger Handler pattern
 */
public with sharing class CX_FeedCommentTriggerHandler extends CX_TriggerHandler.DelegateBase {
    /**
     * @author         Karlo Lorenzana
     * @company        PolSource
     * @created        22.06.2021
     * @description    Method to execute on the after insert of a Feed comment
     * @param          Map<Id, sObject> - a map containing new feed comments
    */
    public override void afterInsert(Map<Id, sObject> newMap) {
        CX_UpdateKAVFeedback.updateFeedbacks((Map<Id, FeedComment>)newMap);
    }

    /**
     * @author         Karlo Lorenzana
     * @company        PolSource
     * @created        22.06.2021
     * @description    Method to execute on the after update of a Feed comment
     * @param          Map<Id, sObject> - a map containing old feed comments
     * @param          Map<Id, sObject> - a map containing new feed comments
    */
    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        CX_UpdateKAVFeedback.updateFeedbacks((Map<Id, FeedComment>)newMap);
    }    
}
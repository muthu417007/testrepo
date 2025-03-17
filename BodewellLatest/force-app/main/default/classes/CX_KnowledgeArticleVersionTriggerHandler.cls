/**
 * @author         Karlo Lorenzana
 * @company        PolSource
 * @created        22.06.2021
 * @description    Class used to organize the Knowledge article versions trigger using the Trigger Handler pattern
 */
public with sharing class CX_KnowledgeArticleVersionTriggerHandler extends CX_TriggerHandler.DelegateBase {
    /**
     * @author         Karlo Lorenzana
     * @company        PolSource
     * @created        22.06.2021
     * @description    Method to execute on the after insert of a Knowledge article version
     * @param          Map<Id, sObject> - a map containing new KAVs
    */
    public override void afterInsert(Map<Id, sObject> newMap) {
        CX_UpdateKAVFeedback.updateFeedbacks((Map<Id, Knowledge__kav>)newMap);
    }

    /**
     * @author         Karlo Lorenzana
     * @company        PolSource
     * @created        22.06.2021
     * @description    Method to execute on the after update of a Case
     * @param          Map<Id, sObject> - a map containing old KAVs
     * @param          Map<Id, sObject> - a map containing new KAVs
    */
    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        CX_UpdateKAVFeedback.updateFeedbacks((Map<Id, Knowledge__kav>)newMap);
    }    
}
/**
 * @author         Karlo Lorenzana
 * @company        PolSource
 * @created        22.06.2021
 * @description    Class used to Update the KAVs feedbacks
 */
public with sharing class CX_UpdateKAVFeedback {
    
    /**
     * @author         Karlo Lorenzana
     * @company        PolSource
     * @created        22.06.2021
     * @description    Makes the update to the feedback records associated to KAVs.
     * @param          Map<Id,Knowledge__kav> - a list containing KAVs
    */
    public static void updateFeedbacks(Map<Id,Knowledge__kav> knowledgeVersions){
        updateLastModifiedDate(knowledgeVersions);
    }

    /**
     * @author         Karlo Lorenzana
     * @company        PolSource
     * @created        22.06.2021
     * @description    Makes the update to the feedback records associated to feed comments.
     * @param          Map<Id,Knowledge__kav> - a list containing KAVs
    */
    public static void updateFeedbacks(Map<Id,FeedComment> feedComments){
        updateLastModifiedDate(feedComments);
    }

    private static void updateLastModifiedDate(Map<Id,Knowledge__kav> knowledgeVersions){
        Set<Id> knowledgeArticlesVersions = new Set<Id>();
        for (Knowledge__kav version : knowledgeVersions.values()) {
            knowledgeArticlesVersions.add(version.KnowledgeArticleId);
        }
        //Get Articles versions
        List<Knowledge__kav> versions = [
            SELECT 
                Id
            FROM 
                Knowledge__kav
            WHERE 
                KnowledgeArticleId IN :knowledgeArticlesVersions
        ];
        List<Id> versionsIds = new List<Id>();
        for (Knowledge__kav version : versions) {
            versionsIds.add(version.Id);
        }
        //Get Articles feedbacks
        List<Knowledge_Feedback__c> feedbacks = [
            SELECT 
                Id
            FROM
                Knowledge_Feedback__c
            WHERE 
                Knowledge_Article__c IN :versionsIds
        ];
        for (Knowledge_Feedback__c feedback : feedbacks) {
            feedback.cx_Chatter_Updates__c = System.now();
        }
        update feedbacks;
    }

    private static void updateLastModifiedDate(Map<Id,FeedComment> feedComments){
        Set<Id> feedbackIds = new Set<Id>();
        for (FeedComment comment : feedComments.values()) {
            feedbackIds.add(comment.ParentId);
        }
        //Get Articles feedbacks
        List<Knowledge_Feedback__c> feedbacks = [
            SELECT 
                Id
            FROM
                Knowledge_Feedback__c
            WHERE 
                Id IN :feedbackIds
        ];
        for (Knowledge_Feedback__c feedback : feedbacks) {
            feedback.cx_Chatter_Updates__c = System.now();
        }
        update feedbacks;
    }
}
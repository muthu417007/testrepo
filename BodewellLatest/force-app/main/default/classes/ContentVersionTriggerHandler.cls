public with sharing class ContentVersionTriggerHandler {

    public static void createPublicLinkForFile(List<ContentVersion> contentVersions){
        ContentDistribution[] distributionsToInsert = new List<ContentDistribution>();
        Set<Id> contentDocId = new Set<Id>();
        for(ContentVersion objContentVersion : contentVersions){
            contentDocId.add(objContentVersion.ContentDocumentId);
        }
        for(ContentVersion objContentVersion : contentVersions){
           distributionsToInsert.add(createContentDistribution(objContentVersion.Id));
        }
        insert distributionsToInsert;
    }

    public static ContentDistribution createContentDistribution(Id contentVersionId){
        ContentDistribution newDist = new ContentDistribution();
        newDist.ContentVersionId = contentVersionId;
        newDist.Name = 'External Link';
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        return newDist;
    }
}
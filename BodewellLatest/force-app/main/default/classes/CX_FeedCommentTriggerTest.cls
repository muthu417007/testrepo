@isTest
public with sharing class CX_FeedCommentTriggerTest {
    @IsTest
    static void insertFeedComment(){
        Knowledge_Feedback__c feedback = new Knowledge_Feedback__c();
        insert feedback;
        FeedItem item = new FeedItem(ParentId = feedback.id, Body = 'test body');
        insert item;
        FeedComment comment = new FeedComment(
            FeedItemId = item.Id,
            CommentBody = 'test comment body'
        );        
        insert comment;
        update comment;
    }
}
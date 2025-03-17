global class TestKnowledgeToDraft implements Database.Batchable<sObject>{
    private String publishStatus;
    global TestKnowledgeToDraft(String status){
        publishStatus=status;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,KnowledgeArticleId FROM Knowledge__kav where publishstatus=:publishStatus]);
    }
    
    global void execute(Database.BatchableContext BC, List<Knowledge__kav> scope){        
        for(Knowledge__kav article : scope){
            if(publishStatus=='Online')
            	KBManagement.PublishingService.editOnlineArticle(article.KnowledgeArticleId, true);
            else if(publishStatus=='Draft')
            	KBManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }    
}
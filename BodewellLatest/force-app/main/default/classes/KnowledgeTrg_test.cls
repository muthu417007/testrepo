@isTest
private class KnowledgeTrg_test {
    
    @isTest
    static void test1() {       
        Knowledge__kav  testArticle = new Knowledge__kav();
        testArticle.Title = 'Test Prod Info';
        testArticle.Summary = 'Test Summary';
        testArticle.URLName = 'Test';
        insert testArticle ;
        
        Knowledge__kav testRec = [SELECT Id, KnowledgeArticleId ,PublishStatus from Knowledge__kav where id =:testArticle.id LIMIT 1];        
        
        Test.startTest();        
        //this does not fire the delete trigger...added step to call handler manually
        //KbManagement.PublishingService.deleteDraftArticle(testRec.KnowledgeArticleId);
        //KnowledgeTrgHandler.onBeforeDelete(new List<Knowledge__kav>{testRec});
        //Test.stopTest();
    }
}
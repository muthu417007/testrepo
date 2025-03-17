@IsTest
private class QueryResultsRestResourceTest {
	@IsTest
    static void testApi9(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/queryResults';  //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
		req.params.put('query','SELECT Id FROM Knowledge__kav');
        QueryResultsRestResource.doGet();
    }
    
    @TestSetup
    static void setupData(){
        Knowledge__kav  testArticle = new Knowledge__kav();
        testArticle.Title = 'Test Prod Info';
        testArticle.Summary = 'Test Summary';
        testArticle.URLName = 'Test';
        insert testArticle ;
    }
}
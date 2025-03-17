@IsTest
private class ServiceProductsRestResourceTest {
	@IsTest
    static void testApi9(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/serviceProducts';  //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
		
        ServiceProductsRestResource.doGet();
    }
}
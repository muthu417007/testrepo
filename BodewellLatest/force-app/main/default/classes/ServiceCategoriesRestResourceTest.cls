@IsTest
private class ServiceCategoriesRestResourceTest {
    @IsTest
    static void testApi10(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/serviceCategories';  //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
		
        ServiceCategoriesRestResource.doGet();
    }
    
    @IsTest
    static void testApi11(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/serviceCategories/Care_and_Cleaning';  //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
		
        ServiceCategoriesRestResource.doGet();
    }	
}
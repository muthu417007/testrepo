@IsTest
private class KnowledgeRestResourceTest {
	@IsTest
    static void testApi1(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/knowledge';  //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
		
        KnowledgeRestResource.doGet();
    }
    
    @IsTest
    static void testApi2(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Knowledge__kav k =[SELECT Id FROM Knowledge__kav];
        req.requestURI = '/knowledge/'+k.Id;  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
		
        KnowledgeRestResource.doGet();
    }
    
    @IsTest
    static void testApi3(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Knowledge__kav k =[SELECT Id FROM Knowledge__kav];
        req.requestURI = '/knowledge/'+k.Id+'/accessLevels';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
		
        KnowledgeRestResource.doGet();
    }
    
    @IsTest
    static void testApi4(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Knowledge__kav k =[SELECT Id FROM Knowledge__kav];
        req.requestURI = '/knowledge/'+k.Id+'/accessLevels/4';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
		
        KnowledgeRestResource.doGet();
    }
    
    @IsTest
    static void testApi5(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Knowledge__kav k =[SELECT Id FROM Knowledge__kav];
        req.requestURI = '/knowledge/'+k.Id+'/fileAttachments';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
		
        KnowledgeRestResource.doGet();
    }
    
    @IsTest
    static void testApi6(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Knowledge__kav k =[SELECT Id FROM Knowledge__kav];
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
        ContentDocument cd = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId=k.Id;
        cdl.ContentDocumentId=cd.Id;
        cdl.ShareType='I';
        insert cdl;
        
        req.requestURI = '/knowledge/'+k.Id+'/fileAttachments/'+cd.Id;  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
		
        KnowledgeRestResource.doGet();
    }
    
    @IsTest
    static void testApi7(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Knowledge__kav k =[SELECT Id FROM Knowledge__kav];
        req.requestURI = '/knowledge/'+k.Id+'/products';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
		
        KnowledgeRestResource.doGet();
    }
    
    @IsTest
    static void testApi8(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Knowledge__kav k =[SELECT Id FROM Knowledge__kav];
        req.requestURI = '/knowledge/'+k.Id+'/categories';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
		
        KnowledgeRestResource.doGet();
    }
    
    @IsTest
    static void testApi13(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Knowledge__kav k =[SELECT Id FROM Knowledge__kav];
        req.requestURI = '/knowledge/deleted';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
		req.params.put('startDate','2014-11-15 15:37:20.000+0000');
        req.params.put('endDate','2014-11-15 15:37:20.000+0000');
        KnowledgeRestResource.doGet();
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
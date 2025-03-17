@isTest
private class MYA_AfxAPIController_Test {
    
    private class Mya_AfxAPIControllerResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            HttpResponse res = new HttpResponse();
            System.assertEquals(details.AFX_Search_API_Endpoint__c, req.getEndpoint());
           	System.assertEquals(details.AFX_Search_API_MethodType__c, req.getMethod());
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Authorization":' + details.AFX_Search_API_AuthToken__c);
            res.setStatusCode(200);            
            return res;
        }
    }
                            
	@isTest
    static void searchAssetsFromAFXTest() {
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert cont;
         // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';        
        User u1 = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
        	ContactId=cont.Id);
        insert u1;
        
        Test.startTest();  
        
        System.runAs(U1) {
            Test.setMock(HttpCalloutMock.class, new Mya_AfxAPIControllerResponseGenerator());
            
        	String response1 = MYA_AfxAPIController.searchAssetsFromAFX('TEST Address', 'TEST City', 'TEST Region', 'TEST Postal code', 'TEST Phone', 'TEST Email', 'TEST Lastname');
            
            String response2 = MYA_AfxAPIController.searchAssetsFromAFX('TEST Address', 'TEST City', 'TEST Region', '23232', '1234567890', 'test@test.com', 'Lasname');
        }
        
        Test.stopTest();
    }
}
@isTest
private class MYA_EndecaApiHandler_Test {
    private class Mya_EndecaAPIResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String input = '{\"results\":[{\"filters\":{\"Commercial Categories\":{\"filterValues\":[{\"label\":\"Cooking Products\"}]}}},{\"records\":{\"products\":{\"PT916WMWW\":[{\"Brand.DisplayName\":[\"GE Profile\"],\"SKU\":[\"PT916WMWW\"],\"Product_Commercial_Category\":[\"Cooking Products_Electric Cooking_Built-In Ovens\"],\"Description\":[\"GE Profile™ 30\\" Built-In Single Convection Wall Oven\"],\"Product_Display_Status\":[\"54~Name~Consumer Ready\"]},{\"BenefitCopy\":{}},{\"Attributes\":{\"WallOvens.LaborWarranty\":{\"Value\":[\"Limited 1-year entire appliance\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Labor Warranty\"},\"WallOvens.WarrantyNotes\":{\"Value\":[\"See written warranty for full details\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Warranty Notes\"},\"WallOvens.PartsWarranty\":{\"Value\":[\"Limited 1-year entire appliance\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Parts Warranty\"}}},{\"Images\":{\"007621\":{\"Default\":\"TRUE\",\"Name\":\"0106462.jpg\"},\"017622\":{\"Name\":\"0107209.jpg\"}}},{\"Documents\":{\"116642\":{\"Document_Type\":\"Use_and_Care_Manual\",\"Name\":\"49-80599.pdf\"}}},{\"Services\":{}},{\"Relationships\":{\"Accessories_\":{\"00\":{\"Brand_Name\":\"GE\",\"Images_DisplayImageName\":\"WX09X10035-4549.jpg\",\"Images_Name\":\"WX09X10035-4549.jpg\",\"Images\":\"27037\",\"Product_Status\":\"Consumer Ready\",\"SKU\":\"WX09X10035\"}}}},{\"BinaryObjectDetails\":{}},{\"FeaturedPart\":{}}]}}}]}';
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt MyaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
        	String Jwt = getJWT.generateJWTToken(MyaConfig.Endeca_API_Client_Id__c,MyaConfig.Endeca_API_Type__c,120,MyaConfig.Endeca_API_Client_Secret__c);
            String token =Jwt;
            HttpResponse res = new HttpResponse();
            System.assertEquals(MyaConfig.Endeca_API_Endpoint__c+'PT916WMWW', req.getEndpoint());
           	System.assertEquals('GET', req.getMethod());
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            res.setBody(input);
            res.setStatusCode(200);            
            return res;
        }
    }    
    
	@isTest
    static void getEndecaDetailsTest() { 
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
        
        System.runAs(u1) {
            Test.setMock(HttpCalloutMock.class, new Mya_EndecaAPIResponseGenerator());            
            String[] Keys = new String[] {'PT916WMWW'};
        	MYA_EndecaApiHandler.ProductsResponse response1 = new MYA_EndecaApiHandler.ProductsResponse();
            response1 = MYA_EndecaApiHandler.MYA_GetEndecaDetails(Keys);
        }
        
        Test.stopTest();
		   			
     }
}
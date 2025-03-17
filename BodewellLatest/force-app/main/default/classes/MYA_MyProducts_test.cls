@isTest
public class MYA_MyProducts_test {
    
    private class Mya_EndecaResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String input = '{\"results\":[{\"filters\":{\"Commercial Categories\":{\"filterValues\":[{\"label\":\"Cooking Products\"}]}}},{\"records\":{\"products\":{\"PT916WMWW\":[{\"Brand.DisplayName\":[\"GE Profile\"],\"SKU\":[\"PT916WMWW\"],\"Product_Commercial_Category\":[\"Cooking Products_Electric Cooking_Built-In Ovens\"],\"Description\":[\"GE Profile™ 30\\" Built-In Single Convection Wall Oven\"],\"Product_Display_Status\":[\"54~Name~Consumer Ready\"]},{\"BenefitCopy\":{}},{\"Attributes\":{\"WallOvens.LaborWarranty\":{\"Value\":[\"Limited 1-year entire appliance\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Labor Warranty\"},\"WallOvens.WarrantyNotes\":{\"Value\":[\"See written warranty for full details\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Warranty Notes\"},\"WallOvens.PartsWarranty\":{\"Value\":[\"Limited 1-year entire appliance\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Parts Warranty\"}}},{\"Images\":{\"007621\":{\"Default\":\"TRUE\",\"Name\":\"0106462.jpg\",\"Path\": \"https://products-stg.geappliances.com/image/upload/s--3BWa37Nv--/d768a82efc8c5a1ed9cab93b873b0c13cd6da1d1.jpg\"},\"017622\":{\"Name\":\"0107209.jpg\"}}},{\"Documents\":{\"116642\":{\"Document_Type\":\"Use_and_Care_Manual\",\"Name\":\"49-80599.pdf\"}}},{\"Services\":{}},{\"Relationships\":{\"Accessories_\":{\"00\":{\"Brand_Name\":\"GE\",\"Images_DisplayImageName\":\"WX09X10035-4549.jpg\",\"Images_Name\":\"WX09X10035-4549.jpg\",\"Images\":\"27037\",\"Product_Status\":\"Consumer Ready\",\"SKU\":\"WX09X10035\"}}}},{\"BinaryObjectDetails\":{}},{\"FeaturedPart\":{}}]}}}]}';
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt MyaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
        	String Jwt = getJWT.generateJWTToken(MyaConfig.Endeca_API_Client_Id__c,MyaConfig.Endeca_API_Type__c,120,MyaConfig.Endeca_API_Client_Secret__c);
            String token =Jwt;
            HttpResponse res = new HttpResponse();
            
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            res.setBody(input);
            res.setStatusCode(200);            
            return res;
        }
  }

 
    @isTest
    static void MYA_ProductDetails_test()
    { 
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
        
        Account a=new Account();
          a.Name='testName';
          a.BillingStreet='test street';
          a.BillingCity='test City';
          a.BillingState='OH';
          a.BillingPostalCode='12345';
          a.Country_Code__c='United States Of America';   
          insert a; 
        
        GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
           contactLoc.Name='testName';  
           contactLoc.Account__c=a.Id;
           contactLoc.Contact__c=u1.ContactId;
           contactLoc.MYA_Included__c=true;
           contactLoc.Nick_Name__c='testName';
           insert contactLoc;  
        
        Asset ast=new Asset();
            ast.AccountId=a.Id;
            ast.Model_Number__c='PT916WMWW';
            ast.SerialNumber='SL87537HG6';
            ast.AssetNickname__c='testnick';
            ast.ModelValidityFlag__c=true;
            ast.MACAddress__c='D828C95C2442';
            insert ast;
        
        Id asset_Id=ast.Id;
         
        // Switch to the runtime context
        Test.startTest();  
    
        // run as a different user to test security and rights
       System.runAs(u1) {
        Test.setMock(HttpCalloutMock.class, new Mya_EndecaResponseGenerator());
        list<mya_RegisteredProducts> listAssets=MYA_MyProducts.MYA_ProductDetails();
        MYA_MyProducts.MYA_ProductDetails1(asset_Id);
       }
         ConnectedApplianceResponse resp = ConnectedApplianceHelper.checkOnlineStatus(ast.MACAddress__c);
         String conn = resp.presence;
        ConnectedApplianceResponse testResponse = new ConnectedApplianceResponse();
        testResponse.presence = 'ONLINE';
        Test.stopTest();
        System.assertEquals('conn','ONLINE');
        
    }


}
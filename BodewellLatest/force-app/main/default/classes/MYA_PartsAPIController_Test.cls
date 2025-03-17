@isTest
private class MYA_PartsAPIController_Test {

    private class Mya_PartsAPIControllerResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt MyaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);        
            String Jwt = getJWT.generateJWTToken(MyaConfig.Payment_Method_Client_Id__c,MyaConfig.Payment_Method_Request_Type__c,120,MyaConfig.Payment_Method_Client_Secret__c);
            String token =Jwt;HttpResponse res = new HttpResponse();
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Authorization":' + token);
            res.setStatusCode(200);            
            return res;
        }
    }
    
    private class Mya_PartsAPIControllerErrorResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt MyaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);        
            String Jwt = getJWT.generateJWTToken(MyaConfig.Payment_Method_Client_Id__c,MyaConfig.Payment_Method_Request_Type__c,120,MyaConfig.Payment_Method_Client_Secret__c);
            String token =Jwt;HttpResponse res = new HttpResponse();
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            res.setBody(Null);
            res.setStatusCode(400);            
            return res;
        }
    }
    
    @isTest
    static void getPaymentInfoTest() {
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
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
            MYA_PartsAPIController controller = new MYA_PartsAPIController();
            Test.setMock(HttpCalloutMock.class, new Mya_PartsAPIControllerResponseGenerator());
            MYA_PartsAPIController.PaymentResponseModel response1 = new MYA_PartsAPIController.PaymentResponseModel(); 
        	response1 = MYA_PartsAPIController.getPaymentInfo('test@test.com');
            MYA_PartsAPIController.PaymentResponseModel response2 = new MYA_PartsAPIController.PaymentResponseModel(); 
        	response2 = MYA_PartsAPIController.getPaymentInfo('standarduser@testorg.com');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void getPaymentInfoTest2() {
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
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
            Test.setMock(HttpCalloutMock.class, new Mya_PartsAPIControllerErrorResponseGenerator());
            MYA_PartsAPIController.PaymentResponseModel response1 = new MYA_PartsAPIController.PaymentResponseModel(); 
        	response1 = MYA_PartsAPIController.getPaymentInfo('test@test.com');
        }
        
        Test.stopTest();
    }
}
@isTest
private class MYA_AddressHandler_Test {
    
 private class MYA_AddressHandlerResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) 
        { 
            HttpResponse res = new HttpResponse();
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            if(req.getEndpoint().endsWith('tokens'))
            {                         
                System.assertEquals(details.Token_EndPoint_URL__c, req.getEndpoint());
                System.assertEquals('POST', req.getMethod());
                System.assertEquals('{"client_id":"'+details.Token_Client_Id__c+'","client_secret":"'+details.Token_Client_Secret__c+'","audience":"'+details.Token_Audience__c+'","grant_type":"client_credentials"}',req.getBody());
                // Create a fake response
               
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik5qVXdNMFUxUVVRM00wSXlNVVZCTUVSQ09EUkJSak00TURnd09UZzBNRGsyUVRNelJUazNPUSJ9.eyJpc3MiOiJodHRwczovL2dlYS1ub25wcm9kLmF1dGgwLmNvbS8iLCJzdWIiOiJjcnBmZ1A3dlJRVlV6Z2xIVE9tUDZXYXVqamI5U3VjbUBjbGllbnRzIiwiYXVkIjoiZ2VhLWp3dC1hdXRob3JpemVyLW5vbi1wcmQiLCJpYXQiOjE2NTg5MzkwMDIsImV4cCI6MTY1ODkzOTkwMiwiYXpwIjoiY3JwZmdQN3ZSUVZVemdsSFRPbVA2V2F1ampiOVN1Y20iLCJndHkiOiJjbGllbnQtY3JlZGVudGlhbHMifQ.SZRgU9XDoRVFGEDPoBT7-Zn8iYyoW8JlV2eYuEekV-8SOR8RVWs6m1YDVwh-08ZCCQTA0ue8xsmWeh7gV4-JdIFjiEVVMuaCUUaM_YX3aFf5h25tNg05xKGR0CKvEMOHAWrCkZG3VOjbcW9m1FvOeu0GiZg-A35y4TKHW_vOIP-K3s4Nw1ajSMQsH2P7eVTslOcT_wN7-WY_g2dypvLR_DcbSD-cTd4NoVO8JFE5M476mp5UKeQ85q5eX09o52Bt5Py0Fi159cu3KazotAnb__UnYRAv4jpUaVUOibyxnU5ZahbOwI44plDlNg3DX_LBVx7KP_FqQvLyw5tk8xIklQ","expires_in": 900,"token_type": "Bearer"}');
                res.setStatusCode(200);
               
            }
            else if(req.getEndpoint().contains('addressvalidation?'))
            {
                System.assertEquals('GET', req.getMethod());
                System.assertEquals(details.Mellisa_Client_Id__c, req.getHeader('Client_id'));
                System.assertEquals(details.Mellisa_Client_Secret__c, req.getHeader('Client_secret'));
                
                
                // Create a fake response
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"ADDRESS_LINE1": "TEST1","ADDRESS_LINE2": " ","CITY": "Schenectady","COUNTY": "Schenectady","STATE": "NY","POSTALCODE": "12345-1222","COUNTRY": "United States of America","EMAIL": " ","PHONE": " ","ADDRESS_EXTRAS": " ","ADDRESS_KEY": "12345000000","COMPANY_NAME": "GE","MELISSA_ADDRESS_KEY": " ","MELISSA_ADDRESS_KEYBASE": " ","RECORD_EXTRAS": " ","RECORD_ID": "1","RESERVED": " ","RESULTS": "AS01","TOTAL_RECORDS": "1","TRANSMISSION_REFERENCE": " ","TRANSMISSION_RESULTS": " ","VERSION": "5.4.5.5"}');
                res.setStatusCode(200); 
            }
            return res;
            
        }
  }
    
   private class MYA_AddressHandlerResponseGenerator1 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) 
        { 
            HttpResponse res = new HttpResponse();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain('geapp--mya.my.salesforce.com');
            if(req.getEndpoint().endsWith('tokens'))
            {                         
                System.assertEquals(details.Token_EndPoint_URL__c, req.getEndpoint());
                System.assertEquals('POST', req.getMethod());
                System.assertEquals('{"client_id":"'+details.Token_Client_Id__c+'","client_secret":"'+details.Token_Client_Secret__c+'","audience":"'+details.Token_Audience__c+'","grant_type":"client_credentials"}',req.getBody());
                // Create a fake response
               
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik5qVXdNMFUxUVVRM00wSXlNVVZCTUVSQ09EUkJSak00TURnd09UZzBNRGsyUVRNelJUazNPUSJ9.eyJpc3MiOiJodHRwczovL2dlYS1ub25wcm9kLmF1dGgwLmNvbS8iLCJzdWIiOiJjcnBmZ1A3dlJRVlV6Z2xIVE9tUDZXYXVqamI5U3VjbUBjbGllbnRzIiwiYXVkIjoiZ2VhLWp3dC1hdXRob3JpemVyLW5vbi1wcmQiLCJpYXQiOjE2NTg5MzkwMDIsImV4cCI6MTY1ODkzOTkwMiwiYXpwIjoiY3JwZmdQN3ZSUVZVemdsSFRPbVA2V2F1ampiOVN1Y20iLCJndHkiOiJjbGllbnQtY3JlZGVudGlhbHMifQ.SZRgU9XDoRVFGEDPoBT7-Zn8iYyoW8JlV2eYuEekV-8SOR8RVWs6m1YDVwh-08ZCCQTA0ue8xsmWeh7gV4-JdIFjiEVVMuaCUUaM_YX3aFf5h25tNg05xKGR0CKvEMOHAWrCkZG3VOjbcW9m1FvOeu0GiZg-A35y4TKHW_vOIP-K3s4Nw1ajSMQsH2P7eVTslOcT_wN7-WY_g2dypvLR_DcbSD-cTd4NoVO8JFE5M476mp5UKeQ85q5eX09o52Bt5Py0Fi159cu3KazotAnb__UnYRAv4jpUaVUOibyxnU5ZahbOwI44plDlNg3DX_LBVx7KP_FqQvLyw5tk8xIklQ","expires_in": 900,"token_type": "Bearer"}');
                res.setStatusCode(200);
               
            }
            else if(req.getEndpoint().contains('addressvalidation?'))
            {
                System.assertEquals('GET', req.getMethod());
                System.assertEquals(details.Mellisa_Client_Id__c, req.getHeader('Client_id'));
                System.assertEquals(details.Mellisa_Client_Secret__c, req.getHeader('Client_secret'));
                
                
                // Create a fake response
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"ADDRESS_LINE1": "120 N Hurstbourne Pkwy","ADDRESS_LINE2": " ","CITY": "Louisville","COUNTY": "Schenectady","STATE": "KY","POSTALCODE": "40222","COUNTRY": "United States of America","EMAIL": " ","PHONE": " ","ADDRESS_EXTRAS": " ","ADDRESS_KEY": "12345000000","COMPANY_NAME": "GE","MELISSA_ADDRESS_KEY": " ","MELISSA_ADDRESS_KEYBASE": " ","RECORD_EXTRAS": " ","RECORD_ID": "1","RESERVED": " ","RESULTS": "AS01","TOTAL_RECORDS": "1","TRANSMISSION_REFERENCE": " ","TRANSMISSION_RESULTS": " ","VERSION": "5.4.5.5"}');
                res.setStatusCode(200); 
            }
            return res;
            
        }
  }
    
    @isTest
    static void Mya_GetAddressDetails_Test1()
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
        
     	Account a1=new Account();
          a1.Name='Test STREET1 Test City1 AK 33333';
          a1.BillingStreet='test street1';
          a1.BillingCity='test City1';
          a1.BillingState='AK';
          a1.BillingPostalCode='33333';
          a1.Country_Code__c='United States Of America';
       	insert a1;
        
        Account a2=new Account();
          a2.Name='Test STREET1 Test City1 AK 33333';
          a2.BillingStreet='test street1';
          a2.BillingCity='test City1';
          a2.BillingState='AK';
          a2.BillingPostalCode='33333';
          a2.Country_Code__c='United States Of America';
       	  a2.LocationID__c = '234342343';
       	insert a2;
        
     	GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
           ContactLoc.Name='testName';  
           ContactLoc.Account__c=a.Id;
           ContactLoc.Contact__c=u1.ContactId;
           ContactLoc.MYA_Included__c=true;
           ContactLoc.Nick_Name__c='testName';
           insert contactLoc; 
        
     	GEA_AccountContactRelation__c contactLoc1=new GEA_AccountContactRelation__c();
           ContactLoc1.Name='testName1';  
           ContactLoc1.Account__c=a1.Id;
           ContactLoc1.Contact__c=u1.ContactId;
           ContactLoc1.MYA_Included__c=true;
           ContactLoc1.Nick_Name__c='testName';
           insert contactLoc1;   
        
     	Asset ast=new Asset();
            ast.AccountId=a.Id;
            ast.Model_Number__c='PSB42YSNSS';
            ast.SerialNumber='SL87537HG6';
            insert ast;
        
        // Switch to the runtime context
        Test.startTest();  
    
        // run as a different user to test security and rights
        System.runAs(u1) {
        Test.setMock(HttpCalloutMock.class, new MYA_AddressHandlerResponseGenerator());
        Account acc1=Mya_AddressHandler.Mya_AddressValidation('test STREET1','test City1','AK','33333',true,'nick1');
        Mya_AddressHandler.AfxAccountResponse acc2=Mya_AddressHandler.Mya_AfxAddressValidation('test street1','test City1','AK','33333',true,'nick2','234342343');
        //string accId2=Mya_AddressHandler.Mya_AddressValidation('test street','city1','OH','00000',true,'nick1');    
       
        list<GEA_AccountContactRelation__c> address=Mya_AddressHandler.Mya_GetAddressDetails();
        GEA_AccountContactRelation__c add=new GEA_AccountContactRelation__c();    
        if(address.size()>0)
        {
          add=address[0];  
        }    
        Mya_AddressHandler.Mya_AssetList();
        Mya_AddressHandler.Mya_UpdateAssetAddress(a1.Id,ast.Id);
        Mya_AddressHandler.Mya_UpAssetAddress(a1.Id,contactLoc.Id);
        Mya_AddressHandler.Mya_UpdateContLoc(contactLoc.Id,'ni',true);
        Mya_AddressHandler.Mya_DelAddress(contactLoc1.Id);
       }
        
       Test.stopTest();
    }

    @isTest
    static void Mya_GetAddressDetails_Test2()
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
        
     Account a1=new Account();
          a1.Name='testName';
          a1.BillingStreet='test street';
          a1.BillingCity='test City';
          a1.BillingState='OH';
          a1.BillingPostalCode='12345';
          a1.Country_Code__c='United States Of America';   
     insert a1;
        
     GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
           ContactLoc.Name='testName';  
           ContactLoc.Account__c=A.Id;
           ContactLoc.Contact__c=U1.ContactId;
           ContactLoc.MYA_Included__c=true;
           ContactLoc.Nick_Name__c='testName';
           insert contactLoc; 
        
     GEA_AccountContactRelation__c contactLoc1=new GEA_AccountContactRelation__c();
           ContactLoc1.Name='testName1';  
           ContactLoc1.Account__c=a1.Id;
           ContactLoc1.Contact__c=u1.ContactId;
           ContactLoc1.MYA_Included__c=true;
           ContactLoc1.Nick_Name__c='testName';
           insert contactLoc1; 
        
     	Asset ast=new Asset();
            ast.AccountId=A.Id;
            ast.Model_Number__c='PSB42YSNSS';
            ast.SerialNumber='SL87537HG6';
            insert ast;
        
        // Switch to the runtime context
        Test.startTest();  
    
        // run as a different user to test security and rights
        
        Test.setMock(HttpCalloutMock.class, new MYA_AddressHandlerResponseGenerator());
        Mya_AddressHandler.Mya_UpdateAddress('test1','city1','state1','12345','nick1',ast.Id);
        Mya_AddressHandler.Mya_GetAddressDetails();
        Mya_AddressHandler.Mya_AssetList();
        Mya_AddressHandler.Mya_UpdateAssetAddress(a1.Id,ast.Id);
        Mya_AddressHandler.Mya_UpAssetAddress(a1.Id,contactLoc.Id);
        Mya_AddressHandler.Mya_UpdateContLoc(contactLoc.Id,'ni',true);
        Mya_AddressHandler.Mya_DelAddress(contactLoc1.Id);
        string num='123';    
        Mya_AddressHandler.Mya_DelAddress(num);    
       
       //stop test 
       Test.stopTest();
    }
     @isTest
    static void Mya_GetAddressDetails_Test()
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
        
     Account a1=new Account();
          a1.Name='testName';
          a1.BillingStreet='test street';
          a1.BillingCity='test City';
          a1.BillingState='OH';
          a1.BillingPostalCode='12345';
          a1.Country_Code__c='United States Of America';   
     insert a1;
        
     GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
           ContactLoc.Name='testName';  
           ContactLoc.Account__c=A.Id;
           ContactLoc.Contact__c=U1.ContactId;
           ContactLoc.MYA_Included__c=true;
           ContactLoc.Nick_Name__c='testName';
           insert contactLoc; 
        
     GEA_AccountContactRelation__c contactLoc1=new GEA_AccountContactRelation__c();
           ContactLoc1.Name='testName1';  
           ContactLoc1.Account__c=a1.Id;
           ContactLoc1.Contact__c=u1.ContactId;
           ContactLoc1.MYA_Included__c=true;
           ContactLoc1.Nick_Name__c='testName';
           insert contactLoc1; 
        
     Asset ast=new Asset();
            //ast.Account_Location__c=A.Id;
            ast.Model_Number__c='PSB42YSNSS';
            ast.SerialNumber='SL87537HG6';
            insert ast;
        
        // Switch to the runtime context
        Test.startTest();  
    
        // run as a different user to test security and rights
        System.runAs(u1) {
        Test.setMock(HttpCalloutMock.class, new MYA_AddressHandlerResponseGenerator());
        Mya_AddressHandler.Mya_UpdateAddress('test1','city1','state1','12345','nick1',ast.Id);
        Mya_AddressHandler.Mya_GetAddressDetails();
        Mya_AddressHandler.Mya_AssetList();
        Mya_AddressHandler.Mya_UpdateAssetAddress(a1.Id,ast.Id);
        Mya_AddressHandler.Mya_UpAssetAddress(a1.Id,contactLoc.Id);
        Mya_AddressHandler.Mya_UpdateContLoc(contactLoc.Id,'ni',true);
        Mya_AddressHandler.Mya_DelAddress(contactLoc1.Id);
        string num='123';    
        Mya_AddressHandler.Mya_DelAddress(num);    
       }
       //stop test 
       Test.stopTest();
    }
    
     @isTest
    static void Mya_GetAddressDetails_Test3()
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
        
     Account a1=new Account();
          a1.Name='testName';
          a1.BillingStreet='test street';
          a1.BillingCity='test City';
          a1.BillingState='OH';
          a1.BillingPostalCode='12345';
          a1.Country_Code__c='United States Of America';   
     insert a1;
        
     GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
           ContactLoc.Name='testName';  
           ContactLoc.Account__c=A.Id;
           ContactLoc.Contact__c=U1.ContactId;
           ContactLoc.MYA_Included__c=true;
           ContactLoc.Nick_Name__c='testName';
           insert contactLoc; 
        
     GEA_AccountContactRelation__c contactLoc1=new GEA_AccountContactRelation__c();
           ContactLoc1.Name='testName1';  
           ContactLoc1.Account__c=a1.Id;
           ContactLoc1.Contact__c=u1.ContactId;
           ContactLoc1.MYA_Included__c=true;
           ContactLoc1.Nick_Name__c='testName';
           insert contactLoc1; 
        
     Asset ast=new Asset();
            ast.AccountId=A.Id;
            ast.Model_Number__c='PSB42YSNSS';
            ast.SerialNumber='SL87537HG6';
            insert ast;
        
        // Switch to the runtime context
        Test.startTest();  
    
        // run as a different user to test security and rights
        
        Test.setMock(HttpCalloutMock.class, new MYA_AddressHandlerResponseGenerator());
        Mya_AddressHandler.Mya_UpdateAddress('test1','city1','state1','12345','nick1',ast.Id);
        Mya_AddressHandler.Mya_GetAddressDetails();
        Mya_AddressHandler.Mya_AssetList();
        Mya_AddressHandler.Mya_UpdateAssetAddress(a1.Id,ast.Id);
        Mya_AddressHandler.Mya_UpAssetAddress(a1.Id,contactLoc.Id);
        Mya_AddressHandler.Mya_UpdateContLoc(contactLoc.Id,'ni',true);
        Mya_AddressHandler.Mya_DelAddress(contactLoc1.Id);
        string num='123';    
        Mya_AddressHandler.Mya_DelAddress(num);    
       
       //stop test 
       Test.stopTest();
    }
     @isTest
    static void Mya_GetAddressDetails_Test4()
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
          a.Name='120 N Hurstbourne Pkwy Louisville KY 40222';
          a.BillingStreet='120 N Hurstbourne Pkwy';
          a.BillingCity='Louisville';
          a.BillingState='KY';
          a.BillingPostalCode='40222';
          a.Country_Code__c='United States Of America';   
          insert a;
        
     Asset ast=new Asset();
            //ast.Account_Location__c=A.Id;
            ast.Model_Number__c='PSB42YSNSS';
            ast.SerialNumber='SL87537HG6';
            insert ast;
        
        // Switch to the runtime context
        Test.startTest();  
    
        // run as a different user to test security and rights
        System.runAs(u1) {
        Test.setMock(HttpCalloutMock.class, new MYA_AddressHandlerResponseGenerator1());
        Mya_AddressHandler.Mya_UpdateAddress('120 N Hurstbourne','Louisville','KY','40222','nick1',ast.Id);    
       }
       //stop test 
       Test.stopTest();
    }
    
}
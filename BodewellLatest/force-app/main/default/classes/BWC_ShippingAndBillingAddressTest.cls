@isTest
public class BWC_ShippingAndBillingAddressTest {
    
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
    @isTest
    public static void Mya_GetAddressDetails_Test1()
    {
        
        // Switch to the runtime context
        Test.startTest();  
        
        // run as a different user to test security and rights
        //        Public static AddressValidationWrapper Mya_AddressValidation(String firstName,String lastName,String Address,String City,String State,String Code,string addressType)
        
        Test.setMock(HttpCalloutMock.class, new MYA_AddressHandlerResponseGenerator());
        BWC_ShippingAndBillingAddressController.AddressValidationWrapper acc1=BWC_ShippingAndBillingAddressController.Mya_AddressValidation('Shubhada','k','test STREET1','test City1','AK','33333','Shipping', 'test STREET1', true, '123456','7709955667');
        
        Test.stopTest();
        
        
    }
    @isTest
    public static void getShippingAddressTest()
    {
        
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        
        Profile p = [select Id from profile where name='Bodewell Commerce D2C Login User'];
        
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
        
        
        // Switch to the runtime context
        Test.startTest();  
        
        // run as a different user to test security and rights
        //        Public static AddressValidationWrapper Mya_AddressValidation(String firstName,String lastName,String Address,String City,String State,String Code,string addressType)
        
        // Test.setMock(HttpCalloutMock.class, new MYA_AddressHandlerResponseGenerator());
        List<ContactPointAddress> accountShippingAddresses=BWC_ShippingAndBillingAddressController.bwc_getShippingAddress(u1.Id);
        
        Test.stopTest();
        
        
        
    }
    
    @isTest
    public static void getBillingAddressTest()
    {
        
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        ContactPointAddress cpa=new ContactPointAddress();
        
        cpa.Street='Address';
        cpa.AddressType='Shipping';
        
        cpa.State='Us';
        
        cpa.City='US';
        cpa.Country='US';
        cpa.PostalCode='40222';
        cpa.Name='Shubhada K';
        
        cpa.IsDefault=true;
        cpa.ParentId=acc.Id;
        insert cpa;
        // Switch to the runtime context
        Test.startTest();  
        
        // run as a different user to test security and rights
        //        Public static AddressValidationWrapper Mya_AddressValidation(String firstName,String lastName,String Address,String City,String State,String Code,string addressType)
        
        // Test.setMock(HttpCalloutMock.class, new MYA_AddressHandlerResponseGenerator());
        ContactPointAddress accountbillingAddresses=BWC_ShippingAndBillingAddressController.bwc_getBillingAddressB(acc.Id);
        
        Test.stopTest();
        
        
        
    }
    @isTest
    public static void getStatusTest()
    {
        
        Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
        
        
        
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        CartItem ctItem=new CartItem();
        ctItem.Name=productRecord.Name;
        ctItem.Product2Id=productRecord.Id;
        ctItem.CartId=cart.Id;
        ctItem.Sku=productRecord.StockKeepingUnit;    
        ctItem.Type='Product';
        ctItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
        ctItem.Quantity=1;
        ctItem.SalesPrice=20;
        ctItem.TotalPrice=30;
        
        insert ctItem;
        Test.startTest();  
        
        String status=BWC_ShippingAndBillingAddressController.getCheckoutStatus(cart.Id);
        
        Test.stopTest();
    }
       @isTest
    public static void updateStatusTest()
    {
        
        Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
        
        
        
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        CartItem ctItem=new CartItem();
        ctItem.Name=productRecord.Name;
        ctItem.Product2Id=productRecord.Id;
        ctItem.CartId=cart.Id;
        ctItem.Sku=productRecord.StockKeepingUnit;    
        ctItem.Type='Product';
        ctItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
        ctItem.Quantity=1;
        ctItem.SalesPrice=20;
        ctItem.TotalPrice=30;
        
        insert ctItem;
        Test.startTest();  
        
        WebCart status=BWC_ShippingAndBillingAddressController.updateCheckoutStatus(cart.Id,'Billing');
        
        Test.stopTest();
    }
    
    
      @isTest
    public static void updatecartItemFields()
    {
        
        Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        ContactPointAddress cpa=new ContactPointAddress();
        
        cpa.Street='Address';
        cpa.AddressType='Shipping';
        
        cpa.State='Us';
        
        cpa.City='US';
        cpa.Country='US';
        cpa.PostalCode='40222';
        cpa.Name='Shubhada K';
        
        cpa.IsDefault=true;
        cpa.ParentId=ac.Id;
        insert cpa;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
        
          Product2 productRecord1=new Product2();
        productRecord1.StockKeepingUnit='Test 2';
        productRecord1.Item_Number__c='456755';
        productRecord1.Name='TEST product 1';
        insert productRecord1;
        
        
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        CartItem ctItem=new CartItem();
        ctItem.Name=productRecord.Name;
        ctItem.Product2Id=productRecord.Id;
        ctItem.CartId=cart.Id;
        ctItem.Sku=productRecord.StockKeepingUnit;    
        ctItem.Type='Product';
        ctItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
        ctItem.Quantity=1;
        ctItem.SalesPrice=20;
        ctItem.TotalPrice=30;
        
        insert ctItem;
          CartItem ctItem1=new CartItem();
        ctItem1.Name=productRecord.Name;
        ctItem1.Product2Id=productRecord1.Id;
        ctItem1.CartId=cart.Id;
        ctItem1.Sku=productRecord1.StockKeepingUnit;    
        ctItem1.Type='Product';
        ctItem1.CartDeliveryGroupId=cartDeliveryGroup.Id;
        ctItem1.Quantity=1;
        ctItem1.SalesPrice=20;
        ctItem1.TotalPrice=30;
        
        insert ctItem1;
        Test.startTest();  
        List<String> hdCartItems =new List<String>();
        
        hdCartItems.add(ctItem.Id);
        List<String> hdCartItems2 =new List<String>();
        
        hdCartItems2.add(ctItem1.Id);
        List<String> hdCartItems3 =new List<String>();
/*  (String expectedDeliveryDate,
                                                List<String> hdCartItems,
                                                String expectedpickupDeliveryDate,
                                                List<String> pickupcartItems,
                                                String shipType,
                                                List<String>shipcartItems,
                                                String shipFee,
                                                List<String> prodShippingList,
                                                String pickupLocation,List<String> sdsList)*/
        List<CartItem> status=BWC_ShippingAndBillingAddressController.updatecartItem('2023-12-06',hdCartItems,'2023-12-06',hdCartItems2,'test 19.95',hdCartItems3,'19.95',hdCartItems3,'test Location',hdCartItems3);
        
        Test.stopTest();
    }
    
    
      @isTest
    public static void addAddressTest()
    {
        
    
       
    Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
            Account ac2 = new Account(name ='Grazitti2') ;
        insert ac2; 
          
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;

          WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id);
        insert cart;
        
        CartDeliveryGroup cdg=new CartDeliveryGroup();
        cdg.CartId=cart.Id;
        cdg.Name='Default deivery group';
        insert cdg;
        
          ContactPointAddress cpa=new ContactPointAddress();
        cpa.Street='Test Address Line';
        cpa.AddressType='Shipping';
        cpa.State='NY';
        cpa.City='New York';
        cpa.Country='NY';
        cpa.PostalCode='40222';
        cpa.Name='Test Address';
          cpa.BWC_Formatted_Address__c='hello123';
        
          ContactPointAddress cpa1=new ContactPointAddress();
        cpa1.Street='Test Address Line';
        cpa1.AddressType='Shipping';
        cpa1.State='NY';
        cpa1.City='New York';
        cpa1.Country='NY';
        cpa1.PostalCode='40222';
        cpa1.Name='Test Address';
        cpa1.BWC_Formatted_Address__c='hello123';
        cpa1.ParentId=ac.Id;
        insert cpa1;
         ContactPointAddress cpa2=new ContactPointAddress();
        cpa2.Street='Test Address Line';
        cpa2.AddressType='Shipping';
        cpa2.State='NY';
        cpa2.City='New York';
        cpa2.Country='NY';
        cpa2.PostalCode='40222';
        cpa2.Name='Test Address';
         
           Test.startTest();  
        
        ContactPointAddress cpaSaved=BWC_ShippingAndBillingAddressController.addAddress(ac.Id,cpa);
                ContactPointAddress cpaSaved1=BWC_ShippingAndBillingAddressController.addAddress(ac2.Id,cpa2);

              //  ContactPointAddress cpaSaved=BWC_ShippingAndBillingAddressController.addAddress(ac.Id,cpa);

        
        Test.stopTest();
   
    }
        
      @isTest
    public static void addAddressTestBilling()
    {
        
    
        
           
        Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
     
        
        
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id);
        insert cart;
        
        
          ContactPointAddress cpa=new ContactPointAddress();
        cpa.Street='Test Address Line';
        cpa.AddressType='Billing';
        cpa.State='NY';
        cpa.City='New York';
        cpa.Country='NY';
        cpa.PostalCode='40222';
        cpa.Name='Test Address';
          cpa.BWC_Formatted_Address__c='hello123';
        
          ContactPointAddress cpa1=new ContactPointAddress();
        cpa1.Street='Test Address Line';
        cpa1.AddressType='Billing';
        cpa1.State='NY';
        cpa1.City='New York';
        cpa1.Country='NY';
        cpa1.PostalCode='40222';
        cpa1.Name='Test Address';
        cpa1.BWC_Formatted_Address__c='hello123';
        cpa1.ParentId=ac.Id;
        insert cpa1;
           Test.startTest();  
        
        ContactPointAddress cpaSaved=BWC_ShippingAndBillingAddressController.addAddress(ac.Id,cpa);
        
        Test.stopTest();
   
    }
     
      @isTest
    public static void makeAddressDefaultTest()
    {
        
    Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
          
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;

          WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id);
        insert cart;
        
        CartDeliveryGroup cdg=new CartDeliveryGroup();
        cdg.CartId=cart.Id;
        cdg.Name='Default deivery group';
        insert cdg;
          ContactPointAddress cpa=new ContactPointAddress();
        cpa.Street='Test Address Line';
        cpa.AddressType='Shipping';
        cpa.State='NY';
        cpa.City='New York';
        cpa.Country='NY';
        cpa.PostalCode='40222';
        cpa.Name='Test Address';
        insert cpa;
           Test.startTest();  
        
        ContactPointAddress cpaSaved=BWC_ShippingAndBillingAddressController.makeAddressDefault(cpa.Id,'1234123412');
        
        Test.stopTest();
   
    }
    
      
    @isTest
    static void createContactTest() { 

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
        
        Contact_Point__c ContactPointObj = new Contact_Point__c();
        ContactPointObj.Contact__c = u1.ContactId;
        ContactPointObj.Phone__c = '1122334455';
        ContactPointObj.MYA_Included__c = true;
        ContactPointObj.MYAISPrimary__c = false;
        insert ContactPointObj;
        
        Contact_Point__c ContactPointObj1 = new Contact_Point__c();
        ContactPointObj1.Contact__c = u1.ContactId;
        ContactPointObj1.Phone__c = '1122334456';
        ContactPointObj1.MYA_Included__c = true;
        ContactPointObj1.MYAISPrimary__c = false;
        insert ContactPointObj1;
        
        Contact_Point__c ContactPointObj2 = new Contact_Point__c();
        ContactPointObj2.Contact__c = u1.ContactId;
        ContactPointObj2.Phone__c = '1122334457';
        ContactPointObj2.MYA_Included__c = true;
        ContactPointObj2.MYAISPrimary__c = false;
        ContactPointObj2.MYA_IsDeleted__c = true;
        insert ContactPointObj2;
        
        Test.startTest();  
        
        System.runAs(u1) {
        	Contact_Point__c response1 = BWC_ShippingAndBillingAddressController.createContact(u1.ContactId, '1122334457', true);
            Contact_Point__c response2 = BWC_ShippingAndBillingAddressController.createContact(u1.ContactId, '9977886655', true);
            Contact_Point__c response3 = BWC_ShippingAndBillingAddressController.createContact(u1.ContactId, '1122334457', false);
            Contact_Point__c response4 = BWC_ShippingAndBillingAddressController.createContact(u1.ContactId, '9977886658', false);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void updateCartStatusTest() { 

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
 WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=acc.Id);
        insert cart;
     
        Test.startTest();  
        
        System.runAs(u1) {
        	BWC_ShippingAndBillingAddressController.updateCartStatus(cart.id);
        }
        
        Test.stopTest();
		   			
     }
    
       @isTest
    public static void callIntegrationTest()
    {
        
    Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='testacc');
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, EBS_X_ACCOUNT_NUMBER__c = '123');
        insert con;  
        
        User user = new User(alias = 'demo', email='demo123@noemail.com',
                             emailencodingkey='UTF-8', lastname='demo', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='demo@noemail.com');
        insert user;
        WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='Part123', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            TotalPrice=23,
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;
        ContactPointAddress cpa1 = new ContactPointAddress(Name = 'test', city = 'Green Bay',
                                                           country = 'US', street = 'TestS Street', state = 'test State', PostalCode = '123', AddressType = 'Billing');
        insert cpa1;
        
        ContactPointAddress cpa2 = new ContactPointAddress(Name = 'test1', city = 'Green Bay',
                                                           country = 'US', street = 'TestS Street', state = 'test State', PostalCode = '123', BWC_Account_Number__c='',BWC_Bill_To_Org_Id__c='',BWC_Ship_To_Org_Id__c='', IsDefault = True, AddressType = 'Shipping');
        insert cpa2;
        
        Date dt=Date.newInstance(2016, 12, 9);
        CartTax cartTaxInstance=new CartTax(Name='Test',CartItemId=cartItem.Id,TaxType='Actual',TaxCalculationDate=dt,Amount=24);
        insert cartTaxInstance;
           Test.startTest();  
        
        sfdc_checkout.IntegrationStatus result=BWC_ShippingAndBillingAddressController.BWC_CallCheckoutIntrgration(cart.Id);
                        ContactPointAddress result1=BWC_ShippingAndBillingAddressController.getConsumerZipcode(ac.Id);

        Test.stopTest();
   
    }
}
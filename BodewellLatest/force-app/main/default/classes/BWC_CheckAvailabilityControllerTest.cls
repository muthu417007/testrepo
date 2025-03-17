@isTest
public class BWC_CheckAvailabilityControllerTest {
    @TestSetup
    public static void method(){
        Id p = [select id from profile where name='Default Customer Login User'].id;
        
        Account ac = new Account(name ='testacc');
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, EBS_X_ACCOUNT_NUMBER__c = '123');
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        ContactPointAddress cpa1 = new ContactPointAddress(Name = 'test', city = 'Green Bay',
                                                           country = 'US', street = 'TestS Street', state = 'test State', PostalCode = '123', AddressType = 'Billing');
        insert cpa1;
        
        ContactPointAddress cpa2 = new ContactPointAddress(Name = 'test1', city = 'Green Bay',
                                                           country = 'US', street = 'TestS Street', state = 'test State', PostalCode = '123', AddressType = 'Shipping');
        insert cpa2;
        
        WebStore testWebStore = new WebStore(Name='Bodewell Store');
        insert testWebStore;
        User u = [select id, Account.EBS_X_ACCOUNT_NUMBER__pc from User limit 1];
        WebStore testWebStore2 = new WebStore(Name='Bodewell Store2');
        insert testWebStore2;   
        WebStore testWebStore3 = new WebStore(Name='Bodewell Store3');
        insert testWebStore3;
        WebStore testWebStore4 = new WebStore(Name='Bodewell Store4');
        insert testWebStore4;
        system.debug(u);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=ac.Id,Status='Checkout');
        insert cart;
        WebCart cart2 = new WebCart(Name='Cart2', WebStoreId=testWebStore2.Id, AccountId=ac.Id,Status='Active');
        insert cart2;
        WebCart cart3 = new WebCart(Name='Cart3', WebStoreId=testWebStore3.Id, AccountId=ac.Id,Status='Active');
        insert cart3;
        WebCart cart4 = new WebCart(Name='Cart4', WebStoreId=testWebStore4.Id, AccountId=ac.Id,Status='Checkout');
        insert cart4;
        
        CartDeliveryGroup cartDeliveryGroupInstance=new CartDeliveryGroup(Name='Default Delivery',CartId=cart.Id);
        insert cartDeliveryGroupInstance;
        
        Product2 testProductInstance = new Product2(
            Name='Item 1',
            StockKeepingUnit='Item 1',
            Inventory_Item_ID__c='123',
            Item_Type__c='test',
            Item_Number__c = '1',
            BWC_Is_Part__c = false
        );
        insert testProductInstance;
        Product2 testProductInstance2 = new Product2(
            Name='Item 2',
            StockKeepingUnit='Item 2',
            Inventory_Item_ID__c='321',
            Item_Type__c='test2',
            Item_Number__c = '2',
            BWC_Is_Part__c = false
        );
        insert testProductInstance2;
        Product2 testProductInstance3 = new Product2(
            Name='Item',
            Inventory_Item_ID__c='456',
            Item_Type__c='test3',
            Item_Number__c = '3',
            BWC_Is_Part__c = false
        );
        insert testProductInstance3;
        
        CartItem cartItemInstance=new CartItem(sku='Item 1',Name=testProductInstance.Name,Product2Id=testProductInstance.Id,CartId=cart.Id,CartDeliveryGroupId=cartDeliveryGroupInstance.Id,Quantity=4.0, Type='Product');
        insert cartItemInstance;
        CartItem cartItemInstance2=new CartItem(sku='Item 2',Name=testProductInstance2.Name,Product2Id=testProductInstance2.Id,CartId=cart.Id,CartDeliveryGroupId=cartDeliveryGroupInstance.Id,Quantity=16.0, Type='Product');
        insert cartItemInstance2;
        CartItem cartItemInstance3=new CartItem(Name=testProductInstance3.Name,Product2Id=testProductInstance3.Id,CartId=cart3.Id,CartDeliveryGroupId=cartDeliveryGroupInstance.Id,Quantity=16.0, Type='Product');
        insert cartItemInstance3;
        CartItem cartItemInstance4=new CartItem(sku='Item 2',Name=testProductInstance2.Name,Product2Id=testProductInstance2.Id,CartId=cart4.Id,CartDeliveryGroupId=cartDeliveryGroupInstance.Id,Quantity=12.0, Type='Product');
        insert cartItemInstance4;
        
        
        
        GEA_AccountContactRelation__c gacr = new GEA_AccountContactRelation__c(Name = 'g Test', EBS_X_BILL_TO_ORG_ID__c = '123', Contact__c = con.Id, EBS_X_SHIP_TO_ORG_ID__c = '123', Account__c = ac.Id);
        insert gacr;
    }
    
    @isTest
    public static void func(){
        /* StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
mock.setStaticResource('GetInventoryResource');
mock.setStatusCode(200);
mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
Test.startTest();
Test.setMock(HttpCalloutMock.class, mock);*/
        Test.startTest();
        BWC_CheckAvailabilityController apexSample = new BWC_CheckAvailabilityController();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        //  System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }
    
    @isTest
    public static void test_Method_In_Catch(){
        BWC_CheckAvailabilityController apexSample = new BWC_CheckAvailabilityController();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart2' LIMIT 1];
        
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
    }
    
    @isTest
    public static void test_Method_Is_Empty(){
        BWC_CheckAvailabilityController apexSample = new BWC_CheckAvailabilityController();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart3' LIMIT 1];
        
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
    }
    
    @isTest
    public static void test_MethodIn_Catch2(){
        BWC_CheckAvailabilityController apexSample = new BWC_CheckAvailabilityController();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart4' LIMIT 1];
        
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
    }
    
    
    @isTest
    public static void test_MethodIn_Catch4(){
        List<Product2> productList = new List<Product2>();
        for(Product2 pro : [SELECT Id,Name,BWC_Is_Part__c FROM Product2]){
            pro.BWC_Is_Part__c = True;
            productList.add(pro);
        }
        update productList;
        BWC_CheckAvailabilityController apexSample = new BWC_CheckAvailabilityController();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart4' LIMIT 1];
        
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
    }
   @isTest
    public static void test_MethodIn_Catch5(){
        delete [SELECT Id,Name,BWC_Is_Part__c FROM Product2];
        system.debug('@@@@productList:after delete');
        BWC_CheckAvailabilityController apexSample = new BWC_CheckAvailabilityController();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart4' LIMIT 1];
        
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
    }

// Implement the HTTP callout mock class

}
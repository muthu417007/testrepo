@isTest
public class BWC_ProductViewServicesControllerTest {
    
        @isTest
    static void testGetADC_Details() {
        // Create test data if needed, including any required objects or records
        // Insert necessary data into the database for the test
        
        // Call the method to be tested

        List<String> skuList = new List<String>{'SKU1'};
        String postalCodeInstance = '40222';
       // System.Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockBWC_ADC());
        String result = BWC_ProductViewServicesController.getADC_Details(skuList, postalCodeInstance);
       // System.Test.stopTest();

        // Add assertions to verify the results
      //  System.assertEquals(null, result); // Adjust this assertion based on your expected result
    }
    @isTest
    public static void testGetProductServices()
    {
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
        
        Test.startTest();  
        
        BWC_ProductViewServicesController.BundleServiceWrapper service= BWC_ProductViewServicesController.getProductServices('ABCSE','40222');
        
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void testbwc_getRelatedCartItem()
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
           
          BWC_Product_Service__c service=new BWC_Product_Service__c();
        service.Name='Test';
        service.BWC_Service_Description__c='Test Service';
        service.BWC_Service_Price__c=10.70;
        service.BWC_Service_Type__c='Installation';
        service.BWC_SKU__c='TEST';
        service.Cart_Item__c=ctItem.Id;
        service.BWC_Cart_Id__c=cart.Id;
        service.BWC_Member_Price__c=20;
        service.BWC_Quantity__c=1;
        service.BWC_ZipCode__c	='40299';
        insert service;

        Test.startTest();  
        //m(String itemId,String zipCode,String skuProduct,String cartId,String quantity)
        List<BWC_Product_Service__c> serviceList=BWC_ProductViewServicesController.bwc_getRelatedCartItem(ctItem.Id,'40299',productRecord.id,cart.Id,'2');
        
        Test.stopTest();
    }
    
      @isTest
    public static void testbwc_getRelatedCartItem2()
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
           
          BWC_Product_Service__c service=new BWC_Product_Service__c();
        service.Name='Test';
        service.BWC_Service_Description__c='Test Service';
        service.BWC_Service_Price__c=10.70;
        service.BWC_Service_Type__c='Installation';
        service.BWC_SKU__c='TEST';
        service.Cart_Item__c=ctItem.Id;
        service.BWC_Cart_Id__c=cart.Id;
        service.BWC_Member_Price__c=20;
        service.BWC_Quantity__c=1;
        service.BWC_ZipCode__c	='40299';
        insert service;

        Test.startTest();  
        //m(String itemId,String zipCode,String skuProduct,String cartId,String quantity)
        List<BWC_Product_Service__c> serviceList=BWC_ProductViewServicesController.bwc_getRelatedCartItem(ctItem.Id,'40222',productRecord.id,cart.Id,'2');
        
        Test.stopTest();
    }
    @isTest
    public static void testbwc_getAllRelatedCartItem()
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
        //m(String itemId,String zipCode,String skuProduct,String cartId,String quantity)
        BWC_ProductViewServicesController.SerciceWrapper serviceList=BWC_ProductViewServicesController.bwc_getAllRelatedCartItem(cart.Id,'40222');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testbwc_getRelatedCartItemAll()
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
        
        //Installation
        BWC_Product_Service__c service=new BWC_Product_Service__c();
        service.Name='Test';
        service.BWC_Service_Description__c='Test Service';
        service.BWC_Service_Price__c=10.70;
        service.BWC_Service_Type__c='Installation';
        service.BWC_SKU__c='TEST';
        service.Cart_Item__c=ctItem.Id;
        service.BWC_Cart_Id__c=cart.Id;
        service.BWC_Member_Price__c=20;
        service.BWC_Quantity__c=1;
        service.BWC_ZipCode__c	='40222';
        insert service;
        
        //Protection Plan
        BWC_Product_Service__c servicePP=new BWC_Product_Service__c();
        servicePP.Name='Test';
        servicePP.BWC_Service_Description__c='Test Service';
        servicePP.BWC_Service_Price__c=10.70;
        servicePP.BWC_Service_Type__c='Protection Plan';
        servicePP.BWC_SKU__c='TEST';
        servicePP.Cart_Item__c=ctItem.Id;
        servicePP.BWC_Cart_Id__c=cart.Id;
        servicePP.BWC_Member_Price__c=20;
        servicePP.BWC_Quantity__c=1;
        insert servicePP;
        
        //Parts Ship
        BWC_Product_Service__c servicePS=new BWC_Product_Service__c();
        servicePS.Name='Test';
        servicePS.BWC_Service_Description__c='Test Service';
        servicePS.BWC_Service_Price__c=10.70;
        servicePS.BWC_Service_Type__c='Parts Ship Fee';
        servicePS.BWC_SKU__c='TEST';
        servicePS.Cart_Item__c=ctItem.Id;
        servicePS.BWC_Cart_Id__c=cart.Id;
        servicePS.BWC_Member_Price__c=20;
        servicePS.BWC_Quantity__c=1;        
        insert servicePS;
        
        Test.startTest();  
        //m(String itemId,String zipCode,String skuProduct,String cartId,String quantity)
        BWC_ProductViewServicesController.SerciceWrapperFees serviceList=BWC_ProductViewServicesController.bwc_getRelatedCartItemAll(cart.Id,false,'40222');
        BWC_ProductViewServicesController.SerciceWrapperFees serviceList1=BWC_ProductViewServicesController.bwc_getRelatedCartItemAll(cart.Id,true,'40222');

        BWC_ProductViewServicesController.SerciceWrapperFees serviceListPP=BWC_ProductViewServicesController.bwc_getRelatedCartItemAll(cart.Id,false,'40222');
        BWC_ProductViewServicesController.SerciceWrapperFees serviceListPP1=BWC_ProductViewServicesController.bwc_getRelatedCartItemAll(cart.Id,true,'40222');
        
        BWC_ProductViewServicesController.SerciceWrapperFees serviceListPS=BWC_ProductViewServicesController.bwc_getRelatedCartItemAll(cart.Id,false,'40222');
        BWC_ProductViewServicesController.SerciceWrapperFees serviceListPS1=BWC_ProductViewServicesController.bwc_getRelatedCartItemAll(cart.Id,true,'40222');

        Test.stopTest();
    }
    
    
    
    
    
}
@isTest(seeAllData = true)
public class BWC_GetInfoTest {
    @isTest
    public static void getProductTest(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        Product2 productInstance = [SELECT Id FROM Product2 LIMIT 1];
        Network networkInstance = [SELECT Id FROM Network LIMIT 1];
        WebStoreNetwork w = [select id,WebStoreId,NetworkId from WebStoreNetwork LIMIT 1];
        SYstem.debug('w-->'+w);
        Test.startTest();
        BWC_GetInfo.getProduct(w.NetworkId,productInstance.Id,accountInstance.Id);
        Test.stopTest();
    }
    
     @isTest
    public static void getCartSummaryTest(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        Network networkInstance = [SELECT Id FROM Network LIMIT 1];
        Test.startTest();
        BWC_GetInfo.getCartSummary(networkInstance.Id,accountInstance.Id);
        Test.stopTest();
    }
    
     @isTest(seealldata=true)
    public static void addToCartTest(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
       // String accId=String.valueOf(accountInstance.Id);
        Product2 productInstance = [SELECT Id,StockKeepingUnit FROM Product2 LIMIT 1];
        //String proId=String.valueof(productInstance.Id);
        Network networkInstance = [SELECT Id FROM Network where name='Bodewell Store' LIMIT 1];
        String networkId=String.valueof(networkInstance.Id);
        
        Test.startTest();
        BWC_GetInfo.ProductInformation productInformationInstance = new BWC_GetInfo.ProductInformation();
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        String accId=String.valueOf(ac.Id);
 
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
        String proId=String.valueof(productRecord.Id);
        
        

        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        //String networkId=String.valueof(webStore.Id);
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id, Status = 'Checkout',IsSecondary=false);
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
        
        BWC_GetInfo.addToCart(networkId,proId,'5',accId,new List<String>{productInstance.StockKeepingUnit},new List<String>{productInstance.StockKeepingUnit},new List<String>{'M0850'},'40222');
            
        Test.stopTest();
    }

    @isTest(seealldata=true)
    public static void addToCartTestForVariation(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        Product2 productInstance = [SELECT Id,StockKeepingUnit FROM Product2 where ProductClass = 'VariationParent' LIMIT 1];

        Network networkInstance = [SELECT Id FROM Network LIMIT 1];
        Test.startTest();
        BWC_GetInfo.ProductInformation productInformationInstance = new BWC_GetInfo.ProductInformation();
        productInformationInstance = BWC_GetInfo.addToCart(networkInstance.Id,productInstance.Id,'5',accountInstance.Id,new List<String>{productInstance.StockKeepingUnit},new List<String>{productInstance.StockKeepingUnit},new List<String>{'M0850'},'40222');
        Test.stopTest();
    }
    
    /*  @isTest
    public static void createCartTest(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
Network networkInstance = [SELECT Id FROM Network LIMIT 1];
     
        Test.startTest();
        ConnectApi.CartSummary cartsumm =BWC_GetInfo.createCart(networkInstance.Id,accountInstance.Id);
        Test.stopTest();
    }
    */
    @isTest
    public static void createAndAddToListTest(){

        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        Product2 productInstance = [SELECT Id,StockKeepingUnit FROM Product2 LIMIT 1];

        Network networkInstance = [SELECT Id FROM Network LIMIT 1];
        WebStoreNetwork w = [select id,WebStoreId,NetworkId from WebStoreNetwork LIMIT 1];
        //
             ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
            wishlistItemInput.productId =productInstance.id ;
            
            //Create a wishlistInput to be created
            ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
            // wishlistInput. = wishlistId;
            wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
                wishlistItemInput
                    };
        //

        Test.startTest();
        BWC_GetInfo.createAndAddToList(w.NetworkId,productInstance.Id,'test',accountInstance.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getProductPriceTest(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        Product2 productInstance = [SELECT Id FROM Product2 LIMIT 1];
        Network networkInstance = [SELECT Id FROM Network LIMIT 1];
        WebStoreNetwork w = [select id,WebStoreId,NetworkId from WebStoreNetwork LIMIT 1];
        Test.startTest();
        BWC_GetInfo.getProductPrice(w.NetworkId,productInstance.Id,accountInstance.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testAddRelatedServices()
    {
        
        
        

        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
 
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
        
        
        
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id, Status = 'Checkout');
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
        service.BWC_SKU__c='test';
        service.Cart_Item__c=ctItem.Id;
        service.BWC_Cart_Id__c=cart.Id;
        service.BWC_Member_Price__c=20;
        service.BWC_Quantity__c=1;
        service.BWC_ZipCode__c	='40222';
        insert service;
        
      
        //m(String itemId,String zipCode,String skuProduct,String cartId,String quantity)
        List<String> deliverySKU=new List<String>();
        deliverySKU.add('HOME DELIVERY');
        List<String> installationSKU=new List<String>();
        installationSKU.add('FREESTANDING INSTALL');
        system.debug('ctItem.Id=='+ctItem.Id);
        system.debug('cart.Id.Id=='+cart.Id);
               
          Test.startTest();  
        List<BWC_Product_Service__c> serviceList=BWC_GetInfo.addRelatedServices(ctItem.Id,cart.Id,deliverySKU,installationSKU, '1', '40222',new List<String>{'M0850'});

        Test.stopTest();
    }
        @isTest
    public static void testAddRelatedServicesNew()
    {
        
        
        

        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
 
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
        
        
        
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id, Status = 'Checkout');
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
        service.BWC_SKU__c='FREESTANDING INSTALL';
        service.Cart_Item__c=ctItem.Id;
        service.BWC_Cart_Id__c=cart.Id;
        service.BWC_Member_Price__c=20;
        service.BWC_Quantity__c=1;
        service.BWC_ZipCode__c	='40222';
        insert service;
        
      
        //m(String itemId,String zipCode,String skuProduct,String cartId,String quantity)
        List<String> deliverySKU=new List<String>();
        deliverySKU.add('HOME DELIVERY');
        List<String> installationSKU=new List<String>();
        installationSKU.add('FREESTANDING INSTALL');
          Test.startTest();  
                List<BWC_Product_Service__c> serviceList2=BWC_GetInfo.addRelatedServices(ctItem.Id,cart.Id,deliverySKU,installationSKU, '2', '40222',new List<String>{'M0850'});

        Test.stopTest();
    }

    @isTest
    public static void testAddRelatedServicesNew2(){
         Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
 
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
        
        
        
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id, Status = 'Checkout');
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
        service.BWC_SKU__c='FREESTANDING INSTALL';
        service.Cart_Item__c=ctItem.Id;
        service.BWC_Cart_Id__c=cart.Id;
        service.BWC_Member_Price__c=20;
        service.BWC_Quantity__c=1;
        service.BWC_ZipCode__c	='40222';
        insert service;
    List<String> deliverySKU=new List<String>();
        deliverySKU.add('HOME DELIVERY');
        List<String> installationSKU=new List<String>();
        installationSKU.add('FREESTANDING INSTALL');
    List<String> MCode = new List<String>();
    MCode.add('M901');
    {
        Test.startTest();  
                List<BWC_Product_Service__c> serviceList3 = BWC_GetInfo.addRelatedServices(ctItem.Id,cart.Id,deliverySKU,installationSKU, '2','40222',MCode);
        Test.stopTest();
    }
    }
}
@IsTest
public class BWC_ProtectionPlanControllerTest {
 /*  @isTest
    static void testaddDeliveryServices() {
        // Create test data if needed, including any required objects or records
        // Insert necessary data into the database for the test
        
        // Call the method to be tested

        List<String> skuList = new List<String>{'SKU1'};
        String postalCodeInstance = '40222';
       // System.Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockBWC_ADC());
        BWC_ProtectionPlanController.AdditionalServicesWrapper result = BWC_ProtectionPlanController.addDeliveryServices('sku1', postalCodeInstance);
       // System.Test.stopTest();

        // Add assertions to verify the results
      //  System.assertEquals(null, result); // Adjust this assertion based on your expected result
    }
    @isTest
    static void testGetADC_Details() {
        // Create test data if needed, including any required objects or records
        // Insert necessary data into the database for the test
        
        // Call the method to be tested

        List<String> skuList = new List<String>{'SKU1'};
        String postalCodeInstance = '40222';
       // System.Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockBWC_ADC());
        String result = BWC_ProtectionPlanController.getADC_Details(skuList, postalCodeInstance);
       // System.Test.stopTest();

        // Add assertions to verify the results
      //  System.assertEquals(null, result); // Adjust this assertion based on your expected result
    }
*/
    /**
     * @description test setup for creating data
     */
    @TestSetup
    public static void createCustomerUser() {
        Account account = new Account();
        Contact contact = new Contact();

        Test.startTest();
        User user = new User();
        BWC_TestDataFactory.returnSysAdminUser();
        Test.stopTest();
        user = [SELECT Id, Name, UserRoleId FROM User WHERE FirstName = 'Arellano' AND UserRoleId != NULL LIMIT 1];
        account.BillingStreet = 'New York Street';
        account.BillingCity = 'New York';
        account.BillingCountry = 'USA';
        account.BillingPostalCode = '234324';

        account.ShippingStreet = 'Candata Street';
        account.ShippingCity = 'Canada';
        account.ShippingCountry = 'Canada';
        account.ShippingPostalCode = '32432';
        account.Name = 'Buyer Account';
        account.AccountNumber = '50002299';
        account.ownerId = user.Id;

        insert account;

        contact = BWC_TestDataFactory.createContact(true, account.Id);
        User commerceUser = new User();
        commerceUser = BWC_TestDataFactory.createCommerceUser(contact.Id);

        WebStore webStore = new WebStore(Name = 'TestWebStore');
        insert webStore;
        //addStoreIntegratedService(webStore);
    }



    @IsTest
    static void testgetProductDetails() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Buyer Account' LIMIT 1];
        WebStore webStore = [Select Id from WebStore WHERE Name = 'TestWebStore'];
        WebCart cart = new WebCart(Name = 'Cart', WebStoreId = webStore.Id, AccountId = account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
        insert cartDeliveryGroup;
                String planPlus=System.Label.BWC_MonthlyPlusPlanSKU;

        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='test1';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product1';
        insert productRecord;
        
        Product2 productRecord1=new Product2();
        productRecord1.StockKeepingUnit='planPlus';
        productRecord1.Item_Number__c='45678';
        productRecord1.Name='TEST product';
        insert productRecord1;
        Test.startTest();
           BWC_ProtectionPlanController.BundleProtectionWrapperNew result=BWC_ProtectionPlanController.getProductDetails(productRecord.StockKeepingUnit+'~'+productRecord1.StockKeepingUnit,account.Id,'1234');

        Test.stopTest();

    }
    
        @IsTest
    static void testaddPlanAdLineItem() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Buyer Account' LIMIT 1];
        WebStore webStore = [Select Id from WebStore WHERE Name = 'TestWebStore'];
        WebCart cart = new WebCart(Name = 'Cart', WebStoreId = webStore.Id, AccountId = account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
        insert cartDeliveryGroup;
                String planPlus=System.Label.BWC_MonthlyPlusPlanSKU;
//ddPlanAdLineItem(String proId,string cartId,string cartItemId,String quantity) {
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='test1';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product1';
        insert productRecord;
        
        Product2 productRecord1=new Product2();
        productRecord1.StockKeepingUnit='planPlus';
        productRecord1.Item_Number__c='45678';
        productRecord1.Name='TEST product';
        insert productRecord1;
        
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
        
        List<PricebookEntry> standardPriceEntries = new List<PricebookEntry>();
      
            standardPriceEntries.add(new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productRecord.Id,
                UnitPrice = 10.00,
                IsActive = true
            ));
        
        insert standardPriceEntries;
        System.debug('standardPriceEntries' + standardPriceEntries);

                 BWC_Price_Book_Configuration__mdt memberPriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'Member Price Book'];
         String memberPriceBook = memberPriceBookRecord.PriceBookName__c;

         BWC_Price_Book_Configuration__mdt basePriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'BasePriceBook'];
         String basePriceBook = basePriceBookRecord.PriceBookName__c;
       // product2 pro=[select id,StockKeepingUnit from product2 where StockKeepingUnit=:planPlus limit 1];
            // Step 2: Create Member & Base test pricebook for Non Parts
        Pricebook2 testBasePricebook = new Pricebook2(
            Name = basePriceBook,
            IsActive = true
        );
        insert testBasePricebook;
        System.debug('testBasePricebook' + testBasePricebook);

       
        Pricebook2 testMemPricebook = new Pricebook2(
            Name = memberPriceBook,
            IsActive = true
        );
        insert testMemPricebook;
        System.debug('testMemPricebook' + testMemPricebook);

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
       
            pricebookEntries.add(new PricebookEntry(
                Pricebook2Id = testBasePricebook.Id,
                Product2Id = productRecord.Id,
                UnitPrice = 100.00,
                BWC_BasePrice__c=100.00,
                IsActive = true
            ));
        
        insert pricebookEntries;
        System.debug('pricebookEntries' + pricebookEntries);

        List<PricebookEntry> memberPricebookEntries = new List<PricebookEntry>(); 
      
            memberPricebookEntries.add(new PricebookEntry(
                Pricebook2Id = testMemPricebook.Id,
                Product2Id = productRecord.Id,
                UnitPrice = 100.00,
                IsActive = true                
            ));
           
            
        
        insert memberPricebookEntries;
        System.debug('memberPricebookEntries' + memberPricebookEntries);

        Test.startTest();
           BWC_Product_Service__c result=BWC_ProtectionPlanController.addPlanAdLineItem(productRecord.Id,cart.id,ctItem.Id,'1');
BWC_ProtectionPlanController.BundleProtectionWrapperPlan result1= BWC_ProtectionPlanController.getRelatedProPan(ctItem.Id,'1');
        BWC_ProtectionPlanController.BundleProtectionWrapperPlan result2= BWC_ProtectionPlanController.getRelatedProPan(ctItem.Id,'2');

        Test.stopTest();

    }

    @isTest
    static void testAddPartsShippingAsLineItem() {        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        WebCart cart = new WebCart(Name = 'Cart', WebStoreId = webStore.Id, AccountId = ac.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
        insert cartDeliveryGroup;    

        // Create Product2 records
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Product 1', Item_Number__c='GEA_0001_Part1', stockkeepingunit = 'GEA_0001_Part1',MSRP__c=100.0, BWC_MaxOrderQuantity__c=2),
            new Product2(Name = 'Product 2', Item_Number__c='GEA_0002_Part2', stockkeepingunit = 'GEA_0002_Part2',MSRP__c=250.0, BWC_MaxOrderQuantity__c=2)
        };

        insert products;

        // Create CartItems using the Product2 records
        List<CartItem> cartItems = new List<CartItem>();

        for(Product2 product : products) {
            CartItem ctItem = new CartItem();
            
            ctItem.Name = product.Name;
            ctItem.Product2Id = product.Id; // Using the Product2 Id
            ctItem.CartId = cart.Id;
            ctItem.Sku = product.StockKeepingUnit;
            ctItem.Type = 'Product';
            ctItem.CartDeliveryGroupId = cartDeliveryGroup.Id;
            ctItem.Quantity = 1;
            ctItem.SalesPrice = 20;
            ctItem.TotalPrice = 30;
            
            cartItems.add(ctItem); // Add the cartItem to the list
        }

                // Inserting multiple cartItems in one DML operation
                insert cartItems;

        List<String> cartItemIds = new List<String>();
        for(CartItem ctItem : cartItems) {
            cartItemIds.add(ctItem.Id);
        }       

       // BWC_Product_Bundle_Services__mdt partShipFeeMdt = [SELECT Id, BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c = 'Next_Day'];

        List<BWC_Product_Service__c> partShipFeeList = new List<BWC_Product_Service__c>();
        
        for (String cartItemId : cartItemIds) {
            BWC_Product_Service__c partShipFee = new BWC_Product_Service__c();
            partShipFee.Name = 'This is partShipFee Label';
            partShipFee.BWC_Service_Description__c = 'This is partShipFee Description';
            partShipFee.BWC_Service_Price__c = 20.00;
            partShipFee.BWC_Service_Type__c = 'Parts Ship Fee';
            partShipFee.BWC_SKU__c = 'Next_Day';
            partShipFee.Cart_Item__c = cartItems[0].id;
            partShipFee.BWC_Cart_Id__c = cart.id;
            partShipFee.BWC_Quantity__c = 1;
            
            partShipFeeList.add(partShipFee);
            System.debug('partShipFeeList' + partShipFeeList);
        }
        
        insert partShipFeeList;

        Test.startTest();
        List<BWC_Product_Service__c> partResult = BWC_ProtectionPlanController.addPartsShippingAsLineItem('Next_Day',  String.valueOf(cart.Id), cartItemIds);
        //BWC_ProtectionPlanController.BundleProtectionWrapperPlan partResult1= BWC_ProtectionPlanController.getRelatedProPan(cartItems[0].id,'1');

        Test.stopTest();
    }
}
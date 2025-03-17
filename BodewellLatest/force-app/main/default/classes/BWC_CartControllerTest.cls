@isTest
    public class BWC_CartControllerTest {

        @isTest
        static void testGetTaxAmount() {
        Account ac = new Account(name ='Grazitti') ;
        insert ac;         
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        WebCart cart = new WebCart(Name = 'Cart', WebStoreId = webStore.Id, AccountId = ac.Id);
        insert cart;

        List<CartTax> testCartTaxes = new List<CartTax>();
        testCartTaxes.add(new CartTax(Amount = 50));  
        testCartTaxes.add(new CartTax(Amount = 120));   
        //insert testCartTaxes;     
        
        Test.startTest();
        List<CartTax> taxAmount = BWC_CartController.getTaxAmount(String.valueOf(cart.Id));
        Test.stopTest();
        }

        @isTest
        static void testGetBuyerGroup() {
            // Create test Buyer
            Account buyer= new Account();
            buyer.Name = 'Test Buyer';
            insert buyer;
            
            // Create test Buyer Group
            BuyerGroup buyerGroup = new BuyerGroup(Name = 'Test Buyer Group');
            insert buyerGroup;   
            
        
            Test.startTest();
            // Call the method being tested
            List<BuyerGroupMember> result = BWC_CartController.getBuyerGroup(buyer.Id);
            Test.stopTest();
        
        }

        @isTest
        static void testFetchPrices() {
            List<Product2> products = new List<Product2>{
                new Product2(Name = 'Product 1', Item_Number__c='GEA_0001_MemProd1', stockkeepingunit = 'GEA_0001_MemProd1',MSRP__c=0.0, BWC_MaxOrderQuantity__c=2),
                new Product2(Name = 'Product 2', Item_Number__c='GEA_0002_MemProd2', stockkeepingunit = 'GEA_0002_MemProd1',MSRP__c=250.0, BWC_MaxOrderQuantity__c=2)
                         };                             
            insert products;
            System.debug('##products' + products);

           List<String> productIds = new List<String>();
           List<Integer> quantities = new List<Integer>();
           for (Product2 product : products) {
               productIds.add(product.Id);
               quantities.add(2);
           }
           
           System.debug('##Product Ids: ' + productIds);

           //List<Integer> quantities = new List<Integer>{1, 2};

            List<PricebookEntry> standardPriceEntries = new List<PricebookEntry>();
            for (Product2 pro : products) {
                standardPriceEntries.add(new PricebookEntry(
                    Pricebook2Id = Test.getStandardPricebookId(),
                    Product2Id = pro.Id,
                    UnitPrice = 10.00,
                    IsActive = true
                ));
            }
            insert standardPriceEntries;
            System.debug('##standardPriceEntries' + standardPriceEntries);

         //Fetch PriceBook Names
         BWC_Price_Book_Configuration__mdt memberPriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'Member Price Book'];
         String memberPriceBook = memberPriceBookRecord.PriceBookName__c;

         BWC_Price_Book_Configuration__mdt basePriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE DeveloperName = 'BasePriceBook'];
         String basePriceBook = basePriceBookRecord.PriceBookName__c;

         System.debug('##memberPriceBook' + memberPriceBook + 'basePriceBook' + basePriceBook);
            
        // Step 2: Create test pricebook
        Pricebook2 testBasePricebook = new Pricebook2(
            Name = basePriceBook,
            IsActive = true
        );
        insert testBasePricebook;
        System.debug('##testBasePricebook' + testBasePricebook);

        // Step 3: Create Member test pricebook
        Pricebook2 testMemPricebook = new Pricebook2(
            Name = memberPriceBook,
            IsActive = true
        );
        insert testMemPricebook;
        System.debug('##testMemPricebook' + testMemPricebook);
        

        List<PricebookEntry> basePricebookEntries = new List<PricebookEntry>();
        for (Product2 pro : products) {
        basePricebookEntries.add(new PricebookEntry(
            //BWC_Product_MSRP__c=pro.MSRP__c,
            Pricebook2Id = testBasePricebook.Id,
            UnitPrice = 80.0,
            Product2Id = pro.Id
        ));
      /*  basePricebookEntries.add(new PricebookEntry(  
             Pricebook2Id = testBasePricebook.Id,
            UnitPrice = 100.0,
            Product2Id = pro.Id
        ));*/
        }
     
        List<PricebookEntry> memberPricebookEntries = new List<PricebookEntry>();
        for (Product2 pro : products) {
        memberPricebookEntries.add(new PricebookEntry(
           Pricebook2Id = testMemPricebook.Id,
            UnitPrice = 70.0,
            Product2Id = pro.Id
        ));
     /*   memberPricebookEntries.add(new PricebookEntry(
           Pricebook2Id = testMemPricebook.Id,
            UnitPrice = 150.0,
            Product2Id = pro.Id
        ));*/
        }         
insert basePricebookEntries;
      insert memberPricebookEntries;

        Test.startTest();
        Map<String, Object> result = BWC_CartController.fetchPrices(productIds, quantities);
        Test.stopTest();
        
    }













/*
        @testSetup
        static void setupTestData() {
            Account ac = new Account(name ='Test Acc') ;
            insert ac; 
        
            WebStore webStore = new WebStore(Name='Bodewell Store');
            insert webStore;
        
            WebCart testCart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id);
            insert testCart;
        }
        
        @isTest
        static void testUpdateCartStatus() {
            // Retrieve the test data
            List<WebCart> testCarts = [SELECT Id FROM WebCart LIMIT 1];
        
            // Call the method under test
            Test.startTest();
            BWC_CartController.updateCartStatus(testCarts[0].Id, 'Closed');
            Test.stopTest();
        
            // Verify the updated cart status
            WebCart updatedCart = [SELECT Status FROM WebCart WHERE Id = :testCarts[0].Id];
            System.assertEquals('Closed', updatedCart.Status);
        }
        
        @isTest
        static void testGetTaxAmount() {
            // Retrieve the test data
            List<WebCart> testCarts = [SELECT Id FROM WebCart LIMIT 1];
        
            // Call the method under test
            Test.startTest();
            Decimal taxAmount = BWC_CartController.getTaxAmount(testCarts[0].Id);
            Test.stopTest();
        
            // Verify the returned tax amount
            // System.assertEquals(10.0, taxAmount);
        }
 */

        @isTest
        static void testConsumerZip() {
            
            Account acc= new Account();
            acc.Name = 'Test';
            insert acc;
            Test.startTest();
            ContactPointAddress cpa = BWC_CartController.getConsumerZipcode(acc.Id);
            Test.stopTest();
            
        }
        @isTest
        static void testZipServiceRes() {
            
            
            Test.startTest();
            String res = BWC_CartController.getZipcodeServiceInfo2('41114');
            Test.stopTest();
            
        }
        @isTest
        static void testZipServiceDeliveryDates() {
            
            
            Test.startTest();
            String res = BWC_CartController.getDeliveryDates('41114','KY','SDS',new List<String>{'ItemA','ItemB'});
            List<BWC_Product_Bundle_Services__mdt> resp = BWC_CartController.getShipTypeFees();
            Test.stopTest();
            
        }
    }
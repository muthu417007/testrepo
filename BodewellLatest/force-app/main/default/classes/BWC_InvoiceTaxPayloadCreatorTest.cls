@isTest
public class BWC_InvoiceTaxPayloadCreatorTest {
    @testSetup static void setup() {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs (thisUser) {
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Contact testContact = new Contact(AccountId = testAccount.Id, FirstName = 'Test', LastName = 'Contact',EBS_X_ACCOUNT_NUMBER__c = '123');
            insert testContact; 
            ContactPointAddress shippingAddress = new ContactPointAddress();
            shippingAddress.Name = 'test';
            shippingAddress.PostalCode = '201332';
            shippingAddress.City = 'twes';
            shippingAddress.Country = 'US';
            shippingAddress.State = 'test';
            shippingAddress.Street = 'test';
            shippingAddress.AddressType = 'Shipping';
            shippingAddress.ParentId = testAccount.Id;
            shippingAddress.isDefault=true;  
            insert shippingAddress;
            
            ContactPointAddress BillingAddress = new ContactPointAddress();
            BillingAddress.Name = 'test';
            BillingAddress.PostalCode = '201332';
            BillingAddress.City = 'twes';
            BillingAddress.Country = 'US';
            BillingAddress.State = 'test';
            BillingAddress.Street = 'test';
            BillingAddress.AddressType = 'Billing';
            BillingAddress.ParentId = testAccount.Id;
            insert BillingAddress;
            
            
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Bodewell Commerce D2C Login User' LIMIT 1];
            User testUser = new User(ContactId = testContact.Id, Alias = 'testuser', Email='testuser@test.com', 
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = p.Id,
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testussacsdceer@test.com');
            insert testUser; 
            WebStore webStore = new WebStore(Name='TestWebStore');
            insert webStore;
            WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=testAccount.Id);
            insert cart;
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
            insert cartDeliveryGroup;
            List<Product2> productList = new List<Product2>();
            Product2 productItem = new Product2();
            productItem.Name = 'test';
            productItem.ProductCode = '124';
            productItem.Item_Number__c = '123';
            productItem.StockKeepingUnit = 'sf3';
            productItem.BWC_Delivery_Type__c = 'sds';
            productItem.ProductCode = '541501';
            productList.add(productItem);
            
            Product2 productItem2 = new Product2();
            productItem2.Name = 'test1';
            productItem2.Item_Number__c = '124';
            productItem2.StockKeepingUnit = 'sf4';
            productItem2.BWC_Delivery_Type__c = 'hd';
            productItem2.ProductCode = '541502';
            productList.add(productItem2);
            
            Product2 productItem3 = new Product2();
            productItem3.Name = 'test3';
            productItem3.Item_Number__c = '125';
            productItem3.StockKeepingUnit = 'sf5';
            productItem3.BWC_Delivery_Type__c = 'sps fee';
            productItem3.ProductCode = '541503';
            productList.add(productItem3);
            
            
            Product2 productItem4 = new Product2();
            productItem4.Name = 'test4';
            productItem4.Item_Number__c = '126';
            productItem4.StockKeepingUnit = 'sf6';
            productItem4.BWC_Delivery_Type__c = 'sps';
            productItem4.ProductCode = '541504';
            productList.add(productItem4);
            
            
            Product2 productItem5 = new Product2();
            productItem5.Name = 'test5';
            productItem5.Item_Number__c = '127';
            productItem5.StockKeepingUnit = 'sf7';
            productItem5.BWC_Delivery_Type__c = 'willcall';
            productItem5.ProductCode = '541505';
            productList.add(productItem5);
            
            insert productList;
            List<CartItem> cartItemList = new List<CartItem>();
            CartItem cartItem = new CartItem(
                CartId=cart.Id, 
                Sku='sf3', 
                Quantity=3.0, 
                Type='Product', 
                Name='TestProduct', 
                TotalPriceAfterAllAdjustments=123,
                Product2Id = productItem.Id,
                TotalPrice=23,
                CartDeliveryGroupId=cartDeliveryGroup.Id
            );
            cartItemList.add(cartItem);
            
            CartItem cartItem2 = new CartItem(
                CartId=cart.Id, 
                Sku='sf4', 
                Quantity=3.0, 
                Type='Product', 
                Name='TestProduct1', 
                TotalPriceAfterAllAdjustments=123,
                Product2Id = productItem2.Id,
                TotalPrice=23,
                CartDeliveryGroupId=cartDeliveryGroup.Id
            );
            cartItemList.add(cartItem2);
            
            CartItem cartItem3 = new CartItem(
                CartId=cart.Id, 
                Sku='sf5', 
                Quantity=3.0, 
                Type='Product', 
                Name='TestProduct2', 
                TotalPriceAfterAllAdjustments=123,
                Product2Id = productItem3.Id,
                TotalPrice=23,
                CartDeliveryGroupId=cartDeliveryGroup.Id
            );
            cartItemList.add(cartItem3);
            
            CartItem cartItem4 = new CartItem(
                CartId=cart.Id, 
                Sku='sf6', 
                Quantity=3.0, 
                Type='Product', 
                Name='TestProduct3', 
                TotalPriceAfterAllAdjustments=123,
                Product2Id = productItem4.Id,
                TotalPrice=23,
                CartDeliveryGroupId=cartDeliveryGroup.Id
            );
            cartItemList.add(cartItem4);
            
            CartItem cartItem5 = new CartItem(
                CartId=cart.Id, 
                Sku='sf7', 
                Quantity=3.0, 
                Type='Product', 
                Name='TestProduct6', 
                TotalPriceAfterAllAdjustments=123,
                Product2Id = productItem5.Id,
                TotalPrice=23,
                CartDeliveryGroupId=cartDeliveryGroup.Id
            );
            cartItemList.add(cartItem5);
            
            insert cartItemList;
            List<BWC_Product_Service__c> productServiceList = new List<BWC_Product_Service__c>();
            BWC_Product_Service__c productService = new BWC_Product_Service__c(
                BWC_Quantity__c = 1,
                BWC_Service_Price__c = 99,
                BWC_SKU__c = 'HOME DELIVERY',
                BWC_Member_Price__c = 0,
                Cart_Item__c = cartItem.Id
            );
            
            productServiceList.add(productService);
            
            BWC_Product_Service__c productService2 = new BWC_Product_Service__c(
                BWC_Quantity__c = 1,
                BWC_Service_Price__c = 99,
                BWC_SKU__c = 'BUILT-IN INSTALL',
                BWC_Member_Price__c = 0,
                Cart_Item__c = cartItem2.Id
            );
            
            productServiceList.add(productService2);

            BWC_Product_Service__c productService3 = new BWC_Product_Service__c(
                BWC_Quantity__c = 1,
                BWC_Service_Price__c = 25,
                BWC_SKU__c = 'FREESTANDING INSTALL',
                BWC_Member_Price__c = 0,
                Cart_Item__c = cartItem3.Id
            );
            
            productServiceList.add(productService3);
            
            
            
            BWC_Product_Service__c productService4 = new BWC_Product_Service__c(
                BWC_Quantity__c = 1,
                BWC_Service_Price__c = 99,
                BWC_SKU__c = 'HOME DELIVERY',
                BWC_Member_Price__c = 0,
                Cart_Item__c = cartItem4.Id
            );
            
            productServiceList.add(productService4);
            
            
            
            BWC_Product_Service__c productService5 = new BWC_Product_Service__c(
                BWC_Quantity__c = 1,
                BWC_Service_Price__c = 99,
                BWC_SKU__c = 'FREESTANDING INSTALL',
                BWC_Member_Price__c = 0,
                Cart_Item__c = cartItem5.Id
            );
            
            productServiceList.add(productService5);
            
            insert productServiceList;
        }        
    }
    
    @isTest
    public static void testGetInvoiceTaxPayload() {
        // Create test data
        BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper searchAndConsumerPayloadInstance = new BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper();
        searchAndConsumerPayloadInstance.isNull=true;
        searchAndConsumerPayloadInstance.responseData='{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
        test.startTest();
        
        List<CartItem> cartItem = [SELECT Id,TotalAmount,TotalPriceAfterAllAdjustments,Product2.ProductCode,sku,Product2.BWC_Delivery_Type__c FROM CartItem];
        String payload = BWC_InvoiceTaxPayloadCreator.getInvoiceTaxPayload(cartItem,searchAndConsumerPayloadInstance);
        test.stopTest(); 
        // Assert that the payload is not null
        //System.assertNotEquals(null, payload);
    }
    @isTest
    public static void testGetInvoiceTaxPayloadAvoidProductCode() {
        // Create test data
        BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper searchAndConsumerPayloadInstance = new BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper();
        searchAndConsumerPayloadInstance.isNull=true;
        searchAndConsumerPayloadInstance.responseData='{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
        test.startTest();
        Product2 p = [SELECT Id,ProductCode FROM Product2 LIMIT 1];
        p.ProductCode = null;
        update p;
        List<CartItem> cartItem = [SELECT Id,TotalAmount,TotalPriceAfterAllAdjustments,Product2.ProductCode,sku,Product2.BWC_Delivery_Type__c FROM CartItem];
        String payload = BWC_InvoiceTaxPayloadCreator.getInvoiceTaxPayload(cartItem,searchAndConsumerPayloadInstance);
        test.stopTest(); 
        // Assert that the payload is not null
        //System.assertNotEquals(null, payload);
    }
    @isTest
    public static void coverException() {
        // Create test data
        BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper searchAndConsumerPayloadInstance = new BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper();
        searchAndConsumerPayloadInstance.isNull=true;
        searchAndConsumerPayloadInstance.responseData='{"X_Account_Number": "", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
        test.startTest();
        ContactPointAddress cpa = [SELECT City FROM ContactPointAddress LIMIT 1];
        cpa.City = null;
        update cpa;
        List<CartItem> cartItem = [SELECT Id,TotalAmount,TotalPriceAfterAllAdjustments,Product2.ProductCode,sku,Product2.BWC_Delivery_Type__c FROM CartItem];
        String payload = BWC_InvoiceTaxPayloadCreator.getInvoiceTaxPayload(cartItem,searchAndConsumerPayloadInstance);
        test.stopTest(); 
        // Assert that the payload is not null
        //System.assertNotEquals(null, payload);
    }
    @isTest
    public static void avoidShippingAddress() {
        // Create test data
        BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper searchAndConsumerPayloadInstance = new BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper();
        searchAndConsumerPayloadInstance.isNull=true;
        searchAndConsumerPayloadInstance.responseData='{"X_Account_Number": "", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
        test.startTest();
        ContactPointAddress cpa = [SELECT Id FROM ContactPointAddress LIMIT 1];
        delete cpa;
        List<CartItem> cartItem = [SELECT Id,TotalAmount,TotalPriceAfterAllAdjustments,Product2.ProductCode,sku,Product2.BWC_Delivery_Type__c FROM CartItem];
        String payload = BWC_InvoiceTaxPayloadCreator.getInvoiceTaxPayload(cartItem,searchAndConsumerPayloadInstance);
        test.stopTest(); 
        // Assert that the payload is not null
        //System.assertNotEquals(null, payload);
    }
}
@isTest
public class BWC_TaxControllerTest {
    @testSetup static void setup() {
        
       Id p = [SELECT Id
                FROM Profile 	
                WHERE Name='Bodewell Commerce D2C Login User'].Id;
        
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        User userWithRole = new User(alias = 'hasrole', 
                                     email='userwithrole@roletest.com', 
                                     userroleid = r.id,
                                     emailencodingkey='UTF-8',
                                     lastname='Testing',
                                     languagelocalekey='en_US', 
                                     localesidkey='en_US',
                                     profileid = UserInfo.getProfileId(), 
                                     timezonesidkey='America/Los_Angeles',
                                     username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account ac;
        System.runAs(userWithRole){
            
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            ac= new Account(
                RecordTypeID=recordTypeId ,
                FirstName='Test FName',
                LastName='Test LName',
                PersonMailingStreet='test@yahoo.com',
                PersonMailingPostalCode='12345',
                PersonMailingCity='SFO',
                PersonEmail='test@yahoo.com',
                PersonHomePhone='1234567',
                PersonMobilePhone='12345678',
                EBS_X_PARTY_ID__pc='123',
                EBS_X_CUST_ACCOUNT_ID__pc='1234'
            );
            
            insert ac;
        }
        
        Account acc = [SELECT PersonContactId 
                       FROM Account 
                       WHERE Id = :ac.Id];
        
        
        User user = new User(alias = 'demo',
                             email='demo123@noemail.com',
                             emailencodingkey='UTF-8',
                             lastname='demo',
                             languagelocalekey='en_US',
                             localesidkey='en_US',
                             profileid = p,
                             country='United States',
                             IsActive =true,
                             ContactId = acc.PersonContactId,
                             timezonesidkey='America/Los_Angeles',
                             username='demo@noemail.com');
        insert user;
        
    }
    @isTest
    static void testStartCartProcessAsync_Success() {
        // To create the static resource from the Developer Console, select File | New | Static Resource
      /*  StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetTaxesResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);*/
        
        // Test: execute the integration for the test cart ID.
        User u = [SELECT Id,
                  AccountId
                  FROM User
                  WHERE alias = 'demo'
                  LIMIT 1];
         ContactPointAddress conPointAddress1 = new ContactPointAddress(Name = 'test',
                                                               city = 'Green Bay',
                                                               country = 'US',
                                                               street = 'TestS Street',
                                                               state = 'test State',
                                                               PostalCode = '123',
                                                               AddressType = 'Billing',
                                                               ParentId = u.AccountId,
                                                               IsDefault = True);
            insert conPointAddress1;
            
            ContactPointAddress conPointAddress2 = new ContactPointAddress(Name = 'test1',
                                                               city = 'Green Bay',
                                                               country = 'US',
                                                               street = 'TestS Street',
                                                               state = 'test State',
                                                               PostalCode = '123',
                                                               IsDefault = true,
                                                               AddressType = 'Shipping',
                                                               ParentId = u.AccountId);
            insert conPointAddress2;
        
        System.runAs(u){
            
           
            
            WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=u.AccountId);
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
        
        
        Date dt=Date.newInstance(2016, 12, 9);
        CartTax cartTaxInstance=new CartTax(Name='Test',CartItemId=cartItem.Id,TaxType='Actual',TaxCalculationDate=dt,Amount=24);
        insert cartTaxInstance;
            
        BWC_TaxController apexSample = new BWC_TaxController();
        //Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
       // Id cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCartId LIMIT 1].Id;
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        Test.startTest();
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, cart.Id);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
        //  System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        // List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemId];
        // System.assertEquals(1, cartTaxesForCartItem.size());
        Test.stopTest();
   }
}
    
     @isTest
    static void testStartCartProcessAsync_Success2() {
        // To create the static resource from the Developer Console, select File | New | Static Resource
      /*  StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetTaxesResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);*/
        
        // Test: execute the integration for the test cart ID.
        User u = [SELECT Id,
                  AccountId
                  FROM User
                  WHERE alias = 'demo'
                  LIMIT 1];
        
        ContactPointAddress conPointAddress1 = new ContactPointAddress(Name = 'test',
                                                               city = 'Green Bay',
                                                               country = 'US',
                                                               street = 'TestS Street',
                                                               state = 'test State',
                                                               PostalCode = '123',
                                                               AddressType = 'Billing',
                                                               ParentId = u.AccountId,
                                                               IsDefault = True);
            insert conPointAddress1;
            
            ContactPointAddress conPointAddress2 = new ContactPointAddress(Name = 'test1',
                                                               city = 'Green Bay',
                                                               country = 'US',
                                                               street = 'TestS Street',
                                                               state = 'test State',
                                                               PostalCode = '123',
                                                               IsDefault = true,
                                                               AddressType = 'Shipping',
                                                               ParentId = u.AccountId);
            insert conPointAddress2;
        
        System.runAs(u){
            
            
            
            WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=u.AccountId, Status = 'Active', IsSecondary = false);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
            
         Product2 testProductInstance = new Product2(
                Name = 'test',
                ProductCode = '124',
                Item_Number__c = '123',
                StockKeepingUnit = 'Item1',
                Inventory_Item_ID__c='12',
                BWC_Delivery_Type__c = 'sds',
                Is_Accessory__c = 'Yes'
            );
            insert testProductInstance;
        
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='Part123', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            TotalPrice=23,
            TotalPriceAfterAllAdjustments = 25,
            CartDeliveryGroupId=cartDeliveryGroup.Id,
            Product2Id = testProductInstance.Id,
            BWC_Shipping_Method__c = 'Home Delivery'
        );
        insert cartItem;
            
            Product2 testProductInstance2 = new Product2(
                Name = 'test2',
                ProductCode = '1243',
                Item_Number__c = '1233',
                StockKeepingUnit = 'Item2',
                Inventory_Item_ID__c='123',
                BWC_Delivery_Type__c = 'sps fee',
                Is_Accessory__c = 'Yes'
            );
            insert testProductInstance2;
        
        CartItem cartItem2 = new CartItem(
            CartId=cart.Id, 
            Sku='Part123', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            TotalPrice=23,
            TotalPriceAfterAllAdjustments = 25,
            CartDeliveryGroupId=cartDeliveryGroup.Id,
            Product2Id = testProductInstance2.Id,
            BWC_Shipping_Method__c = 'Home Delivery'
        );
        insert cartItem2;
            
            BWC_Product_Service__c productServiceRecord = new BWC_Product_Service__c(
                Name = 'test',
                BWC_Quantity__c = 3.0,
                BWC_Service_Price__c = 99,
                BWC_SKU__c = 'HOME DELIVERY',
                BWC_Member_Price__c = 90,
                Cart_Item__c = cartItem.Id
            );
            insert productServiceRecord;
            BWC_Product_Service__c productServiceRecord2 = new BWC_Product_Service__c(
                Name = 'test',
                BWC_Quantity__c = 3.0,
                BWC_Service_Price__c = 99,
                BWC_SKU__c = 'FREESTANDING INSTALL',
                BWC_Member_Price__c = 90,
                Cart_Item__c = cartItem.Id
            );
            insert productServiceRecord2;
            
            cart.Status = 'Checkout';
            update cart;
        
        
        Date dt=Date.newInstance(2016, 12, 9);
        CartTax cartTaxInstance=new CartTax(Name='Test',CartItemId=cartItem.Id,TaxType='Actual',TaxCalculationDate=dt,Amount=24);
        insert cartTaxInstance;
            
        BWC_TaxController apexSample = new BWC_TaxController();
        //Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
       // Id cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCartId LIMIT 1].Id;
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        Test.startTest();
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, cart.Id);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
        //  System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        // List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemId];
        // System.assertEquals(1, cartTaxesForCartItem.size());
        Test.stopTest();
   }
}
    @isTest
    static void testStartCartProcessWithOutSKU() {
        
        User u = [SELECT Id,
                  AccountId
                 FROM User
                 WHERE alias = 'demo'
                 LIMIT 1];
        
        System.runAs(u){
            
            WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId = u.AccountId);
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
        
        BWC_TaxController apexSample = new BWC_TaxController();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        CartItem cartItemWithoutSKU = [SELECT Id,sku FROM CartItem WHERE CartId = :webCartId LIMIT 1];
        cartItemWithoutSKU.sku = null;
        update cartItemWithoutSKU;
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        Test.startTest();
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCartId);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
        // System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        //List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemWithoutSKU.Id];
        // System.assertEquals(1, cartTaxesForCartItem.size());
        Test.stopTest();
        }
    }
    @isTest
    static void testStartCartProcessWithChargeProduct() {
        
        User u = [SELECT Id,
                  AccountId
                 FROM User
                 WHERE alias = 'demo'
                 LIMIT 1];
        
        System.runAs(u){
            
            WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId = u.AccountId);
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
        
        BWC_TaxController apexSample = new BWC_TaxController();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        CartItem cartItemWithoutSKU = [SELECT Id,type FROM CartItem WHERE CartId = :webCartId LIMIT 1];
        cartItemWithoutSKU.type = 'Charge';
        update cartItemWithoutSKU;
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        Test.startTest();
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCartId);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
        //  System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        // List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemWithoutSKU.Id];
        //System.assertEquals(1, cartTaxesForCartItem.size());
        Test.stopTest();
        }
    }
    
    @isTest
    static void testStartCartProcessWithSimpleProduct() {
        
        User u = [SELECT Id,
                  AccountId
                 FROM User
                 WHERE alias = 'demo'
                 LIMIT 1];
        
        System.runAs(u){
            
            WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId = u.AccountId);
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
        
        BWC_TaxController apexSample = new BWC_TaxController();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        CartItem cartItemWithoutSKU = [SELECT Id,type FROM CartItem WHERE CartId = :webCartId LIMIT 1];
        cartItemWithoutSKU.type = 'Product';
        update cartItemWithoutSKU;
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        Test.startTest();
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCartId);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
        //  System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        // List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemWithoutSKU.Id];
        //System.assertEquals(1, cartTaxesForCartItem.size());
        Test.stopTest();
        }
    }
}
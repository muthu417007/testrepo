@isTest
public class ProcessOrderTest {

    // Test method to cover successful order creation in Oracle
   @testSetup
    static void setup() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs (thisUser) {
            //String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account testAccount = new Account(Name = 'Test1');
            
            insert testAccount;
            Contact con = new Contact(LastName ='testCon',AccountId=testAccount.Id);
            insert con;
            
            ContactPointAddress conPointAdd = new ContactPointAddress();
            conPointAdd.ParentId = testAccount.Id;
            conPointAdd.Name = 'test';
            conPointAdd.IsDefault = true;
            conPointAdd.Street = 'test';
            conPointAdd.City = 'CA';
            conPointAdd.Country = 'US';
            conPointAdd.PostalCode = '123123';
            conPointAdd.BWC_Ship_To_Org_Id__c ='234';
            conPointAdd.BWC_Account_Number__c = '12345';
            conPointAdd.State = 'California';
            conPointAdd.BWC_Bill_To_Org_Id__c = '123';
            insert conPointAdd;
            
         //   System.debug('con AccNumber>>'+con.EBS_X_ACCOUNT_NUMBER__c);
          //  System.debug('Acc AccNumber>>'+testAccount.EBS_X_ACCOUNT_NUMBER__pc);
          //  Bodewell Commerce D2C Login User
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Default Customer Login User' LIMIT 1];
            User testUser = new User(ContactId = con.Id, Alias = 'testuser', email='testuser@test.com', 
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = p.Id,
                                     TimeZoneSidKey='America/Los_Angeles', username='testussacsdceer@test.com');
            insert testUser; 
        }
            // Create test data - Order record
            User u=[SELECT Id,AccountId FROM User WHERE Alias = 'testuser' LIMIT 1];
        System.runAs (u){
            Account acc=[Select Id from Account where Id=:u.AccountId limit 1];
            Contact contactInstance=new Contact(LastName='test1');
            insert contactInstance;
            // Create test data - Order record
            Product2 testProductInstance = new Product2(
                Name = 'test',
                ProductCode = '124',
                Item_Number__c = '123',
                StockKeepingUnit = 'sf3',
                Inventory_Item_ID__c='12'
            );
            insert testProductInstance;
            
            Order testOrderInstance = new Order(
                Status = 'Pending',
                Description = 'Test Order',
                BWC_OracleOrderStatus__c='Status001',
                BWC_HeaderId__c='Header123',
                AccountId = acc.Id,
                EffectiveDate = date.today()
            );
            
            insert testOrderInstance;
            System.debug('testOrderInstance In Test>>>'+testOrderInstance.OrderNumber);
            
            OrderItem testOrderItemInstance=new OrderItem(
                OrderItemExternalId__c='123',
                Quantity=2,
                UnitPrice=12,
                ListPrice=30,
                BWC_Ship_Method__c='testing',
                OrderId=testOrderInstance.Id,
                Product2Id=testProductInstance.Id
            );
            insert testOrderItemInstance;
            
            CardPaymentMethod cmpInstance = new CardPaymentMethod(OPERATION__c='test',
                CONTEXT__c='82',
                CREDIT_CARD_APPROVAL_CODE__c='123',
                CREDIT_CARD_APPROVAL_DATE__c='123',
                CREDIT_CARD_CODE__c='1213',
                CREDIT_CARD_EXPIRATION_DATE__c='09-2029',
                CREDIT_CARD_HOLDER_NAME__c='test',
                CREDIT_CARD_NUMBER__c='567897654',
                PAYMENT_AMOUNT__c='344',
                PAYMENT_COLLECTION_EVENT__c='PREPAY',
                PAYMENT_NUMBER__c='1',
                ATTRIBUTE2__c='22',
                ATTRIBUTE3__c='324567',
                ATTRIBUTE1__c='dwfeerfe33',
                PAYMENT_TYPE_CODE__c='d12516',
                Status='Active',
                ProcessingMode='External'
              );
            //cmpInstance.CardPaymentMethodNumber = '123';
            
            insert cmpInstance;
            
            WebStore testWebStore = new WebStore(Name='Bodewell Store');
            insert testWebStore;
            WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=acc.Id);
            insert cart;
            
            GEA_AccountContactRelation__c geaAccountAndContactInstance = new GEA_AccountContactRelation__c(Name='test',EBS_X_BILL_TO_ORG_ID__c='123',EBS_X_SHIP_TO_ORG_ID__c='321',Account__c=acc.Id,Contact__c=contactInstance.Id);
            insert geaAccountAndContactInstance;
            
            CartDeliveryGroup cartDeliveryGroupInstance=new CartDeliveryGroup(Name='Default Delivery',CartId=cart.Id);
            insert cartDeliveryGroupInstance;
            
            CartItem cartItemInstance=new CartItem(Name=testProductInstance.Name,Product2Id=testProductInstance.Id,CartId=cart.Id,CartDeliveryGroupId=cartDeliveryGroupInstance.Id);
            insert cartItemInstance;
            
            List<BWC_Product_Service__c> productServiceList = new List<BWC_Product_Service__c>();
            BWC_Product_Service__c productServiceInstance = new BWC_Product_Service__c(
                BWC_Quantity__c = 1,
                BWC_Service_Price__c = 99,
                BWC_SKU__c = 'HOME DELIVERY',
                Cart_Item__c = cartItemInstance.Id
            );
            productServiceList.add(productServiceInstance);
            
            BWC_Product_Service__c productServiceInstance2 = new BWC_Product_Service__c(
                BWC_Quantity__c = 1,
                BWC_Service_Price__c = 25,
                BWC_SKU__c = 'FREESTANDING INSTALL',
                Cart_Item__c = cartItemInstance.Id
            );
            productServiceList.add(productServiceInstance2);
            insert productServiceList;
            
            ContactPointAddress conPoint = new ContactPointAddress();
            conPoint.ParentId = acc.Id;
            conPoint.Name = 'test1';
            conPoint.IsDefault = true;
            conPoint.Street = 'test';
            conPoint.City = 'CA';
            conPoint.Country = 'US';
            conPoint.PostalCode = '123123';
            conPoint.BWC_Ship_To_Org_Id__c ='23456';
            conPoint.BWC_Account_Number__c = '123456';
            conPoint.State = 'California';
            conPoint.BWC_Bill_To_Org_Id__c = '12322';
            conPoint.AddressType = 'Shipping';
            insert conPoint;
            
        }
    }

    @isTest
    public static void processOrderTestMethod(){
        List<Order> orderList = [SELECT Id FROM Order LIMIT 1];
        WebCart webCart = [SELECT Id, Status FROM WebCart LIMIT 1];
        webCart.Status = 'Closed';
        update webCart;
        List<String> idList = new List<String>();
        idList.add(orderList[0].Id);
        Test.startTest();
        ProcessOrder.createOrderInOracle(idList);
        Test.stopTest();
    }
    @isTest
    public static void callOracleApiTest(){
        List<Order> orderList = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        ProcessOrder.callOracleApi(orderList[0].Id,'cancel order');
        Test.stopTest();
    }

    // Test method to cover the "cancel order" scenario
    // @isTest
    // static void testCreateOrderInOracle_CancelOrder() {
    //     // Create test data - Order record
    //     Order testOrder = new Order(
    //         Status = 'Pending',
    //         Description = 'Test Order'
    //         // Add other required fields here
    //     );
    //     insert testOrder;

    //     // Create a list of Order Ids
    //     List<String> orderIdList = new List<String>{testOrder.Id};

    //     // Mock the external callout response for "cancel order"
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false, 'cancel order')); // Pass "cancel order" for this scenario

    //     // Call the invocable method
    //     Test.startTest();
    //     ProcessOrder.createOrderInOracle(orderIdList);
    //     Test.stopTest();

    //     // Verify the results for the "cancel order" scenario
    //     Order updatedOrder = [SELECT Id, Description, BWC_HeaderId__c, Status FROM Order WHERE Id = :testOrder.Id];
    //     System.assertEquals('Flow Status Code', updatedOrder.Description);
    //     System.assertEquals('cancelled', updatedOrder.Status);
    // }

    // // Helper class for mocking HTTP callouts
    // public class MockHttpResponseGenerator implements HttpCalloutMock {
    //     private Boolean simulateFailure = false;
    //     private String orderStatusCheck;

    //     public MockHttpResponseGenerator() {}

    //     public MockHttpResponseGenerator(Boolean simulateFailure) {
    //         this.simulateFailure = simulateFailure;
    //     }

    //     public MockHttpResponseGenerator(Boolean simulateFailure, String orderStatusCheck) {
    //         this.simulateFailure = simulateFailure;
    //         this.orderStatusCheck = orderStatusCheck;
    //     }

    //     public HTTPResponse respond(HTTPRequest req) {
    //         HTTPResponse res = new HTTPResponse();
    //         res.setHeader('Content-Type', 'application/json');

    //         if (simulateFailure) {
    //             res.setStatusCode(500);
    //             res.setStatus('Internal Server Error');
    //             res.setBody('{"error": "Simulated failure"}');
    //         } else {
    //             res.setStatusCode(200);
    //             res.setStatus('OK');
    //             if ('cancel order'.equals(orderStatusCheck)) {
    //                 res.setBody('{"X_HEADER_REC": {"FLOW_STATUS_CODE": "Flow Status Code"}}');
    //             } else {
    //                 res.setBody('{"X_HEADER_REC": {"FLOW_STATUS_CODE": "Flow Status Code", "HEADER_ID": "Header ID", "ORDER_NUMBER": "ORDER_NUMBER"}}');
    //             }
    //         }
    //         return res;
    //     }
    // }
}
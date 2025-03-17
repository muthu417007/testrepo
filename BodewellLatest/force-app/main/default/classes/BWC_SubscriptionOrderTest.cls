@isTest
public class BWC_SubscriptionOrderTest {
    @testSetup
    public static void testSetupMethod(){
        
        Account testAccount = new Account(
            Name = 'Test1'
        );
        insert testAccount;
        
        Product2 testProductInstance = new Product2(
            Name = 'test',
            ProductCode = '124',
            Item_Number__c = '123',
            StockKeepingUnit = 'Item1',
            Inventory_Item_ID__c = '12',
            BWC_Delivery_Type__c = 'sds'
        );
        insert testProductInstance;
        
        
        Order testOrderInstance = new Order(
            Status = 'Pending',
            Description = 'Test Order',
            BWC_OracleOrderStatus__c = 'Status001',
            BWC_HeaderId__c = 'Header123',
            EffectiveDate = date.today(),
            AccountId = testAccount.Id
        );
        
        insert testOrderInstance;
        System.debug('testOrderInstance In Test>>>'+testOrderInstance.OrderNumber);
        
        OrderItem testOrderItemInstance = new OrderItem(
            OrderItemExternalId__c = '123',
            Quantity = 2,
            UnitPrice = 12,
            ListPrice = 30,
            BWC_Ship_Method__c = 'testing',
            BWC_SO_Order_Frequency__c = '1.0',
            OrderId = testOrderInstance.Id,
            Product2Id = testProductInstance.Id
        );
        insert testOrderItemInstance;
    }
    
    @isTest
    public static void subscriptionOrder(){
        Order orderInstance = [SELECT Id,
                               BWC_HeaderId__c
                               FROM Order
                               LIMIT 1];
        
        Test.startTest();
        String result = BWC_SubscriptionOrder.subscriptionOrder(orderInstance);
        Test.stopTest();
    }
}
@isTest
public class BWC_SubscriptionOrderBatchTest {
    @isTest
    public static void testBatchExecution() {
        Account ac = new Account(name ='testacc');
        insert ac;
        
        Order order = new Order(BWC_OracleOrderStatus__c = 'BOOKED',
                BWC_HeaderId__c = 'TestHeaderId',
                AccountId = ac.Id,
                EffectiveDate = date.today(),
              	Status = 'Pending',
                Description = 'Test Order');
        insert order;
        
        Product2 testProduct = new Product2(
            Name='Test Product',
            StockKeepingUnit='test',
            Inventory_Item_ID__c='123',
            Item_Type__c='test',
            Item_Number__c = '123'
        );
        insert testProduct;
        
        OrderItem testOrderItem = new OrderItem(
            OrderItemExternalId__c='123',
            Quantity=2,
            ListPrice=30,
            BWC_Ship_Method__c='testing',
            OrderId=order.Id,
            Product2Id=testProduct.Id,
            UnitPrice = 123
        );
        insert testOrderItem;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        BWC_SubscriptionOrderBatch batch = new BWC_SubscriptionOrderBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Order> Orders = [SELECT Id, BWC_OracleOrderStatus__c FROM Order WHERE BWC_OracleOrderStatus__c = 'BOOKED'];
        System.assertEquals(1, Orders.size());
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"mockKey": "mockValue"}');
            res.setStatusCode(200);
            return res;
        }
    }
}
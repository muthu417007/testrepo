@isTest
public class BWC_OrderSummaryTestClass {

    // Create a test Order Summary record
    public static OrderSummary createTestOrderSummary() {
        OrderSummary orderSummary = new OrderSummary();
        orderSummary.OrderNumber = 'TEST123';
        orderSummary.AccountId = '001000000000001';
      //  orderSummary.OriginalOrderId = '001000000000002';
        insert orderSummary;
        return orderSummary;
    }

    // Test that the Order Summary is created correctly
    public static testMethod void testCreateOrderSummary() {
        OrderSummary orderSummary = createTestOrderSummary();

        // Assert that the Order Summary record was created
        System.assertEquals(1, [SELECT Id FROM OrderSummary WHERE Id = :orderSummary.Id].size());

        // Assert that the Order Summary fields are populated correctly
        System.assertEquals('TEST123', orderSummary.OrderNumber);
        System.assertEquals('001000000000001', orderSummary.AccountId);
        System.assertEquals('001000000000002', orderSummary.OriginalOrderId);
    }

    // Test that the Order Summary can be updated correctly
    public static testMethod void testUpdateOrderSummary() {
        OrderSummary orderSummary = createTestOrderSummary();

        // Update the Order Summary record
        orderSummary.OrderNumber = 'TEST456';
        update orderSummary;

        // Assert that the Order Summary record was updated
        System.assertEquals(1, [SELECT Id FROM OrderSummary WHERE Id = :orderSummary.Id AND OrderNumber = 'TEST456'].size());
    }

    // Test that the Order Summary can be deleted correctly
    public static testMethod void testDeleteOrderSummary() {
        OrderSummary orderSummary = createTestOrderSummary();

        // Delete the Order Summary record
        delete orderSummary;

        // Assert that the Order Summary record was deleted
        System.assertEquals(0, [SELECT Id FROM OrderSummary WHERE Id = :orderSummary.Id].size());
    }
}
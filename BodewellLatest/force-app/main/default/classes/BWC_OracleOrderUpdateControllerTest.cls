@IsTest(SeeAllData=true)
public class BWC_OracleOrderUpdateControllerTest {
    @isTest
    public static void getOrderSummaryDetailsTest(){
        List<OrderItemSummary> orderItemSummaryInstance = [SELECT Id,orderSummaryId FROM OrderItemSummary limit 1];
        BWC_OracleOrderUpdateController.BWC_OracleOrderUpdateWrapper inputWrapper = new BWC_OracleOrderUpdateController.BWC_OracleOrderUpdateWrapper();
        for (OrderItemSummary item : orderItemSummaryInstance) {
            BWC_OracleOrderUpdateController.Item inputItem = new BWC_OracleOrderUpdateController.Item();
            inputItem.Id = item.Id;
            inputItem.orderSummaryId = item.OrderSummaryId;
            inputWrapper.item.add(inputItem);
        }
        System.Test.startTest();
        BWC_OracleOrderUpdateController.BWC_OracleOrderUpdateWrapper oracleUpdateWrapper = new BWC_OracleOrderUpdateController.BWC_OracleOrderUpdateWrapper();
        oracleUpdateWrapper.item = BWC_OracleOrderUpdateController.getOrderSummaryDetails(inputWrapper);
        System.Test.stopTest();
        
    }
    @isTest
    public static void getBillingAddressTest(){
        OrderSummary orderSummaryInstance=[Select Id from OrderSummary limit 1];
        System.Test.startTest();
        Object objInstance=BWC_OracleOrderUpdateController.getBillingAddress(orderSummaryInstance.Id);
        System.Test.stopTest();
    }
    @isTest
    public static void getShippingAddressTest(){
        OrderSummary orderSummaryInstance=[Select Id from OrderSummary limit 1];
        System.Test.startTest();
        Object objInstance=BWC_OracleOrderUpdateController.getShippingAddress(orderSummaryInstance.Id);
        System.Test.stopTest();
    }
    @isTest
    public static void getOrderSummaryIdTest(){
        System.Test.startTest();
        OrderSummary orderSummaryInstance= [SELECT Id, OrderNumber FROM OrderSummary limit 1];
        Object objInstance=BWC_OracleOrderUpdateController.getOrderSummaryId(orderSummaryInstance.OrderNumber);
        System.Test.stopTest();
    }
        @isTest
    public static void getOrderAmountTest(){
        System.Test.startTest();
        OrderSummary orderSummaryInstance= [SELECT Id, OrderNumber FROM OrderSummary limit 1];
        Object objInstance=BWC_OracleOrderUpdateController.getOrderAmount(orderSummaryInstance.Id);
        System.Test.stopTest();
    }
    @isTest
    public static void getProductDetailsTest(){
      //  BWC_OracleOrderUpdateController classInstance = new BWC_OracleOrderUpdateController();
        OrderItemSummary orderItemSummaryInstance=[Select Id from OrderItemSummary limit 1];
        List<BWC_OracleOrderUpdateController.ProductWrapper> productWrapperList=BWC_OracleOrderUpdateController.getProductDetails(new List<Id>{orderItemSummaryInstance.Id});
    }
}
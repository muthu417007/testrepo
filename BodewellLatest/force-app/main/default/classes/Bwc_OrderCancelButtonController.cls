public class Bwc_OrderCancelButtonController {
    @AuraEnabled
    public static void cancelOrderRequest(Id orderSummaryIdInstance){
        System.debug('orderSummaryIdInstance-->'+orderSummaryIdInstance);
        Ordersummary orderSummaryInstance = [SELECT OriginalOrderId,
                                             Originalorder.BWC_HeaderId__c 
                                             FROM Ordersummary 
                                             WHERE Id =: orderSummaryIdInstance];
        String jsonString = BWC_CancelOrderJsonGenerator.cancelPayloadGenerator(orderSummaryInstance.Originalorder.BWC_HeaderId__c);
        //ProcessOrder.callOracleApi(jsonString,orderSummaryInstance.OriginalOrderId,'cancel order');
    }
}
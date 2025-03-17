global class BWC_UpdateOrdersDataBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('inside start method');
        return Database.getQueryLocator([
            SELECT Id, BWC_Oracle_Order_Number__c,Status FROM Order WHERE (Status!='Cancelled' and Status!='Returned') and BWC_Oracle_Order_Number__c='1046416433' LIMIT 1
     	]);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> ordersList) {
        system.debug('inside execute method');
        List<Order> ordersToUpdate = new List<Order>();
        List<Order> orderLineItemsToUpdate = new List<Order>();
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        system.debug('orders list '+ordersList);
        // Process each order
        for (sObject obj : ordersList) {
            Order order = (Order)obj;
            system.debug('order number '+order.BWC_Oracle_Order_Number__c);
            String reqbody = '{"P_ORDER_NUMBER":'+integer.valueof(order.BWC_Oracle_Order_Number__c)+'}';
            String orderDetailResp;
            if(utility.isSandbox){
            	orderDetailResp= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','THD_MDO_Orders_Token','THD_MDO_OrdersDetail',null,'POST',reqbody);
            }
            else {
                orderDetailResp= RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','Prod_OrderDetails',null,'POST',reqbody);
            }
        
            if (orderDetailResp != null) {
                ProcessOrderDetailResponseWrapper jsonResp = (ProcessOrderDetailResponseWrapper)JSON.deserialize(orderDetailResp, ProcessOrderDetailResponseWrapper.class);
    			system.debug('tracking number '+jsonResp.P_OUT_LINE_TBL.P_OUT_LINE_TBL_ITEMS[0].CUSTOMER_JOB);
                
                for(OrderItem oi : [Select Id,BWC_Oracle_Line_Id__c, BWC_Shipping_Tracking_Number__c from OrderItem where OrderId = :order.Id]) {
                    for(Integer t=0; t < jsonResp.P_OUT_LINE_TBL.P_OUT_LINE_TBL_ITEMS.size(); t++) {
                        if(jsonResp.P_OUT_LINE_TBL.P_OUT_LINE_TBL_ITEMS[t].LINE_ID == oi.BWC_Oracle_Line_Id__c) {
                            oi.BWC_Shipping_Tracking_Number__c = jsonResp.P_OUT_LINE_TBL.P_OUT_LINE_TBL_ITEMS[t].CUSTOMER_JOB;
                    		orderItemsToUpdate.add(oi);
                        }
                    }
                }
                
                
                //ordersToUpdate.add(order);
            }
        }
        
        // Update the order records
        update orderItemsToUpdate;
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('inside finish method');
        // Perform any post-processing tasks if needed
    }
    
    
    
    
    

}
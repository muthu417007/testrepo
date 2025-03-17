/**
* @author Abhishek
* @date 07/02/2024
* @description This is the batch class which is used to hit create subscription api to ebs.
*/
global class BWC_SubscriptionOrderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
/*
* @description This is start method of the batch in this we are querying order with booked and one flag where clause
* @param context - Database.BatchableContext
* @return Database.QueryLocator
*/
    public Database.QueryLocator start(Database.BatchableContext context) {
        String orderStatus = 'BOOKED';
        String query = 'SELECT Id, BWC_OracleOrderStatus__c,BWC_HeaderId__c,BWC_BILLING_PLAN_HEADER_ID__c,OwnerId, AccountId FROM Order where BWC_OracleOrderStatus__c=' + orderStatus + ' AND BWC_BILLING_PLAN_HEADER_ID__c = null AND BWC_HeaderId__c != null';
        return Database.getQueryLocator(query); 
    }
    /*
* @description This is execute method of the batch in this we are calling BWC_SubscriptionOrder apex class to hit the create subsription api
* @param BC - Database.BatchableContext
* @param orderList - This param is used to get list of orders from start method
* @return 
*/
    global void execute(Database.BatchableContext BC, List<Order> orderList){
        List<Order> orderUpdateList = new List<Order>();
        List<Subscription__c> subscriptionList = new List<Subscription__c>();
        if(!orderList.isEmpty()){
            for(Order order : orderList){
                //order.BWC_BILLING_PLAN_HEADER_ID__c = BWC_SubscriptionOrder.subscriptionOrder(order);
                Map<String, List<String>> headerIdOrderProdId = BWC_SubscriptionOrder.subscriptionOrder(order);
                if(headerIdOrderProdId.size() != 0)
                {
                    for(String billingPlanHeaderId : headerIdOrderProdId.keySet())
                    {
                        list<String> OrderProdIdList = headerIdOrderProdId.get(billingPlanHeaderId);
                        order.BWC_BILLING_PLAN_HEADER_ID__c = billingPlanHeaderId;
                        for(String OrderProdId : OrderProdIdList)
                        {
                            Subscription__c sub = new Subscription__c();
                            sub.Order__c = order.Id;
                            sub.Account__c = order.AccountId;
                            sub.Order_Product__c = OrderProdId;
                            sub.OwnerId = order.OwnerId;
                            subscriptionList.add(sub);
                        }
                        orderUpdateList.add(order);
                    }
                }
                

               
            }
            update orderUpdateList;
            update subscriptionList;
        }
    }
    /*
* @description This is finish method of the batch
* @return 
*/
    global void finish(Database.BatchableContext BC){
        
    }
}
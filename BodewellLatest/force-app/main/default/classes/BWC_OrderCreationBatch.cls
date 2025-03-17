global class BWC_OrderCreationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    final String ORDER_STATUS = 'BOOKED';
    public Database.QueryLocator start(Database.BatchableContext context) {
        String ids = '8018B000000Wk1UQAS';
        String query = 'SELECT Id, BWC_Ship_To_Org_Id__c, BWC_Bill_To_Org_Id__c, BillingPhoneNumber, AccountId, BWC_ORIG_SYS_DOCUMENT_REF__c, OrderReferenceNumber, BillToContactId, BWC_OracleOrderStatus__c, BWC_HeaderId__c, BWC_Oracle_Order_Payload__c, BWC_Oracle_Order_Response__c, BWC_Consumer_Name__c, BWC_Consumer_Number__c, Status, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, CreatedbyId, CreatedBy.Account.BWC_Consumer_Number__c FROM Order WHERE BWC_OracleOrderStatus__c != :ORDER_STATUS AND Id =: ids LIMIT 1';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Order> orderList){
        try {
            if(!orderList.isEmpty()){
                for(Order orderIns : orderList){
                    JSONGenerator jsonString = bwc_OrderCreationBatchPayload.getJson(new List<Order>{orderIns});
                    processOrder(jsonString, orderIns);
                }
            }
        }
        catch(Exception ex){
            system.debug('Error message '+ex.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    public static void processOrder(JSONGenerator gen, Order ord){
        String jsonString = gen != null ? gen.getAsString() : '';
        String response;
        String closedStatus = 'Closed';
        List<OrderItem> orderItemList = new List<OrderItem>();
        Map<String,String> productSkuVSJsonLineId = new Map<String,String>();
        if(!test.isRunningTest()){
            if(utility.isSandbox){
                response = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudProcessOrderQA',null,'POST',jsonString);
            }
            else{
                response = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudProcessOrder',null,'POST',jsonString);
            }
        }
        else{
            response='{"X_HEADER_REC": {"HEADER_ID": "Header123","FLOW_STATUS_CODE": "BOOKED","ORDER_NUMBER": "Order123"},"X_LINE_TBL":{"X_LINE_TBL_ITEM": [{"LINE_ID": "Line1","ORDERED_ITEM": "sf3"}]}}';
        }
        ProcessOrderResponseWrapper jsonData = (ProcessOrderResponseWrapper)JSON.deserialize(response, ProcessOrderResponseWrapper.class);
        
        ord.BWC_Oracle_Order_Payload__c = jsonString;
        ord.BWC_OracleOrderStatus__c = jsonData.X_HEADER_REC.FLOW_STATUS_CODE; 
        ord.BWC_HeaderId__c = jsonData.X_HEADER_REC.HEADER_ID;
        ord.Order_Number__c = jsonData.X_HEADER_REC.ORDER_NUMBER;
        ord.Status = jsonData.X_HEADER_REC.FLOW_STATUS_CODE;
        update ord;
        
        for(Integer i = 0;i < jsonData.X_LINE_TBL.X_LINE_TBL_ITEM.size();i++){
            productSkuVSJsonLineId.put(jsonData.X_LINE_TBL.X_LINE_TBL_ITEM[i].ORDERED_ITEM,jsonData.X_LINE_TBL.X_LINE_TBL_ITEM[i].LINE_ID);
        }
        
        for(OrderItem orderItemInstance : [SELECT Id, OrderItemExternalId__c, Product2.StockKeepingUnit FROM OrderItem 
                                           WHERE OrderId =: ord.Id AND Type!='Delivery Charge']){
                                               if(productSkuVSJsonLineId.containsKey(orderItemInstance.Product2.StockKeepingUnit)){
                                                   orderItemInstance.OrderItemExternalId__c = productSkuVSJsonLineId.get(orderItemInstance.Product2.StockKeepingUnit);
                                                   orderItemList.add(orderItemInstance);                
                                               }
                                           }
        update orderItemList;
    }
}
/**
* @author Abhishek Bisht
* @date 19/09/2023
* @description The purpose of this class is to get the Order Item summary, Billing and shipping addresses, and Product details that will used in the Lwc Component.
* */

public class BWC_OracleOrderUpdateController {

    /*
    * @description This Class is a wrapper class for getOrderSummaryDetails method.
    * @param taking no params
    */
    public class BWC_OracleOrderUpdateWrapper{
        @AuraEnabled public List<Item> item = new List<Item>();
    }
    public class Item{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String orderSummaryId;
        @AuraEnabled
        public String media;
        @AuraEnabled
        public Double quantity;
        @AuraEnabled
        public Double subtotal;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String skuInstance;
        @AuraEnabled
        public String orderNumberInstance;
        @AuraEnabled
        public String orderDescription;
        @AuraEnabled
        public String productId;
    }

    /*
    * @description This method is used to get the Order Item summary,
    * @param orderSummaryIdObjectList - This parameter is coming from lwc Component BWC_orderConfirmationPage.
    * @return List<Item>
    */
    @AuraEnabled
    public static List<Item> getOrderSummaryDetails(Object orderSummaryIdObjectList){
        try{
        System.debug('orderSummaryIdObjectList-->'+orderSummaryIdObjectList);
        String serializeOrderSummary = JSON.serialize(orderSummaryIdObjectList);
        System.debug('serializeOrderSummary-->'+serializeOrderSummary);
        BWC_OracleOrderUpdateWrapper data =  (BWC_OracleOrderUpdateWrapper) JSON.deserialize(serializeOrderSummary, BWC_OracleOrderUpdateWrapper.class);
        //System.debug('data-->'+data.item[0].orderSummaryId);
        Set<Id> orderSummaryIdSet = new Set<Id>();
        for(Item itemInstance : data.item){
            orderSummaryIdSet.add(itemInstance.orderSummaryId);
        }
        Map<Id, OrderItemSummary> idVsOrderItemSummaryMap = new Map<Id, OrderItemSummary>([SELECT Id,
                                                                                           TotalLineAmount,
                                                                                           Quantity,
                                                                                           StockKeepingUnit,
                                                                                           product2.name,
                                                                                           product2.Description,
                                                                                           product2.Id,
                                                                                           OrderSummary.OriginalOrder.OrderNumber
                                                                                           FROM OrderItemSummary 
                                                                                           WHERE OrderSummaryId IN : orderSummaryIdSet]);
        for(Item itemInstance : data.item){
            if(idVsOrderItemSummaryMap.containsKey(itemInstance.Id)){
                itemInstance.orderNumberInstance = idVsOrderItemSummaryMap.get(itemInstance.Id).OrderSummary.OriginalOrder.OrderNumber;
                itemInstance.quantity = idVsOrderItemSummaryMap.get(itemInstance.Id).Quantity;
                itemInstance.subtotal = idVsOrderItemSummaryMap.get(itemInstance.Id).TotalLineAmount;
                itemInstance.productName = idVsOrderItemSummaryMap.get(itemInstance.Id).product2.name;
                itemInstance.skuInstance = idVsOrderItemSummaryMap.get(itemInstance.Id).StockKeepingUnit;
                itemInstance.orderDescription = idVsOrderItemSummaryMap.get(itemInstance.Id).product2.Description;
                itemInstance.productId = idVsOrderItemSummaryMap.get(itemInstance.Id).product2.Id; 
            }
        }
        System.debug('data-->'+data.item);
        return data.item;
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    }

    /*
    * @description This method is used to get the Billing Address of an order,
    * @param orderSummaryIdObjectList - This parameter is coming from lwc Component BWC_orderConfirmationPage.
    * @return Object
    */
    @AuraEnabled(cacheable=true)
    public static Object getBillingAddress(Id orderSummaryIdInstance){
        try{
        return [SELECT Id, 
                BillingAddress 
                FROM OrderSummary 
                WHERE Id =: orderSummaryIdInstance][0].BillingAddress;
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    }

    /*
    * @description This method is used to get the Shipping Address of an order,
    * @param orderSummaryIdObjectList - This parameter is coming from lwc Component BWC_orderConfirmationPage.
    * @return Object
    */
    @AuraEnabled(cacheable=true)
    public static Object getShippingAddress(Id orderSummaryIdInstance){
        try{
        return [SELECT Id, 
                DeliverToAddress, 
                DeliverToPostalCode, 
                TotalLineAmount 
                FROM OrderDeliveryGroupSummary 
                WHERE OrderSummaryId =: orderSummaryIdInstance];
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static Object getOrderSummaryId(string orderNumber){
        try{
        return [SELECT Id, OrderNumber FROM OrderSummary where orderNumber = :orderNumber];
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    }

  @AuraEnabled(cacheable=true)
    public static String getCurrentCartId(string accountId){
        try{
        return [SELECT Id,accountId,createddate, status FROM Webcart where status ='Closed' and accountId=:accountId order by createddate Desc][0].Id;
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    }
     @AuraEnabled(cacheable=true)
    public static List<cartItem> getCurrentCartItems(string cartId){
        try{
        return [SELECT Id  ,BWC_Shipping_Method__c, BWC_Ship_Date__c,product2.BWC_Delivery_Type__c,product2.BWC_Product_Marketing_Description__c,product2.stockKeepingUnit,cartId FROM cartItem where cartId=:cartId ];
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Object getOrderAmount(Id orderSummaryId){
        try{
        return [SELECT Id, TotalAdjustedProductTaxAmount,TotalAdjustedProductAmount, TotalAdjDistAmount, TotalAdjustedDeliveryAmount, GrandTotalAmount FROM OrderSummary where Id = :orderSummaryId];
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    }
    
    /*
    * @description This method is used to get the DelivaryType,and Name etc.
    * @param orderSummaryIdObjectList - This parameter is coming from lwc Component BWC_orderConfirmationPage.
    * @return List<ProductWrapper>
    */
    @AuraEnabled
    public static List<ProductWrapper> getProductDetails(List<Id> orderItemSummaryList){
        try{
        List<ProductWrapper> productWrappers = new List<ProductWrapper>();
        for(OrderItemSummary summary : [SELECT Id, 
                                        product2.Name, 
                                        product2.BWC_Delivery_Type__c, 
                                        product2.BWC_Is_Part__c, 
                                        product2.BWC_Accessories__c 
                                        FROM OrderItemSummary 
                                        WHERE Id IN :orderItemSummaryList]){
                                            ProductWrapper wrapper = new ProductWrapper();
                                            ProductDetails details = new ProductDetails();
                                            Fields fields = new Fields();
                                            
                                            fields.Name = summary.product2.Name;
                                            fields.partInstance = summary.product2.BWC_Is_Part__c;
                                            fields.deliveryTypeInstance = summary.product2.BWC_Delivery_Type__c;
                                            fields.accessoriesInstacne = summary.product2.BWC_Accessories__c;
                                            
                                            details.fields = fields;
                                            wrapper.ProductDetails = details;
                                            
                                            productWrappers.add(wrapper);
                                        }
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+productWrappers);
        return productWrappers;
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    } 
    
    /*
    * @description This is the wrapper used in the method getProductDetails
    */
    public class ProductWrapper {
        @AuraEnabled public ProductDetails ProductDetails;
    }
    
    /*
    * @description This is the wrapper used in the Class ProductWrapper
    */
    public class ProductDetails {
        @AuraEnabled public Fields fields;
    }
    
    /*
    * @description This is the wrapper used in the Class ProductDetails
    */
    public class Fields {
        @AuraEnabled public String Name;
        @AuraEnabled public Boolean partInstance; //BWC_Is_Part__c;
        @AuraEnabled public String deliveryTypeInstance; //BWC_Delivery_Type__c;
        @AuraEnabled public String accessoriesInstacne; //BWC_Accessories__c;
    }
    
    
    /* public static void deleteOrderItemSummary(Object orderSummaryIdObjectList){
System.debug('orderSummaryIdObjectList-->'+orderSummaryIdObjectList);
String serializeOrderSummary = JSON.serialize(orderSummaryIdObjectList);
System.debug('serializeOrderSummary-->'+serializeOrderSummary);
BWC_OracleOrderUpdateWrapper data =  (BWC_OracleOrderUpdateWrapper) JSON.deserialize(serializeOrderSummary, BWC_OracleOrderUpdateWrapper.class);
Set<Id> orderSummaryIdSet = new Set<Id>();
for(Item itemInstance : data.item){
orderSummaryIdSet.add(itemInstance.orderSummaryId);
}
Set<Id> orderIdSet = new Set<Id>();
List<Order> updateOrderList = new List<Order>();
//List<OrderItemSummary> updateOrderSummaryItemList = new List<OrderItemSummary>();
for(OrderItemSummary oIS : [SELECT Id,OrderSummary.OriginalOrderId FROM OrderItemSummary WHERE OrderSummaryId IN : orderSummaryIdSet]){
orderIdSet.add(oIS.OrderSummary.OriginalOrderId);
}
for(Order orderInstance : [SELECT Id,Status FROM Order WHERE Id IN : orderIdSet]){
orderInstance.Status = 'Draft';
updateOrderList.add(orderInstance);
}
update updateOrderList;
delete [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId IN : orderSummaryIdSet];
for(Order orderInstance : [SELECT Id,Status FROM Order WHERE Id IN : orderIdSet]){
orderInstance.Status = 'Activated';
updateOrderList.add(orderInstance);
}
update updateOrderList;

}*/
}
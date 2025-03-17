public class BWC_DeliveryTypeUtility {
    public static void getDeliveryTypeData(Id cartIdInstance){
        Map<String, List<CartItem>> cartItemsMap = new Map<String, List<CartItem>>();
        for(cartItem cartItemInstance : [SELECT Id,
                                         product2.BWC_Delivery_Type__c,
                                         quantity
                                         FROM CartItem 
                                         WHERE cartId =: cartIdInstance 
                                         AND product2.BWC_Delivery_Type__c != null
                                         LIMIT 1]){
                                             if(!cartItemsMap.containsKey(cartItemInstance.product2.BWC_Delivery_Type__c)){
                                                 cartItemsMap.put(cartItemInstance.product2.BWC_Delivery_Type__c,new List<CartItem>());
                                             }
                                             cartItemsMap.get(cartItemInstance.product2.BWC_Delivery_Type__c).add(cartItemInstance);
                                         }
        System.debug('cartItemsMap-->'+cartItemsMap);
    }
}
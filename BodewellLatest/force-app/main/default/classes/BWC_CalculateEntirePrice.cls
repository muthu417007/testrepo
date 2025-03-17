/**
* @author Abhishek Bisht
* @date 06/12/2023
* @description The purpose of this class is to calculate all services amount.
* */
public class BWC_CalculateEntirePrice {
    /*
* @description This method is called in OrderBodyCreater and Bwc_InvoiceTaxPayloadCreater class to add total amount into the payload.
* @param cartItemList - This parameter contains all the cartItems added into the cart.
* @return Double
*/
    @AuraEnabled(cacheable = true)
    public static Double calculateTotalAmount(Id cartId){
        try{
            Double totalAmountService=0;
            Boolean isHD = false;
            Boolean isSDS = false;
            List<CartItem> cartItemList = [SELECT Id,
                                           Product2.BWC_Delivery_Type__c,
                                           BWC_Shipping_Method__c
                                           FROM CartItem
                                           WHERE CartId =:cartId];
            
            for(CartItem ctItem: cartItemList){
                if(ctItem.Product2.BWC_Delivery_Type__c == 'sds' &&  ctItem.BWC_Shipping_Method__c != 'Will Call'){
                    totalAmountService += 150;
                    isSDS = true;
                    break;
                }
            }
            for(BWC_Product_Service__c productServiceRecord: [SELECT Id,
                                                              BWC_SKU__c,
                                                              BWC_Service_Price__c,
                                                              Cart_Item__r.Product2.BWC_Delivery_Type__c
                                                              FROM BWC_Product_Service__c
                                                              WHERE Cart_Item__c IN: cartItemList]){
                                                                  if(!isHD && ('HOME DELIVERY').equals(productServiceRecord.BWC_SKU__c)){
                                                                      totalAmountService += productServiceRecord.BWC_Service_Price__c;
                                                                      isHD = true;
                                                                  }
                                                                  else if(('HOME DELIVERY').equals(productServiceRecord.BWC_SKU__c) && isHD){
                                                                      continue;
                                                                  }
                                                                  else{
                                                                      totalAmountService += productServiceRecord.BWC_Service_Price__c;
                                                                  }
                                                                  // For Delivery oversize product
                                                                  if(('sds').equals(productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c) && !isSDS){
                                                                      totalAmountService += 150;
                                                                      isSDS = true;
                                                                  }  
                                                                  // For Delivery oversize product
                                                              }
            return totalAmountService;
        }catch(Exception e){
            System.debug('Exception in Bwc_InvoiceTaxPayloadCreator-->'+e.getMessage()+'at line Number-->'+e.getLineNumber());
            return null;
        }
        
    }
}
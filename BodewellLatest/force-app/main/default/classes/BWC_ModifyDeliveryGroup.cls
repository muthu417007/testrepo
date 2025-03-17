/**
* @author Abhishek Bisht
* @date 15/12/2023
* @description The purpose of this class is to resolve the checkout conflict in checkout page
* */
public class BWC_ModifyDeliveryGroup {
    /*
* @description The purpose of this method is to update current delivery group
* @param 
* @return Boolean
*/
    @AuraEnabled
    public static Boolean updateCurrentDeliveryGroup(){
        try{
            final String chargeProductName = 'Shipping Charge for this delivery method';
            List<CartDeliveryGroup> cartDeliveryGroupList = [SELECT Id,
                                                             DeliveryMethodId
                                                             FROM CartDeliveryGroup
                                                             WHERE CreatedById = :userInfo.getUserId()
                                                             Order By CreatedDate DESC
                                                             LIMIT 1];
            
            if(cartDeliveryGroupList[0].DeliveryMethodId != null){
                return true;
            }
            else{
                List<OrderDeliveryMethod> orderDeliveryMethodList = [SELECT Id,
                                                                     ProductId
                                                                     FROM OrderDeliveryMethod
                                                                     WHERE CreatedById = :userInfo.getUserId()
                                                                     LIMIT 1];
                
                if(!orderDeliveryMethodList.isEmpty()){
                    cartDeliveryGroupList[0].DeliveryMethodId = orderDeliveryMethodList[0].Id;
                }
                else{
                    Id productId = [SELECT Id
                                    FROM Product2
                                    WHERE Name = :chargeProductName
                                    LIMIT 1][0].Id;
                    OrderDeliveryMethod orderDeliveryMethodRecord = new OrderDeliveryMethod();
                    orderDeliveryMethodRecord.Name = 'Order Delivery Method 1';
                    orderDeliveryMethodRecord.ProductId = productId;
                    insert orderDeliveryMethodRecord;
                    
                    cartDeliveryGroupList[0].DeliveryMethodId = orderDeliveryMethodRecord.Id;
                }
                update cartDeliveryGroupList;
            }
            return true;
        }catch(Exception e){
            System.debug('Exception coming as-> '+e.getMessage()+'in BWC_ModifyDeliveryGroup apex class at Line Number-> '+e.getLineNumber());
            return false;
        }
    } 
}
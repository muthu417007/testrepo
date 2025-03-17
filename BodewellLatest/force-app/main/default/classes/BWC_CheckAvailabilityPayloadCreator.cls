/**
* @author Abhishek Bisht
* @date 22/08/2023
* @description The purpose of this class is to generate a payload for checking inventory related to the BDC-696 ticket.
* */
public class BWC_CheckAvailabilityPayloadCreator {
    /*
* @description The purpose of this technique is to generate a payload for the current item in the shopping cart based on the user who is logged in to the website.
* @param cartItemList - Here is a collection of CartItem.
* @return String
*/
    public static String getAvailabilityPayload(List<CartItem> cartItemList, Id userIdInstance){
       // try{
            List<User> userInstance = [SELECT AccountId,
                                       Account.EBS_X_ACCOUNT_NUMBER__pc,
                                       BWC_Current_Location_ZipCode__c
                                       FROM User 
                                      // WHERE Id =: UserInfo.getUserId() 
                                      WHERE Id =: userIdInstance
                                       LIMIT 1];
            
            System.debug('cartItemListINPayloadCreator>>>'+cartItemList);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartArray();
            for(CartItem cartItemInstance : cartItemList){
                gen.writeStartObject();
                gen.writeStringField('inventoryItemName', cartItemInstance.sku);
                System.debug('cartItemInstance.sku>>>'+cartItemInstance.sku);
                gen.writeNumberField('quantityOrdered', cartItemInstance.Quantity);
                System.debug('quantity>>>'+ cartItemInstance.Quantity);
                Datetime GMTDate = DateTime.now() + 1;
                String strConvertedDate = GMTDate.format('yyyy-MM-dd');
                gen.writeStringField('requestDate', strConvertedDate);
                System.debug('strConvertedDate>>>'+strConvertedDate);
                gen.writeStringField('quantityUOM', 'EA');
                gen.writeNumberField('orderLineIdentifier', 1);
                //gen.writeStringField('zipCode', userInstance[0].BWC_Current_Location_ZipCode__c);
                gen.writeStringField('zipCode',userInstance[0].BWC_Current_Location_ZipCode__c);
                // gen.writeStringField('accountNumber', userInstance[0].Account.EBS_X_ACCOUNT_NUMBER__pc);
               // gen.writeStringField('accountNumber', '4653999');

                //gen.writeStringField('itemType', cartItemInstance.Product2.Item_Type__c);
                if(cartItemInstance.Product2.BWC_Is_Part__c == false){
                    gen.writeStringField('itemType', 'FG');
                }
                else{
                    gen.writeStringField('itemType', 'PARTS_ITEM');
                }
                System.debug('cartItemInstance.Product2.Item_Type__c???'+cartItemInstance.Product2.Item_Type__c);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            String jsonString = gen.getAsString();
            System.debug('jsonString-->'+jsonString);
            return jsonString;
        }
       /* catch(Exception e){
            System.debug('Exception-->'+e.getMessage());
            System.debug('Exception line number-->'+e.getLineNumber());
            return null;
        }
    }*/
}
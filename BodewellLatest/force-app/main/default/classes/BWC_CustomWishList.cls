public without sharing class BWC_CustomWishList {
    
      
     @AuraEnabled(cacheable=false)
    public static List<WishListItem> getWishlistItems()
  {
        try{
            List<WishListItem> wishListItemList = [SELECT Id,
                                                   Product2Id,
                                                   Product2.BWC_Product_Marketing_Description__c,
                                                   Product2.BWC_Main_Image__c,
                                                   WishlistId
                                                   FROM WishListItem 
                                                   WHERE WishlistId = :[SELECT Id 
                                          								FROM Wishlist 
                                          								WHERE CreatedById = :UserInfo.getUserId()
                                                                        LIMIT 1][0].Id];
            System.debug('wishListItemList-->'+wishListItemList);
            return wishListItemList;
        }
      catch(Exception e){
          System.debug('Exception message BWC_CustomWishList-->' + e.getMessage());
          System.debug('Exception Line number BWC_CustomWishList-->' + e.getLineNumber());
          return null;
      }
  } 
    
    
    /*https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_removeWishlistItem_1 */
      @AuraEnabled
      public static Void removeItemFromWishlist(String communityId, String effectiveAccountId,String wishListId, String wishlistItemId ){
          try{
       String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);    
        
       
         ConnectApi.CommerceWishlist.removeWishlistItem(
                            webstoreId,
                            effectiveAccountId,
                            wishListId,
                            wishlistItemId
                        );
              }
           catch(Exception e){
          System.debug('Exception message BWC_CustomWishList-->' + e.getMessage());
          System.debug('Exception Line number BWC_CustomWishList-->' + e.getLineNumber());
          
      }
          
    }
    
     public class WishListInformation {
        @AuraEnabled
        public Boolean isDeleted;
        @AuraEnabled
        public String errorMessage;
        
      
    }
    
    /* @AuraEnabled(cacheable=false)
    public static String getWishList(){
        try{
            
            Id wishlistId = [SELECT Id FROM Wishlist 
                                       WHERE CreatedById = :UserInfo.getUserId()
                                      LIMIT 1][0].id;
            String strWishListId = String.valueOf(wishlistId);
                return strWishListId;
            
        }
         catch(Exception e){
          System.debug('Exception message BWC_CustomWishList-->' + e.getMessage());
          System.debug('Exception Line number BWC_CustomWishList-->' + e.getLineNumber());
          return null;
      }
    }  */

    
    
   /* 
     
    
     
    
      @AuraEnabled(cacheable=true)   
    public static ConnectApi.PricingResult getProducPriceWishListPage(
        String communityId,
        String effectiveAccountId,
        List<String> productIds
    ) {
        try{
            // Lookup the webstore ID associated with the community
            String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
            
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
            return ConnectApi.CommerceStorePricing.getProductPrices(
                webstoreId,
                effectiveAccountId,
                productIds
            );
        }catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    } */
    
  
}
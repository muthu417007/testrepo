public class BWC_addItemToCartMember {

   /* @AuraEnabled
  Public Static ConnectApi.CartItem  addmembershipToCart(String cartId,String userID,String communityID,String proId )
  {
      ID contactId = [Select contactid from User where id =: userID].contactId;

      ID AccID  = [Select AccountID from Contact where id =: contactid].AccountId;

  // Lookup the webstore ID associated with the community

  String webstoreId = resolveCommunityIdToWebstoreId(communityID);



  
  ConnectApi.CartInput cartInput=new ConnectApi.CartInput();
  cartInput.effectiveAccountId=AccID;
    
      if(cartId==null)
      {
          ConnectApi.CartSummary cartSummary= ConnectApi.CommerceCart.createCart(webstoreId,cartInput );
          ConnectApi.CartItemInput input=new ConnectApi.CartItemInput();
          input.productId=proId;
          input.quantity='1';
          input.type=ConnectApi.CartItemType.PRODUCT;
            
          return ConnectApi.CommerceCart.addItemToCart(webstoreId, AccID,cartSummary.cartId, input);
      }
      else {
          ConnectApi.CartItemInput input=new ConnectApi.CartItemInput();
          input.productId=proId;
          input.quantity='1';
          input.type=ConnectApi.CartItemType.PRODUCT;
            
          return ConnectApi.CommerceCart.addItemToCart(webstoreId, AccID,cartId, input);
          
      }
    

  }
  /**

  * @description Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning

  * @param  communityId The Id of the community from which the call originated

  * @return weStoreId The webStoreId corresponding to the community Id.

  * @example

  * String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId('0DB2D0000004Xz7');



public static String resolveCommunityIdToWebstoreId(String communityId) {
  Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();
  if (communityIdToWebStoreIdCache.containsKey(communityId)) {

    return communityIdToWebStoreIdCache.get(communityId);

  } else {

    String webStoreId = [

      SELECT WebStoreId

      FROM WebStoreNetwork

      WHERE NetworkId = :communityId

      WITH SECURITY_ENFORCED

      LIMIT 1

    ].WebStoreId;

    communityIdToWebStoreIdCache.put(communityId, webStoreId);

    return webStoreId;

  }
}

  */


     @AuraEnabled
    public static CartItem bwc_CreateCartItemMethod(String productId,String quantity,Decimal unitPrice) {
          CartItem ctItem=new CartItem();
        try{
          
         List<WebCart> cartList=[Select Id from WebCart where Status='Active' OR Status='Checkout' limit 1];
         System.debug('cartList>>'+cartList);
         Product2 productRecord=[Select Id,Name,StockKeepingUnit from Product2 where Id=:productId limit 1];
         if(cartList.isEmpty()){
            System.debug('insideIf');
            Id accountIdInstance = [Select AccountId from User where Id =:UserInfo.getUserId() LIMIT 1][0].AccountId;
            System.debug('accId>>'+accountIdInstance);
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name = 'Bodewell Store' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=accountIdInstance);
        insert cart;
        
             cartList.add(cart);
         }
         CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cartList[0].Id, Name='Default Delivery');
        insert cartDeliveryGroup;
         if(productId!=null && quantity!=null && unitPrice!=null && productRecord.StockKeepingUnit!=null){
       
         ctItem.Name=productRecord.Name;
         ctItem.Product2Id=productId;
         ctItem.CartId=cartList[0].Id;
         ctItem.Sku=productRecord.StockKeepingUnit;    
         ctItem.Type='Product';
         ctItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
         ctItem.Quantity=Integer.valueOf(quantity);
         ctItem.SalesPrice=unitPrice;
         ctItem.ListPrice=unitPrice;    
         ctItem.UnitAdjustedPrice=unitPrice;
         ctItem.TotalPrice=unitPrice;
         

         insert ctItem;
         System.debug('ctItem>>'+ctItem);
          
         }
        }
        catch(DMLException e){
            System.debug('Error>>'+e.getMessage()+'   >>>LineNumber>>'+e.getLineNumber());
        }
  return ctItem;
    }
    

  
}
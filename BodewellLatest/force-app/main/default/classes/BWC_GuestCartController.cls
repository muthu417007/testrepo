/**
 * @description Controller for the BWC_guestCartListener component
 */
public without sharing class BWC_GuestCartController {

    private static final String SOURCE_CLASS = 'BWC_GuestCartController';
    private static final String LEVEL = 'Error';

    /**
     * @description Updates the guest cart with the guestUUID
     * @param {String} cartId - The id of the guest cart to update
     * @param {String} guestUUID - The guestUUID to update the cart with
     * @return {void} This method will return nothing on success, it will throw an exception on failure
     */
    @AuraEnabled
    public static void updateGuestCart(String cartId, String guestUUID) {
        try {
            List<WebCart> carts = [SELECT BWC_GuestUUID__c FROM WebCart WHERE Id = :cartId LIMIT 1];

            if (carts.size() > 0) {
                carts[0].BWC_GuestUUID__c = guestUUID;
                update carts;
            }
        } catch (Exception e) {
            CX_Logger logger = new CX_Logger();
            logger.logMessage(LEVEL, SOURCE_CLASS, 'updateWebCart', e.getMessage(), null, null, null);
            if(!Test.isRunningTest()){
            throw new AuraHandledException(e.getMessage());
            }
        }
    }

    /**
     * @description Preserves the guest cart for later retrieval
     * @param {String} effectiveAccountId - The id of the account to use for the new cart created from the cloned guest cart
     * @param {String} ownerId - The User Id of the owner of the new cart created from the cloned guest cart
     * @param {String} guestUUID - The guestUUID of the guest cart to preserve
     * @return {void}
     */
    @AuraEnabled
    public static void preserveGuestCart(String effectiveAccountId, String ownerId, String guestUUID,String communityId) {
        try {
            WebCart guestCart = findGuestCart(guestUUID);

            if (guestCart != null) {
                // Check if there is a current cart for the user based on ownerId and AccountId
                // if there is a current cart then update it's Status to "PendingDelete"
                updateCurrentCartToSecondary(effectiveAccountId, ownerId);

                cloneGuestCart(guestCart, effectiveAccountId, ownerId,communityId);

                guestCart.Status = 'PendingDelete';
                update guestCart;
            }

        } catch (Exception e) {
            CX_Logger logger = new CX_Logger();
            logger.logMessage(LEVEL, SOURCE_CLASS, 'preserveGuestCart', e.getMessage(), null, null, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Finds the guest cart based on the guestUUID
     * @param {String}
     */
    private static WebCart findGuestCart(String guestUUID) {
        WebCart guestCart = null;
        List<WebCart> guestCarts = [SELECT Id, Name, AccountId, BWC_GuestUUID__c, IsSecondary, Status, WebStoreId
                                    FROM WebCart
                                    WHERE BWC_GuestUUID__c = :guestUUID
                                    AND Status = 'Active'
                                    ORDER BY CreatedDate Desc
                                    LIMIT 1];

        if (guestCarts.size() > 0) {
            guestCart = guestCarts[0];
        }
        return guestCart;
    }

    /**
     * @description Updates the current cart to secondary
     * @param {String} effectiveAccountId - The Id of the account for the logged in user
     * @param {String} ownerId - The User Id of the logged in user
     * @return {void}
     */
    private static void updateCurrentCartToSecondary(String effectiveAccountId, String ownerId) {
        List<WebCart> currentCarts = [SELECT Id, Status
                                      FROM WebCart
                                      WHERE AccountId = :effectiveAccountId
                                      AND OwnerId = :ownerId
                                      AND (Status = 'Active' OR Status ='Processing' OR Status = 'Checkout')];
        if (currentCarts.size() > 0) {
            for (WebCart cart: currentCarts) {
                cart.IsSecondary = true;
            }
            update currentCarts;
        }
    }

    /**
     * @description Clones the guest cart
     * @param {WebCart} guestCart - The guest cart to be cloned
     * @param {String} effectiveAccountId - The Id of the account for the logged in user
     * @param {String} ownerId - The User Id of the logged in user
     * @return {void}
     */
    private static void cloneGuestCart(WebCart guestCart, String effectiveAccountId, String ownerId,String communityId) {
      /*  WebCart newCart = guestCart.clone();
        newCart.AccountId = effectiveAccountId;
        newCart.OwnerId = ownerId;
        newCart.Name = 'PreservedGuestCart-' + System.now().format();
        insert newCart;*/

        List<CartItem> guestCartItems = [SELECT Id, Name, Type, Sku, Quantity, CartId, SalesPrice, TotalPrice, Product2Id, CartDeliveryGroupId, CreatedById
                                        FROM CartItem
                                        WHERE CartId = :guestCart.id];

          BWC_GetInfo.ProductInformation pinfo=addItemsToCart(communityId,guestCartItems,effectiveAccountId);
      
        
      /*  List<CartItem> newCartItems = new List<CartItem>();

        for (CartItem guestCartItem : guestCartItems) {
            CartItem newCartItem = guestCartItem.clone();
            newCartItem.CartId = newCart.Id;
            newCartItems.add(newCartItem);
        }

        insert newCartItems;*/
    }
    
     @AuraEnabled
    public static BWC_GetInfo.ProductInformation addItemsToCart(
        String communityId,
       List<CartItem> productIds,
     
        String effectiveAccountId
      
    ) {
        BWC_GetInfo.ProductInformation productInformationInstance = new BWC_GetInfo.ProductInformation();
        try{
            
           
            //new Changes
            List<WebCart> cartList = new List<WebCart>();
            if(!Test.isRunningTest()){
                cartList = [SELECT Id, 
                                      Status 
                                      FROM WebCart 
                                      WHERE (Status = 'Checkout' 
                                      OR Status = 'Active')
                                      AND CreatedById = :UserInfo.getUserId()
                                      AND IsSecondary = False
                                      Order By CreatedDate desc 
                                      LIMIT 1];
            }
            else{
                cartList = [SELECT Id, 
                                      Status 
                                      FROM WebCart 
                                      WHERE (Status = 'Checkout' 
                                      OR Status = 'Active')
                                      AND IsSecondary = False
                                      Order By CreatedDate desc 
                                      LIMIT 1];
            }
            System.debug('cartList-->'+cartList);
            if(cartList.IsEmpty()){
                System.debug('inside empty if');
                ConnectApi.CartSummary cartSummaryInstance = BWC_GetInfo.createCart(communityId,effectiveAccountId); // It is an alternative solution and it can work default too.
            }
            else if(cartList[0].Status == 'Checkout'){
                    cartList[0].Status = 'Active';
                    Update cartList;
            }
            
            //new Changes
            
            String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
             List<ConnectApi.BatchInput> cartInputs1=new List<ConnectApi.BatchInput>();
            List<ConnectApi.CartItemInput> cartInputs = new List<ConnectApi.CartItemInput>();
            for(CartItem pid:productIds)
            {
              ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
                cartInput.productId = pid.Product2Id;
            cartInput.quantity= String.valueOf(pid.Quantity);
            cartInput.type = ConnectApi.CartItemType.PRODUCT; 
               ConnectApi.BatchInput binput=new ConnectApi.BatchInput(cartInput);
           cartInputs1.add(binput);
            }
           
            
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
          ConnectApi.BatchResult[]  ctItem=ConnectApi.CommerceCart.addItemsToCart(
                webstoreId,
                effectiveAccountId,
                'active',
                cartInputs1
            );
            //Shubhada changes  
      //  List<BWC_Product_Service__c> listService=addRelatedServices(ctItem.cartItemId,ctItem.cartId,deliverySku,installationSku,quantity,zipCode,mcodeSku);
            if(!cartList.IsEmpty()){
                cartList[0].Status = 'Checkout';
                //Update cartList;
            }
            productInformationInstance.isAddedToCart = true;
            productInformationInstance.errorMessage = null;
            //Shubhada Changes
            
           // productInformationInstance.cartInformation=ctItem;

            return productInformationInstance;
        }catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            // throw newMessageException(e);
            productInformationInstance.isAddedToCart = false;
            productInformationInstance.errorMessage = e.getMessage();
            return productInformationInstance;
        }
    }
    
}
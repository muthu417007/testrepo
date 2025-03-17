public without sharing class BWC_GetInfo {
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductDetail getProduct(
        String communityId,
        String productId,
        String effectiveAccountId
    ) {
        try{
            // Lookup the webstore ID associated with the community
            String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
            
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
            return ConnectApi.CommerceCatalog.getProduct(
                webstoreId,
                productId,
                effectiveAccountID,
                null,
                false,
                null,
                false,
                true,
                false
            );
        }
        catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
        String communityId,
        String effectiveAccountId
    ) {
        try{
            // Lookup the webstore ID associated with the community
            String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
            
            //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
            //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
            String activeCartOrId = 'current';
            
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
            return ConnectApi.CommerceCart.getCartSummary(
                webstoreId,
                effectiveAccountId,
                activeCartOrId
            );
        }
        catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static ConnectApi.CartSummary createCart(
        String communityId,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        System.debug('inside createCart method');
        String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
        ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
        cartInput.effectiveAccountId = effectiveAccountId;
        //shubhadaChange
       // cartInput.name= 'PreservedGuestCart-' + System.now().format();
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return ConnectApi.CommerceCart.createCart(webstoreId, cartInput);
    }
    
    @AuraEnabled
    public static ProductInformation addToCart(
        String communityId,
        String productId,
        String quantity,
        String effectiveAccountId,
        //Shubhada Changes
        list<String>   deliverySku,
        list<String> installationSku,
        List<String> mcodeSku,
        String zipCode
    ) {
        ProductInformation productInformationInstance = new ProductInformation();
        try{
            
            // Lookup the webstore ID associated with the community
            Product2 productData=[Select Id,ProductClass,StockKeepingUnit,BWC_Exploded_Diagram_Parts__c from Product2 where Id=:productId limit 1];
            system.debug('Product Data'+productData);
            String sku;
            if(productData.ProductClass == 'VariationParent'){
            String inputString = productData.BWC_Exploded_Diagram_Parts__c;
            String innerObjectString = inputString.substringBetween('{', '}');
            List<String> keyValuePairs = innerObjectString.split(',');
            Map<String, String> keyValueMap = new Map<String, String>();
            for (String keyValuePair : keyValuePairs) {
                List<String> parts = keyValuePair.split(':');
                sku = parts[2].trim().replaceAll('["\']', '');
            }
            }
            else{
                sku = productData.StockKeepingUnit;
            }
            Id prodId = [Select Id from Product2 where StockKeepingUnit = :sku][0].Id;
            //new Changes
            List<WebCart> cartList = [SELECT Id, 
                                      Status 
                                      FROM WebCart 
                                      WHERE (Status = 'Checkout' 
                                      OR Status = 'Active')
                                      AND CreatedById = :UserInfo.getUserId()
                                      AND IsSecondary = False
                                      Order By CreatedDate desc 
                                      LIMIT 1];
            System.debug('cartList-->'+cartList);
            if(cartList.IsEmpty()){
                System.debug('inside empty if');
                ConnectApi.CartSummary cartSummaryInstance = createCart(communityId,effectiveAccountId); // It is an alternative solution and it can work default too.
            }
            else if(cartList[0].Status == 'Checkout'){
                    cartList[0].Status = 'Active';
                    Update cartList;
            }
            
            //new Changes
            
            String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
            
            ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
            cartInput.productId = prodId;
            cartInput.quantity = quantity;
            cartInput.type = ConnectApi.CartItemType.PRODUCT;
            
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
            ConnectApi.CartItem ctItem=ConnectApi.CommerceCart.addItemToCart(
                webstoreId,
                effectiveAccountId,
                'active',
                cartInput
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
            
            productInformationInstance.cartInformation=ctItem;

            return productInformationInstance;
        }catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            // throw newMessageException(e);
            productInformationInstance.isAddedToCart = false;
            productInformationInstance.errorMessage = e.getMessage();
            return productInformationInstance;
        }
    }
    
    public class ProductInformation {
        @AuraEnabled
        public Boolean isAddedToCart;
        @AuraEnabled
        public String errorMessage;
        //Shubhada Changes
         @AuraEnabled
        public  ConnectApi.CartItem cartInformation;
      
    }
    
    //Shubhada Changes
    public static List<BWC_Product_Service__c> addRelatedServices( String cartItemId,String cartId,list<String>   deliverySku,list<String> installationSku,string quantity,String zipCode,list<String> mcodeSku)
    {
        try{
            List<BWC_Product_Service__c> serviceList=new List<BWC_Product_Service__c>();
            List<BWC_Product_Service__c> updateserviceList=new List<BWC_Product_Service__c>();
            //installationSku.add('FREESTANDING INSTALL 2STEP');
            //BWC_Quantity__c   
            List<BWC_Product_Service__c> existingServices=[Select Id,BWC_ZipCode__c,BWC_Member_Price__c, Name, BWC_SKU__c, BWC_Service_Type__c, Cart_Item__c, BWC_Service_Description__c,BWC_Quantity__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId and BWC_Service_Type__c='Installation' and BWC_ZipCode__c=:zipCode and BWC_Quantity__c=:Integer.valueOf(quantity)  ];
            List<BWC_Product_Bundle_Services__mdt> deliveryServices=[SELECT Id, BWC_Member_Price__c,DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:deliverySku];
            List<BWC_Product_Bundle_Services__mdt> installationServices=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN :installationSku];
                        List<BWC_Product_Bundle_Services__mdt> mcodesServices=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN :mcodeSku];
if(mcodesServices.size()>0)
{
       for(BWC_Product_Bundle_Services__mdt mdt:mcodesServices)
            {
                BWC_Product_Service__c service=new BWC_Product_Service__c();
                service.Name=mdt.Label;
                service.BWC_Service_Description__c=mdt.Description__c;
                service.BWC_Service_Price__c=mdt.Price__c;
                service.BWC_Service_Type__c='MCode';
                service.BWC_SKU__c=mdt.Product_SKU__c;
                service.Cart_Item__c=cartItemId;
                service.BWC_Cart_Id__c=cartId;
                service.BWC_Member_Price__c=mdt.BWC_Member_Price__c;
                service.BWC_Quantity__c=1;
                service.BWC_ZipCode__c  =zipCode;
                serviceList.add(service);
            }
}
         
        if(deliveryServices.size()>0)
{    
            
            for(BWC_Product_Bundle_Services__mdt mdt:deliveryServices)
            {
                BWC_Product_Service__c service=new BWC_Product_Service__c();
                service.Name=mdt.Label;
                service.BWC_Service_Description__c=mdt.Description__c;
                service.BWC_Service_Price__c=mdt.Price__c;
                service.BWC_Service_Type__c='Delivery';
                service.BWC_SKU__c=mdt.Product_SKU__c;
                service.Cart_Item__c=cartItemId;
                service.BWC_Cart_Id__c=cartId;
                service.BWC_Member_Price__c=mdt.BWC_Member_Price__c;
                service.BWC_Quantity__c=1;
                service.BWC_ZipCode__c  =zipCode;
                serviceList.add(service);
            }
}
            if(existingServices.size()>0)
            {
            
                if(installationServices.size()>0)
                {
                     for(BWC_Product_Bundle_Services__mdt mdt:installationServices)
                {
                    BWC_Product_Service__c service=new BWC_Product_Service__c();
                    service.Name=mdt.Label;
                    service.BWC_Service_Description__c=mdt.Description__c;
                    service.BWC_Service_Price__c=(mdt.Price__c)*Integer.valueOf(quantity);
                    service.BWC_Service_Type__c='Installation';
                    service.BWC_SKU__c=mdt.Product_SKU__c;
                    service.Cart_Item__c=cartItemId;
                    service.BWC_Cart_Id__c=cartId;
                    service.BWC_Quantity__c=Integer.valueOf(quantity);
                    service.BWC_Member_Price__c=(mdt.BWC_Member_Price__c)*Integer.valueOf(quantity);
                    service.BWC_ZipCode__c=zipCode;
                    updateserviceList.add(service);
                } 
                }
                   
                
            }
            else
            {
                for(BWC_Product_Bundle_Services__mdt mdt:installationServices)
                {
                    BWC_Product_Service__c service=new BWC_Product_Service__c();
                    service.Name=mdt.Label;
                    service.BWC_Service_Description__c=mdt.Description__c;
                    service.BWC_Service_Price__c=(mdt.Price__c)*Integer.valueOf(quantity);
                    service.BWC_Service_Type__c='Installation';
                    service.BWC_SKU__c=mdt.Product_SKU__c;
                    service.Cart_Item__c=cartItemId;
                    service.BWC_Cart_Id__c=cartId;
                    service.BWC_Quantity__c=Integer.valueOf(quantity);
                    service.BWC_Member_Price__c=(mdt.BWC_Member_Price__c)*Integer.valueOf(quantity);
                    service.BWC_ZipCode__c=zipCode;
                    serviceList.add(service);
                }  
            }
            
            if(serviceList.size()>0)
            {
                insert serviceList;
            }
            if(updateserviceList.size()>0)
            {
                update updateserviceList;
            }
            return serviceList;
        }catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistItem createAndAddToList(
        String communityId,
        String productId,
        String wishlistName,
        String effectiveAccountId
    ) {
        try{
            // Lookup the webstore ID associated with the community
            String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
            List<Wishlist> wishloginList = [SELECT Id ,Name
                                      FROM Wishlist 
                                      WHERE CreatedById = :UserInfo.getUserId()
                                      Order by Name Desc
                                      LIMIT 1
                                           ];
            Id accountIdLogin = [SELECT Id,AccountId FROM User WHERE Id = :UserInfo.getUserId()][0].AccountId;
            system.debug('accountIdLogin'+accountIdLogin);
            
          if(wishloginList.isEmpty())
          {
              WishList w = new Wishlist();
              w.Name = 'My List';
              w.AccountId =accountIdLogin;
              w.WebStoreId = webstoreId;
              insert w;
              wishloginList.add(w);
              System.debug('Wish list created');
          }
            
            // Store the product in a WishlistItemInput to pass to the Wishlist
            ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
            wishlistItemInput.productId = productId;
            
            //Create a wishlistInput to be created
            ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
            // wishlistInput. = wishlistId;
            wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
                wishlistItemInput
                    };
                        
                        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
                        return ConnectApi.CommerceWishlist.addItemToWishlist(
                            webstoreId,
                            accountIdLogin,
                            wishloginList[0].id,
                            wishlistItemInput
                        );
        }catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(
        String communityId,
        String productId,
        String effectiveAccountId
    ) {
        try{
            // Lookup the webstore ID associated with the community
            String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
            
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
            return ConnectApi.CommerceStorePricing.getProductPrice(
                webstoreId,
                productId,
                effectiveAccountId
            );
        }catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    }
    
}
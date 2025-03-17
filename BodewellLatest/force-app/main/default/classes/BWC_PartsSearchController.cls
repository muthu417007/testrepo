/** --------------------------------------------------
* Description BWC_PartsSearchController
*            Search the parts wrt to search key entered by user
*            and return the matching results
* Date Aug 2023
*---------------------------------------------------*/
public without sharing class BWC_PartsSearchController {
    public static final String MIN_SEARCH_LEGTH_KEY = 'MinSearchKeyLength';
    public static final Integer DEFAULT_SEARCH_KEY_LENGTH = 3;
    public static final String GUEST_BUYER_GROUP_KEY = 'GuestPriceBooks';
    public static final String NON_MEMBER_BUYER_GROUP_KEY = 'Non-MemberPriceBooks';
    public static final String MEMBER_BUYER_GROUP_KEY = 'MemberPriceBooks';
    public static final String MEMBER_PRICEBOOK = 'Member_Parts_Price_Book';
    public static final String NON_MEMBER_PRICEBOOK = 'PartsBasePriceBook';
    public static final String PRODUCT_STATUS_FIELD = 'Active';
    
    /*
* @description The purpose of this method is to return length of search values.
* @param
* @return Integer	
*/
    @AuraEnabled
    public static Integer getMinKeyLengthForSearch(){
        List<Part_Finder__mdt> searchKeyLenList = [SELECT Value__c 
                                                   FROM Part_Finder__mdt 
                                                   WHERE Key__c =: MIN_SEARCH_LEGTH_KEY];
        return !searchKeyLenList.isEmpty() && String.isNotBlank(searchKeyLenList[0].Value__c) ? Integer.valueOf(searchKeyLenList[0].Value__c) : DEFAULT_SEARCH_KEY_LENGTH;
    }
    
    /*
* @description The purpose of this method is to get details of the product which is being searched.
* @param key - It contains the value that need to be searched into the product
* @return BWC_PartsSearchResultsWrapper	
*/
    @AuraEnabled
    public static BWC_PartsSearchResultsWrapper getProductBySearchKey(String key){
        List<Product2> products = new List<Product2>();
        BWC_PartsSearchResultsWrapper wrapperToReturn = new BWC_PartsSearchResultsWrapper();
        if(String.isNotBlank(key)){
            key += '%';
            products = [SELECT Id,
                        Name,
                        BWC_Product_Marketing_Description__c,
                        BWC_MFG_SKU__c,
                        StockKeepingUnit,
                        BWC_Main_Image__c,
                        BWC_Exploded_Diagram_Available__c
                        FROM Product2 
                        WHERE BWC_MFG_SKU__c != null 
                        AND Status__c = :PRODUCT_STATUS_FIELD
                        AND StockKeepingUnit 
                        LIKE :key];
            
            wrapperToReturn.showPDP = false;
            
            if(products.isEmpty()){
                products = [SELECT Name,
                            BWC_Product_Marketing_Description__c,
                            BWC_MFG_SKU__c,
                            StockKeepingUnit,
                            BWC_Main_Image__c,
                            BWC_Exploded_Diagram_Available__c
                            FROM Product2 
                            WHERE BWC_MFG_SKU__c != null 
                            AND Status__c = :PRODUCT_STATUS_FIELD
                            AND BWC_MFG_SKU__c 
                            LIKE :key];
                
                wrapperToReturn.showPDP = true;
            }
            wrapperToReturn.products = products;
        }
        return wrapperToReturn;
    }
    
    /*
* @description The purpose of this method is to get details for the parts diagram which contains related SKUs
* @param productId - It contains the id of the product
* @return List<Product2>	
*/
    @AuraEnabled
    public static List<Product2> getProductForExplodedDiagram(String productId){
        List<Product2> productsToReturn = new List<Product2>();
        if(String.isNotBlank(productId)){
            productsToReturn = [SELECT Id,
                                BWC_Product_Marketing_Description__c,
                                Name,
                                StockKeepingUnit,
                                BWC_MFG_SKU__c,
                                BWC_Main_Image__c,
                                BWC_Exploded_Diagram_Parts__c,
                                BWC_Exploded_Diagram_Images__c,
                                BWC_Exploded_Diagram_Available__c,
                                BWC_CAD__c,
                                BWC_Documents__c
                                FROM Product2
                                WHERE Id =: productId
                                AND Status__c = :PRODUCT_STATUS_FIELD];
        }
        return productsToReturn;
    }
    
    /*
* @description The purpose of this method is to get details for the parts diagram which contains related SKUs using productids.
* @param productIds - It contains the id of the products
* @return List<Product2>	
*/
    @AuraEnabled
    public static List<Product2> getProductForExplodedDiagramViaIds(List<String> productIds){
        List<Product2> productsToReturn = new List<Product2>();
        if(!productIds.isEmpty()){
            productsToReturn = [SELECT Id,
                                Name,
                                BWC_MFG_SKU__c,
                                StockKeepingUnit,
                                BWC_Main_Image__c,
                                BWC_Superseded_SKU__c,
                                BWC_Exploded_Diagram_Parts__c,
                                BWC_Exploded_Diagram_Images__c,
                                BWC_Exploded_Diagram_Available__c,
                                BWC_Product_Marketing_Description__c
                                FROM Product2
                                WHERE StockKeepingUnit IN :productIds
                                AND Status__c = :PRODUCT_STATUS_FIELD];
        }
        return productsToReturn;
    }
    
    /*
* @description The purpose of this method is to get the price of product based on current buyer group.
* @param productIds - It contains the id of the products.
* @param isGuestUser - It contains the boolean value to check if the user is guest or not.
* @param showMemberPriceForNonMember - It contains the boolean value to check for specific sku if available in cart.
* @return ProductsAndPricing	
*/    
    @AuraEnabled
    public static ProductsAndPricing getPriceForProducts(List<String> productIds, Boolean isGuestUser, Boolean showMemberPriceForNonMember){
        try{
            ProductsAndPricing productsAndPricing = new ProductsAndPricing();
            Map<String, String> priceBookNameMap = new Map<String, String>();
            for (BWC_Price_Book_Configuration__mdt config : [SELECT DeveloperName, 
                                                             PriceBookName__c 
                                                             FROM BWC_Price_Book_Configuration__mdt]) {
                                                                 priceBookNameMap.put(config.DeveloperName, config.PriceBookName__c);
                                                             }
            
            List<PricebookEntry> nonMemberpbEntry = [SELECT Id,
                                                     UnitPrice,
                                                     Product2Id
                                                     FROM PricebookEntry
                                                     WHERE Pricebook2.Name = :priceBookNameMap.get(NON_MEMBER_PRICEBOOK)
                                                     AND Product2Id IN :productIds];
            
            List<PricebookEntry> memberpbEntry = [SELECT Id,
                                                  UnitPrice,
                                                  Product2Id 
                                                  FROM PricebookEntry
                                                  WHERE Pricebook2.Name = :priceBookNameMap.get(MEMBER_PRICEBOOK)
                                                  AND Product2Id IN :productIds];
            
            if(isGuestUser && !productIds?.isEmpty()){
                productsAndPricing.isGuestPricing = true;
                productsAndPricing.guestPrice = nonMemberpbEntry;
            } else{            
                List<BuyerGroupMember> buyerMember = [SELECT Id,
                                                      BuyerGroup.Name
                                                      FROM BuyerGroupMember
                                                      WHERE BuyerId =:[SELECT AccountId
                                                                       FROM User
                                                                       WHERE Id =: UserInfo.getUserId()][0].AccountId
                                                     ];
                
                productsAndPricing.memberPrice = memberpbEntry;
                productsAndPricing.nonMemberPrice = nonMemberpbEntry;
                
                if(((buyerMember[0].BuyerGroup.Name).equals(Label.BWC_BuyerGroup) && !showMemberPriceForNonMember) || showMemberPriceForNonMember){
                    productsAndPricing.membershipInfo = 'Member';
                }
                else{
                    productsAndPricing.membershipInfo = 'Non-Member';
                }
            }
            return productsAndPricing;
        }catch(Exception e){
            System.debug('BWC_PartsSearchController.getPriceForProducts  : Exception Occured at Line : '+ e.getLineNumber()+' Message : '+e.getMessage());
            return null;
        }
    }
    
    /*
* @description The purpose of this method is to get the product details which is superseded using skus.
* @param stockKeepingUnit - It contains the sku of the product.
* @return List<Product2>	
*/       
    @AuraEnabled
    public static List<Product2> getSupersededPartBySku(String stockKeepingUnit){
        List<Product2> supersededPart = new List<Product2>();
        if(String.isNotBlank(stockKeepingUnit)){
            supersededPart = [SELECT Id,
                              Name
                              FROM Product2
                              WHERE StockKeepingUnit =: stockKeepingUnit];
        }
        return supersededPart;
    }
    
    /*
* @description The purpose of this method is to return the cartItems for the current cart.
* @param communityId - It contains the id of the community.
* @param effectiveAccountId - It contains accountId.
* @param pageParam - It contains page param used in connect api.
* @return ConnectApi.CartItemCollection	
*/        
    @AuraEnabled
    public static ConnectApi.CartItemCollection getCartItems(String communityId, String effectiveAccountId, String pageParam){
        try{
            String activeCartOrId = 'current';
            if(!Test.isRunningTest()){
                String webstoreId = BWC_utils.resolveCommunityIdToWebstoreId(communityId);
                
                if(String.isNotBlank(webstoreId)){
                    return ConnectApi.CommerceCart.getCartItems(
                        webstoreId,
                        effectiveAccountId,
                        activeCartOrId,
                        pageParam
                    );
                }
            }
            return null;
        }catch(Exception e){
            System.debug('BWC_PartsSearchController.getCartItems  : Exception Occured at Line : '+ e.getLineNumber()+' Message : '+e.getMessage());
            return null;
        }
    }
    
    /*
* @description The purpose of this method is to get the current network id.
* @return String
*/    
    @AuraEnabled
    public static String getNetworkId(){
        return Test.isRunningTest() ? '123' : Network.getNetworkId();
    }
    
    /*
* @description The purpose of this method is to get the related product items by product id and sales relationship type.
* @param prd - It contains ids of the products
* @param salesRelationshipType - It contains the value of Sales_Relationship_Type__c value in product.
* @return List<Related_Items__c>
*/
    @AuraEnabled
    public static List<Related_Items__c> getRelatedItemsByProduct(List<Product2> prd, String salesRelationshipType) {  
        try{
            return [ SELECT Product__c,
                    Related_Product__r.Id,
                    Related_Product__r.StockKeepingUnit,
                    Related_Product__r.Description
                    FROM Related_Items__c
                    WHERE Product__c IN :prd
                    AND Sales_Relationship_Type__c = :salesRelationshipType
                    ORDER BY Start_Date__c DESC NULLS LAST];
        }catch(Exception e){
            System.debug('BWC_PartsSearchController.getRelatedItemsByProduct  : Exception Occured at Line : '+ e.getLineNumber()+' Message : '+e.getMessage());
            return null;
        }
    }
    /*
* @description The purpose of this method is to get the labels for picklist values in search bar.
* @param objectApi - It contains name of the object.
* @param refernceFieldOnObject - It contains the field name of the object
* @return Map<String, String>
*/    
    @AuraEnabled
    public static Map<String, String> getPicklistLabelValue(String objectApi, String refernceFieldOnObject){
        Map<String, String> picklistApiNameLabelMap = new Map<String, String>();
        try {
            Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get(objectApi).getDescribe();
            Map<String, Schema.SObjectField> field_map = sobjectDescribe.fields.getMap();
            for(Schema.PicklistEntry f : field_map.get(refernceFieldOnObject).getDescribe().getPickListValues()){
                picklistApiNameLabelMap.put(String.valueOf(f.getLabel()), String.valueOf(f.getValue()));
            }
        }catch(Exception e){
            System.debug('BWC_PartsSearchController.getPicklistLabelValue  : Exception Occured at Line : '+ e.getLineNumber()+' Message : '+e.getMessage());
            return null;
        }
        return picklistApiNameLabelMap;
    }
    
    /*
* @description The purpose of this method is to get the current status of the order.
* @param orderSummaryId - It contains id of the order summary.
* @return List<OrderSummary>
*/     
    @AuraEnabled
    public static List<OrderSummary> getOrderStatus(String orderSummaryId){
        String status;
        List<OrderSummary> orderSum;
        try {
            orderSum = [SELECT Id,
                        OriginalOrder.Status,
                        OriginalOrder.Order_number__c
                        FROM OrderSummary
                        WHERE Id =: orderSummaryId];
            status = orderSum[0].OriginalOrder.Status;
        }catch(Exception e){
            System.debug('BWC_PartsSearchController.getOrderStatus  : Exception Occured at Line : '+ e.getLineNumber()+' Message : '+e.getMessage());
        }
        return orderSum;
    }
    
    public class BWC_PartsSearchResultsWrapper{
        @AuraEnabled
        public List<Product2> products;
        @AuraEnabled
        public Boolean showPDP = false;
    }
    
    public class ProductMediaWrapper{
        @AuraEnabled
        public String productImageType;
        @AuraEnabled
        public String productImageUrl;
        @AuraEnabled
        public Product2 product;
    }
    
    public class ProductPricingWrapper{
        @AuraEnabled
        public Product2 product;
        @AuraEnabled
        public Decimal unitPrice;
    }
    
    public class ProductsAndPricing{
        @AuraEnabled
        public Boolean isGuestPricing;
        @AuraEnabled
        public String membershipInfo;
        @AuraEnabled
        public List<PricebookEntry> memberPrice;
        @AuraEnabled 
        public List<PricebookEntry> nonMemberPrice;
        @AuraEnabled
        public List<PricebookEntry> guestPrice;
    }
}
//Deployment Fix
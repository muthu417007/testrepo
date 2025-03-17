public without sharing class BWC_OrderOnBehalfOfController {
  
    @AuraEnabled
    public static List<WebStore> getAllStores(){
        List<WebStore> stores = new List<WebStore>();
        try {
            stores = [SELECT Id, Name 
                      FROM WebStore 
                      LIMIT 50000];
        } catch(Exception e) {
            System.debug('BWC_OrderOnBehalfOfController.getAllStores > '+e.getMessage());
        }
        return stores;
    }

    @AuraEnabled
    public static List<Account> getAllUsers(){
        List<Account> userAccountList = new List<Account>();
        try {
            userAccountList = [SELECT Id, Name 
                        FROM Account 
                        LIMIT 50000];
        } catch(Exception e) {
            System.debug('BWC_OrderOnBehalfOfController.getAllUsers > '+e.getMessage());
        }
        return userAccountList;
    }

    @AuraEnabled
    public static List<ProductPricingWrapper> getProductBySearchKey(String accountId, String productSku){
        List<ProductPricingWrapper> productPricing = new List<ProductPricingWrapper>();
        try {
            productSku += '%';
            List<CommerceEntitlementBuyerGroup> buyerGpEntitlement = [SELECT Id, PolicyId, BuyerGroupId
                                                                      FROM CommerceEntitlementBuyerGroup
                                                                      WHERE BuyerGroupId IN (SELECT BuyerGroupId 
                                                                        FROM BuyerGroupMember 
                                                                        WHERE BuyerId =: accountId)
                                                                     ];
            if(buyerGpEntitlement != null && buyerGpEntitlement.size() > 0){
                List<Product2> productToReturn = [SELECT Id, Name, StockKeepingUnit 
                                          FROM Product2
                                          WHERE StockKeepingUnit LIKE :productSku];
                if(productToReturn != null && productToReturn.size() > 0){
                    List<CommerceEntitlementProduct> entitlementPdt = [SELECT Id, PolicyId, productId  
                                                                       FROM CommerceEntitlementProduct
                                                                       WHERE PolicyId =: buyerGpEntitlement[0].PolicyId
                                                                       AND ProductId IN : productToReturn];
                    productToReturn = entitlementPdt != null && entitlementPdt.size() > 0 ? productToReturn : new List<Product2>();
                }
                List<PricebookEntry> pbEntry = [SELECT Id, UnitPrice, Product2Id, Product2.Name, Product2.StockKeepingUnit
                                                FROM PricebookEntry 
                                                WHERE Product2Id IN : productToReturn 
                                                AND Pricebook2Id 
                                                IN (SELECT Pricebook2Id
                                                    FROM BuyerGroupPriceBook 
                                                    WHERE BuyerGroupId =: buyerGpEntitlement[0].BuyerGroupId)
                                                ORDER BY UnitPrice NULLS LAST
                                               ];
                for(PricebookEntry pbe : pbEntry){
                    ProductPricingWrapper pdtPricing = new ProductPricingWrapper();
                    pdtPricing.productId = pbe.Product2Id;
                    pdtPricing.productName = pbe.Product2.Name;
                    pdtPricing.productSku = pbe.Product2.StockKeepingUnit;
                    pdtPricing.unitPrice = pbe.UnitPrice != null ? pbe.UnitPrice : 0;
                    productPricing.add(pdtPricing);
                    if(pdtPricing.unitPrice > 0){
                        productPricing.add(1, pdtPricing);
                        break;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('BWC_OrderOnBehalfOfController.getProductBySearchKey > '+e.getMessage());
        }
        return productPricing;
    }

    @AuraEnabled
    public static ConnectApi.ProductPrice getPriceFromConnectApi(String accountId, String productSku, String storeId){
        ConnectApi.ProductPrice pdtPricing;
        try{
        List<Product2> productToReturn = [SELECT Id, Name, StockKeepingUnit 
                                          FROM Product2
                                          WHERE StockKeepingUnit LIKE :productSku];
        String pdtId = productToReturn[0].Id;
        // pdtPricing = ConnectApi.CommerceStorePricing.getProductPrice(
        //     storeId,
        //     pdtId,
        //     accountId
        // );
        String endPoint = 'https://geapp--bwcommoob.sandbox.my.salesforce.com/services/data/v58.0/commerce/webstores/{0}/products/{1}?effectiveAccountId={2}';
        endPoint = String.format(endPoint, new List<String>{storeId, pdtId, accountId});
        Http htp = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());
        //re.setContentType('application/json');
        HttpResponse res = htp.send(req);
        System.debug('Response Is > '+res?.getStatusCode()+ ' Res Body > '+res?.getBody()); 
        System.debug('Product Pricing from Connect Api is > '+pdtPricing);
        }catch(Exception e){
            System.debug('Exception In Connect API > '+e.getMessage());
        }
        return pdtPricing;
    }

    @AuraEnabled
    public static List<ContactPointAddress> getDefaultAddress(String accountId){
        List<ContactPointAddress> userDefaultAddress = new List<ContactPointAddress>();
        try{
            userDefaultAddress = [SELECT Id, Street, City, State, PostalCode, Country FROM ContactPointAddress WHERE AddressType = 'Shipping' AND ParentId =: accountId];
        }catch(Exception ex){
            System.debug('BWC_OrderOnBehalfOfController.getDefaultAddress > '+ex.getMessage());
        }
        return userDefaultAddress;
    }

    public class ProductPricingWrapper{
        @AuraEnabled
        public String productId;

        @AuraEnabled
        public String productName;

        @AuraEnabled
        public String productSku;

        @AuraEnabled
        public Decimal unitPrice;
    }
}
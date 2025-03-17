/**
 * @description Controller used to return variation information
 */
public without sharing class BWC_SwatchController {
    /**
     * @description Return a list of strings containing the color value, product Id and if its a default variant
     */
    @AuraEnabled(cacheable=true)
    public static List<ProductAttribute> getActiveColors(String variantParentId) {
        CX_Logger logger = new CX_Logger();
        try {
            return [
                SELECT Color__c, ProductId, Product.bwc_DefaultVariant__c, Product.StockKeepingUnit,
                Product.BWC_Product_Marketing_Description__c,Product.BWC_Is_Part__c,Product.BWC_ProductSpecAndDetails__c,
                Product.Is_Accessory__c,Product.bwc_SwatchConfig__c,Product.Is_Finished_Good__c,Product.BWC_Main_Image__c
                FROM ProductAttribute
                WHERE Product.IsActive = true
                AND VariantParentId = :variantParentId
            ];
        } catch (Exception e) {
            logger.logError(e, 'BWC_SwatchController', 'getActiveColors');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to get the prices for a list of custom hardware skus
     * @param {List<String>} buyerGroupNames - List of buyer group names (type String) to filter the clearance products.
     * @param {List<String>} customHardwareSkus - List of product IDs (type String) to check for clearance status.
     * @return {Map<String, Double>} - A map of sku to price. If no price is found, no mapping is returned.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Double> getCustomHardwarePrices(List<String> buyerGroupNames, List<String> customHardwareSkus) {
        CX_Logger logger = new CX_Logger();
        Map<String, Double> result = new Map<String, Double>();

        try {
            // Get ProductIds from SKUs
            Set<Id> productIds = new Set<Id>();
            for (Product2 product : [
                SELECT Id
                FROM Product2
                WHERE StockKeepingUnit IN :customHardwareSkus
                AND IsActive = true
            ]) {
                productIds.add(product.Id);
            }

            // Get BuyerGroup Ids from the BuyerGroup Names
            Set<Id> buyerGroupIds = new Set<Id>();
            for (BuyerGroup bg : [
                SELECT Id
                FROM BuyerGroup
                WHERE Name IN :buyerGroupNames
            ]) {
                buyerGroupIds.add(bg.Id);
            }

            // Query the BuyerGroupPricebook junction object to get associated Pricebook2 IDs
            Set<Id> pricebook2Ids = new Set<Id>();
            for (BuyerGroupPricebook bgpb : [
                SELECT Pricebook2Id
                FROM BuyerGroupPricebook
                WHERE BuyerGroupId IN :buyerGroupIds
                AND IsActive = true
            ]) {
                pricebook2Ids.add(bgpb.Pricebook2Id);
            }

            Map<String, Decimal> results = new Map<String, Decimal>();
            for (PricebookEntry entry : [
                SELECT Product2.StockKeepingUnit, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id IN :pricebook2Ids
                AND Product2Id IN :productIds
                AND IsActive = true
            ]) {
                results.put(entry.Product2.StockKeepingUnit, entry.UnitPrice);
            }

            return results;
        } catch (Exception e) {
            logger.logError(e, 'BWC_SwatchController', 'getCustomHardwarePrices');
            throw new AuraHandledException(e.getMessage());
        }
    }
}
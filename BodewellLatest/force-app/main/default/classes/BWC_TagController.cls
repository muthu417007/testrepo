public without sharing class BWC_TagController {
  /**
   * @description Method to get products on Sale and Clearance
   */
  @AuraEnabled(cacheable=true)
  public static Object getProductInformation(List<String> buyerGroupNames, List<String> productIds) {
     Map<String, List<String>> results = new Map<String, List<String>>();
     results.put('sale', getProductsOnSale(productIds));
     results.put('clearance', getProductsOnClearance(buyerGroupNames, productIds));
     return results;
  }

  /**
   * @description Method to get the products on sale.
   *
   * @param productIds List of product IDs (type String) to check for promotions.
   * @return List<String> A list containing the IDs of products that are on sale either by
   * product promotion or by category promotion.
   */
  public static List<String> getProductsOnSale(List<String> productIds) {
    Set<String> onSaleProductIds = new Set<String>();

    // Query promotions for products
    for (PromotionQualifier promotion : [
      SELECT QualifierId
      FROM PromotionQualifier
      WHERE QualifierType = 'Product'
      AND Promotion.IsActive = true
      AND QualifierId IN :productIds
    ]) {
      onSaleProductIds.add(promotion.QualifierId);
    }

    // Create a set to hold category IDs
    Set<Id> categoryIdsOnSale = new Set<Id>();

    // Query promotions for product categories
    for (PromotionQualifier promotion : [
      SELECT QualifierId
      FROM PromotionQualifier
      WHERE QualifierType = 'ProductCategory'
      AND Promotion.IsActive = true
    ]) {
      categoryIdsOnSale.add(promotion.QualifierId);
    }

    // Query junction records to get products for categories
    for (ProductCategoryProduct junctionRecord : [
      SELECT ProductId, ProductCategoryId
      FROM ProductCategoryProduct
      WHERE ProductId IN :productIds AND ProductCategoryId IN :categoryIdsOnSale
    ]) {
      onSaleProductIds.add(junctionRecord.ProductId);
    }

    // Return the list of product IDs that are on sale
    return new List<String>(onSaleProductIds);
  }

  /**
   * @description Method to get the products on clearance.
   *
   * @param buyerGroupNames List of buyer group names (type String) to filter the clearance products.
   * @param productIds List of product IDs (type String) to check for clearance status.
   * @return List<String> A list containing the IDs of products that are on clearance based on buyer groups and product IDs.
   */
  public static List<String> getProductsOnClearance(List<String> buyerGroupNames, List<String> productIds) {
      Set<String> clearanceProductIds = new Set<String>();

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
        ]) {
          pricebook2Ids.add(bgpb.Pricebook2Id);
      }
      // Query PricebookEntry object to get products with clearance field
      // Add the product IDs to the result set
      for (PricebookEntry entry : [
            SELECT Product2Id
            FROM PricebookEntry
            WHERE Pricebook2Id IN :pricebook2Ids
            AND Product2Id IN :productIds
            AND BWC_NET_NET_CLOSEOUT_IND__c = 'Y'
        ]) {
          clearanceProductIds.add(entry.Product2Id);
      }

      return new List<String>(clearanceProductIds);
  }
}
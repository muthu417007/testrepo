@isTest
private class BWC_TagControllerTest {
  @isTest
  static void testGetProductsOnSale() {
    // Create test Catalog record
    ProductCatalog testCatalog = new ProductCatalog(Name = 'Test Catalog');
    insert testCatalog;

    // Create test ProductCategory records
    ProductCategory testCategory = new ProductCategory(
      Name = 'Test Category',
      CatalogId = testCatalog.Id
    );
    insert testCategory;

    // Create test Product2 records
    List<Product2> testProducts = new List<Product2>();
    for (Integer i = 0; i < 5; i++) {
      testProducts.add(
        new Product2(
          Name = 'Test Product ' + i,
          Item_Number__c = 'Test_Product_Item_Number_' + i
        )
      );
    }
    insert testProducts;

    // Create ProductCategoryProduct junction records for last two products
    List<ProductCategoryProduct> junctionRecords = new List<ProductCategoryProduct>();
    for (Integer i = 3; i < 5; i++) {
      junctionRecords.add(
        new ProductCategoryProduct(
          ProductId = testProducts[i].Id,
          ProductCategoryId = testCategory.Id
        )
      );
    }
    insert junctionRecords;

    // Create test Promotion records
    Promotion testPromotion = new Promotion(Name = 'TestPromotion', IsActive = true);
    insert testPromotion;

    // Create promotions for first three products directly
    List<PromotionQualifier> productPromotions = new List<PromotionQualifier>();
    for (Integer i = 0; i < 3; i++) {
      productPromotions.add(
        new PromotionQualifier(
          QualifierId = testProducts[i].Id,
          QualifierType = 'Product',
          PromotionId = testPromotion.Id,
          MinimumQuantity = 1
        )
      );
    }
    insert productPromotions;

    // Add promotions for the category
    insert new PromotionQualifier(
      QualifierId = testCategory.Id,
      QualifierType = 'ProductCategory',
      PromotionId = testPromotion.Id,
      MinimumQuantity = 1
    );

    // Prepare the input list of product IDs
    List<String> productIds = new List<String>();
    for (Product2 p : testProducts) {
      productIds.add(p.Id);
    }

    // Call the method to test
    Test.startTest();
    List<String> onSaleProductIds = BWC_TagController.getProductsOnSale(
      productIds
    );
    Test.stopTest();

    // Verify the results (Expect 5 products on sale: 3 directly and 2 through the category)
    System.assertEquals(
      5,
      onSaleProductIds.size(),
      'Unexpected number of products on sale'
    );

    // Verify that the products on sale directly are included
    for (Integer i = 0; i < 3; i++) {
      System.assert(
        onSaleProductIds.contains(testProducts[i].Id),
        'Missing product on sale directly: ' + testProducts[i].Id
      );
    }

    // Verify that the products on sale through the category are included
    for (Integer i = 3; i < 5; i++) {
      System.assert(
        onSaleProductIds.contains(testProducts[i].Id),
        'Missing product on sale through category: ' + testProducts[i].Id
      );
    }
  }

  @isTest(SeeAllData=true)
  static void testGetProductsOnClearance() {
      // Create test Product2 records
      List<Product2> testProducts = new List<Product2>();
      for (Integer i = 0; i < 5; i++) {
        testProducts.add(
          new Product2(
            Name = 'Test Product ' + i,
            Item_Number__c = 'Test_Product_Item_Number_' + i
          )
        );
      }
      insert testProducts;

      // Get the ID of the standard price book . Since the IsStandard field is not writable,
      // we must query the existing standard price book ID rather than creating a new one.
      Id standardPricebookId = [SELECT Id
                                FROM Pricebook2
                                WHERE IsStandard = true
                                LIMIT 1].Id;
      // Create standard PricebookEntry records for the test products
      List<PricebookEntry> standardPrices = new List<PricebookEntry>();
      for (Product2 p : testProducts) {
          standardPrices.add(new PricebookEntry(
              Product2Id = p.Id,
              Pricebook2Id = standardPricebookId,
              UnitPrice = 100.00,
              IsActive = true
          ));
      }
      insert standardPrices;
      // Create test BuyerGroup
      BuyerGroup testBuyerGroup = new BuyerGroup(Name = 'Test Buyer Group');
      insert testBuyerGroup;
      // Create test Pricebook2
      Pricebook2 testPricebook = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
      insert testPricebook;
      // Link BuyerGroup to Pricebook2
      BuyerGroupPricebook bgpb = new BuyerGroupPricebook(BuyerGroupId = testBuyerGroup.Id, Pricebook2Id = testPricebook.Id);
      insert bgpb;
      // Create PricebookEntries with Clearance__c = true for last two products
      List<PricebookEntry> clearanceEntries = new List<PricebookEntry>();
      for (Integer i = 3; i < 5; i++) {
          clearanceEntries.add(new PricebookEntry(
              Product2Id = testProducts[i].Id,
              Pricebook2Id = testPricebook.Id,
              BWC_NET_NET_CLOSEOUT_IND__c = 'Y',
              UnitPrice = 100,
              IsActive = true
          ));
      }
      insert clearanceEntries;
      // Prepare the input list of product IDs and buyer group names
      List<String> productIds = new List<String>();
      for (Product2 p : testProducts) {
          productIds.add(p.Id);
      }
      List<String> buyerGroupNames = new List<String>{'Test Buyer Group'};
      // Call the method to test
      Test.startTest();
      List<String> onClearanceProductIds = BWC_TagController.getProductsOnClearance(buyerGroupNames, productIds);
      Test.stopTest();
      // Verify the results (Expect 2 products on clearance)
      System.assertEquals(2, onClearanceProductIds.size(), 'Unexpected number of products on clearance');
      // Verify that the products on clearance are included
      for (Integer i = 3; i < 5; i++) {
          System.assert(onClearanceProductIds.contains(testProducts[i].Id), 'Missing product on clearance: ' + testProducts[i].Id);
      }
  }
}
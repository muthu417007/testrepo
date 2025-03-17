@IsTest
public with sharing class BWC_SwatchControllerTest {

    /**
     * @description Test with invalid arguments
     * 1) Empty Variation Parent Id
     * 2) Null Variation Parent Id
     */
    @IsTest
    public static void getActiveColors_BadArgs_Test() {
        String msg = 'Expected empty Map';
        String variationParentId = '';
        System.assertEquals(BWC_SwatchController.getActiveColors(variationParentId).size(), 0, msg);
        variationParentId = null;
        System.assertEquals(BWC_SwatchController.getActiveColors(variationParentId).size(), 0, msg);
    }

    /**
     * @description Test successfull call with Parent/Child products with a default Variation product
     */
    @IsTest
    public static void getActiveColors_Success_With_DefaultVariant_Test() {
        /**
         * Use System.runAs() to avoid error due to setup objects and regular objects
         * executing in the same context
         * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
         */
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Product2 pParent = new Product2(Name = 'Parent Product', Type = 'Base', IsActive = true, Item_Number__c = 'itmnum_parent123');
            insert pParent;
            Product2 pChild = new Product2(Name = 'Child Product', IsActive = true, Item_Number__c = 'itmnum_child123', bwc_DefaultVariant__c = true, bwc_BypassValidation__c = true);
            insert pChild;

            // Assumes the parent and child are related via a ProductAttribute field named 'Color__c'
            BWC_ApexUtils.createProductVariationRelationship(pParent.Id, pChild.Id, 'Color__c');

            List<ProductAttribute> results = BWC_SwatchController.getActiveColors(pParent.Id);
            System.assert(results.size() > 0, 'Expected results.size() > 0');

            //Confirm that the results has a default variant
            System.assert(results[0].Product.bwc_DefaultVariant__c, 'Expected default variant not found');
         }
    }

    /**
     * @description Test successfull call with Parent/Child products without a default Variation product
     */
    @IsTest
    public static void getActiveColors_Success_Without_DefaultVariant_Test() {
        /**
         * Use System.runAs() to avoid error due to setup objects and regular objects
         * executing in the same context
         * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
         */
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Product2 pParent = new Product2(Name = 'Parent Product', Type = 'Base', IsActive = true, Item_Number__c = 'itmnum_parent123');
            insert pParent;
            Product2 pChild = new Product2(Name = 'Child Product', IsActive = true, Item_Number__c = 'itmnum_child123');
            insert pChild;

            // Assumes the parent and child are related via a ProductAttribute field named 'Color__c'
            BWC_ApexUtils.createProductVariationRelationship(pParent.Id, pChild.Id, 'Color__c');

            List<ProductAttribute> results = BWC_SwatchController.getActiveColors(pParent.Id);
            System.assert(results.size() > 0, 'Expected results.size() > 0');

            //Confirm that the results DOT NOT HAVE a default variant
            System.assert(!results[0].Product.bwc_DefaultVariant__c, 'Expected no default variant to be found');
         }
    }

    @isTest(SeeAllData=true)
    public static void getCustomHardwarePrices_success() {
        setupTestData();

        Test.startTest();
        List<String> buyerGroupNames = new List<String>{'Testing Guest'};
        List<String> customHardwareSkus = new List<String>{'SKU_0', 'SKU_1'};
        Map<String, Double> results = BWC_SwatchController.getCustomHardwarePrices(buyerGroupNames, customHardwareSkus);
        System.assertEquals(2, results.size(), 'Expected results.size() == 2');
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void getCustomHardwarePrices_failure_invalid_skus() {
        setupTestData();

        Test.startTest();
        List<String> customHardwareSkus = new List<String>{'NOT VALID SKU'};
        List<String> buyerGroupNames = new List<String>{'Testing Guest'};
        Map<String, Double> results = BWC_SwatchController.getCustomHardwarePrices(buyerGroupNames, customHardwareSkus);
        System.assertEquals(0, results.size(), 'Expected results.size() == 0');
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void getCustomHardwarePrices_failure_invalid_buyer_group() {
        setupTestData();

        Test.startTest();
        List<String> customHardwareSkus = new List<String>{'SKU_0', 'SKU_1'};
        List<String> buyerGroupNames = new List<String>{'Does not Exist'};
        Map<String, Double> results = BWC_SwatchController.getCustomHardwarePrices(buyerGroupNames, customHardwareSkus);
        System.assertEquals(0, results.size(), 'Expected results.size() == 0');
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void getCustomHardwarePrices_failure_one_sku_invalid() {
        setupTestData();

        Test.startTest();
        List<String> customHardwareSkus = new List<String>{'SKU_0', 'NOT VALID SKU'};
        List<String> buyerGroupNames = new List<String>{'Testing Guest'};
        Map<String, Double> results = BWC_SwatchController.getCustomHardwarePrices(buyerGroupNames, customHardwareSkus);
        System.assertEquals(1, results.size(), 'Expected results.size() == 1');
        Test.stopTest();
    }

    public static void setupTestData() {
        List<Product2> products = new List<Product2>();

        for (Integer i = 0; i < 2; i++) {
             products.add(new Product2(
                Name = 'Test Product ' + i,
                Item_Number__c = 'Test_Product_Item_Number_' + i,
                IsActive = true,
                StockKeepingUnit = 'SKU_'+ i));
        }

        insert products;

        BuyerGroup buyerGroup = new BuyerGroup(Name = 'Testing Guest');

        insert buyerGroup;

        Id standardPricebookId = [SELECT Id
                                FROM Pricebook2
                                WHERE IsStandard = true
                                LIMIT 1].Id;

        // Create standard PricebookEntry records for the test products
        List<PricebookEntry> standardPrices = new List<PricebookEntry>();
        for (Product2 p : products) {
            standardPrices.add(new PricebookEntry(
                Product2Id = p.Id,
                Pricebook2Id = standardPricebookId,
                UnitPrice = 100.00,
                IsActive = true
            ));
        }
        insert standardPrices;

        Pricebook2 priceBook = new Pricebook2(Name = 'Custom Price Book', IsActive = true);

        insert priceBook;

        BuyerGroupPricebook bgpb = new BuyerGroupPricebook(
            BuyerGroupId = buyerGroup.Id,
            Pricebook2Id = priceBook.Id,
            IsActive = true
        );

        insert bgpb;

        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        for (Integer i = 0; i < 2; i++) {
            priceBookEntryList.add(new PricebookEntry(
                Product2Id = products[i].Id,
                UnitPrice = 100,
                IsActive = true,
                UseStandardPrice = false,
                Pricebook2Id = priceBook.Id
            ));
        }

        insert priceBookEntryList;
    }
}
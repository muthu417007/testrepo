@IsTest
private class BWC_ProductDataLoadBatchTest {
    @testSetup
    static void setupTestData() {
        
        // Create test records for the batch
        List<Product2> parentProducts = new List<Product2>{
            new Product2(Name = 'Product 1', Item_Number__c='GEA_0001', Type = 'Base', stockkeepingunit = 'GEA_0001', BWC_Product_Category__c='Bodewell>Appliances>Cooking>Ranges>Electric Ranges',BWC_Parent_Model__c  = '', BWC_MaxOrderQuantity__c=2),
            new Product2(Name = 'Product 2', Item_Number__c='GEA_0002',Type = 'Base', stockkeepingunit = 'GEA_0002', BWC_Product_Category__c='Bodewell>Appliances>Cooking>Ranges>Electric Ranges',BWC_Parent_Model__c  = '',BWC_MaxOrderQuantity__c=2)
                     };
                         
       system.debug('parentProducts===>>>>'+parentProducts);                  
                         
        insert parentProducts;
        
         List<Product2> childProducts = new List<Product2>{
            new Product2(Name = 'Product 1', Item_Number__c='sku-1', BWC_Appearance__c='Black on Black', stockkeepingunit = 'sku-1', BWC_Parent_Model__c  = 'GEA_0001', BWC_Product_Category__c='Bodewell>Appliances>Cooking>Ranges>Electric Ranges',BWC_MaxOrderQuantity__c=2),
            new Product2(Name = 'Product 2', Item_Number__c='sku-2', BWC_Appearance__c='white on white', stockkeepingunit = 'sku-2', BWC_Parent_Model__c  = 'GEA_0001', BWC_Product_Category__c='Bodewell>Appliances>Cooking>Ranges>Electric Ranges',BWC_MaxOrderQuantity__c=2),
            new Product2(Name = 'Product 3', Item_Number__c='sku-3', BWC_Appearance__c='Stainless Stell', stockkeepingunit = 'sku-3',BWC_Parent_Model__c  = 'GEA_0002', BWC_Product_Category__c='Bodewell>Appliances>Cooking>Ranges>Electric Ranges',BWC_MaxOrderQuantity__c=1 ),
            new Product2(Name = 'Product 4', Item_Number__c='sku-4', BWC_Appearance__c='Bisk on Bisk', stockkeepingunit = 'sku-4', BWC_Parent_Model__c  = 'GEA_0002', BWC_Product_Category__c='Bodewell>Appliances>Cooking>Ranges>Electric Ranges',BWC_MaxOrderQuantity__c=1)
                };
                    
        system.debug('childProducts===>>>>'+childProducts);                              
        insert childProducts;

       ProductCatalog catalogs  = new ProductCatalog(Name = 'Bodewell Catalog');                       
        insert catalogs;
        
        Id catId = [SELECT ID FROM ProductCatalog WHERE Name = 'Bodewell Catalog' LIMIT 1].Id;
        
         List<CommerceEntitlementPolicy> commPolicies = new List<CommerceEntitlementPolicy>{
            new CommerceEntitlementPolicy(Name = 'Guest', isactive=true),
                 new CommerceEntitlementPolicy(Name = 'Member',isactive=true)
                };
                    
        system.debug('commPolicies===>>>>'+commPolicies);                              
        insert commPolicies;

         List<ProductCategory> productCategories = new List<ProductCategory>{
         new ProductCategory(Name = 'Electric Ranges', CatalogId=catId),
                 new ProductCategory(Name = 'Refrigirations',CatalogId=catId)
                };
                    
        system.debug('productCategories===>>>>'+productCategories);                              
        insert productCategories;
        
    }

    @IsTest
    static void testBatchExecution() {

        String Query1 = 'SELECT Id FROM Product2 WHERE TYPE=\'Base\'';
		BWC_ProducDataLoadBatch batch1 = new BWC_ProducDataLoadBatch(Query1,'ProductAttributeSetProduct'); 
        database.executebatch(batch1, 200);

		String query2 = 'SELECT ID, BWC_APPEARANCE__C, BWC_BASE_MODEL__C, STOCKKEEPINGUNIT, BWC_PARENT_MODEL__C FROM PRODUCT2 WHERE BWC_BASE_MODEL__C <> \'\' AND BWC_PARENT_MODEL__C <> \'\' ' ;
		BWC_ProducDataLoadBatch batch2 = new BWC_ProducDataLoadBatch(Query2,'ProductAttribute'); 
        database.executebatch(batch2, 200);


		String Query3 = 'SELECT Id, BWC_Product_Category__c FROM Product2 WHERE LastModifiedDate = TODAY'; 
		BWC_ProducDataLoadBatch batch3 = new BWC_ProducDataLoadBatch(Query3,'ProductCategoryProduct'); 
        database.executebatch(batch3, 200);

		String Query4 = 'SELECT Id FROM Product2' ; 
		BWC_ProducDataLoadBatch batch4 = new BWC_ProducDataLoadBatch(Query4,'CommerceEntitlementProduct'); 
        database.executebatch(batch4, 200);
        
        // Start the batch execution
        Test.StartTest();
        Database.executebatch(batch1);
        Database.executebatch(batch2);
        Database.executebatch(batch3);
        Database.executebatch(batch4);
        Test.StopTest();
    }
    
    static testmethod void execute_ShouldScheduleJob2() {
        //GIVEN
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2031';

        //WHEN
        String jobId = System.schedule('BWC_ProductDataLoad_CAT_EP_Sheduler', CRON_EXP,  new BWC_ProductDataLoad_CAT_EP_Sheduler());

        //THEN
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2031-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}
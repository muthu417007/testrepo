@IsTest
public class BWC_MemberPriceBookUpdateTest {

    @isTest
    static void testBatchExecution() {
        // Step 1: Create Product records
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 10; i++) {
            Product2 product = new Product2(
                Name = 'Test Product' + i,
                Item_Number__c = 'BWC_GEA_000' + i,
                StockKeepingUnit = 'BWCGEA000' + i,
                Is_Finished_Good__c = 'Yes',
                Is_Accessory__c = 'Yes',
                BWC_Is_Part__c = false,
                Status__c= 'Active'
            );
            products.add(product);
        }

        for (Integer i = 10; i < 15; i++) {
            Product2 product = new Product2(
                Name = 'Test Product' + i,
                Item_Number__c = 'BWC_GEA_000' + i,
                StockKeepingUnit = 'BWCGEA000' + i,
                Is_Finished_Good__c = 'Yes',
                Is_Accessory__c = 'No',
                BWC_Is_Part__c = false,
                Status__c= 'Active'
            );
            products.add(product);
        }

        for (Integer i = 15; i < 20; i++) {
            Product2 product = new Product2(
                Name = 'Test Product' + i,
                Item_Number__c = 'BWC_GEA_000' + i,
                StockKeepingUnit = 'BWCGEA000' + i,
                Is_Finished_Good__c = 'No',
                Is_Accessory__c = 'No',
                BWC_Is_Part__c = true,
                Status__c= 'Active'
            );
            products.add(product);
        }

        insert products;
        System.debug('products' + products);

        List<PricebookEntry> standardPriceEntries = new List<PricebookEntry>();
        for (Product2 pro : products) {
            standardPriceEntries.add(new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = pro.Id,
                UnitPrice = 10.00,
                IsActive = true
            ));
        }
        insert standardPriceEntries;
        System.debug('standardPriceEntries' + standardPriceEntries);

         //List<BWC_Price_Book_Configuration__mdt> configs = [SELECT DeveloperName, PriceBookName__c, Discount_Percentage__c FROM BWC_Price_Book_Configuration__mdt];
         BWC_Price_Book_Configuration__mdt memberPriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'Member Price Book'];
         String memberPriceBook = memberPriceBookRecord.PriceBookName__c;

         BWC_Price_Book_Configuration__mdt basePriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'BasePriceBook'];
         String basePriceBook = basePriceBookRecord.PriceBookName__c;

         BWC_Price_Book_Configuration__mdt memberPartsPriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'Member Parts Price Book'];
         String memberPartsPriceBook = memberPartsPriceBookRecord.PriceBookName__c;

         BWC_Price_Book_Configuration__mdt basePartsPriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'PartsBasePriceBook'];
         String basePartsPriceBook = basePartsPriceBookRecord.PriceBookName__c;

         BWC_Price_Book_Configuration__mdt memberSubscriptionCarePlanPriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'MemberSubscriptionsCarePlans'];
         String memberSubscriptionCarePlanPriceBook = memberSubscriptionCarePlanPriceBookRecord.PriceBookName__c;

         BWC_Price_Book_Configuration__mdt baseSubscriptionPriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'SubscriptionsBasePriceBook'];
         String baseSubscriptionPriceBook = baseSubscriptionPriceBookRecord.PriceBookName__c;

         BWC_Price_Book_Configuration__mdt baseCarePlanPriceBookRecord = [SELECT PriceBookName__c FROM BWC_Price_Book_Configuration__mdt WHERE MasterLabel = 'CarePlanBasePriceBook'];
         String baseCarePlanPriceBook = baseCarePlanPriceBookRecord.PriceBookName__c;

        // Step 2: Create Member & Base test pricebook for Non Parts
        Pricebook2 testBasePricebook = new Pricebook2(
            Name = basePriceBook,
            IsActive = true
        );
        insert testBasePricebook;
        System.debug('testBasePricebook' + testBasePricebook);

       
        Pricebook2 testMemPricebook = new Pricebook2(
            Name = memberPriceBook,
            IsActive = true
        );
        insert testMemPricebook;
        System.debug('testMemPricebook' + testMemPricebook);

         // Step 3: Create Member & Base test pricebook for Parts
        Pricebook2 testMemberPartsPriceBook = new Pricebook2(
            Name = memberPartsPriceBook,
            IsActive = true
        );
        insert testMemberPartsPriceBook;
        System.debug('testMemberPartsPriceBook' + testMemberPartsPriceBook);

        Pricebook2 testBasePartsPriceBook = new Pricebook2(
            Name = basePartsPriceBook,
            IsActive = true
        );
        insert testBasePartsPriceBook;
        System.debug('testBasePartsPriceBook' + testBasePartsPriceBook);

         // Step 3: Create Member & Base test pricebook for Suscription & CarePlan
         Pricebook2 testMemberSuscriptionAndCarePlanPriceBook = new Pricebook2(
            Name = memberSubscriptionCarePlanPriceBook,
            IsActive = true
        );
        insert testMemberSuscriptionAndCarePlanPriceBook;
        System.debug('testMemberSuscriptionAndCarePlanPriceBook' + testMemberSuscriptionAndCarePlanPriceBook);

        Pricebook2 testBaseSuscriptionPriceBook = new Pricebook2(
            Name = baseSubscriptionPriceBook,
            IsActive = true
        );
        insert testBaseSuscriptionPriceBook;
        System.debug('testBaseSuscriptionPriceBook' + testBaseSuscriptionPriceBook);

        Pricebook2 testBaseCarePlanPriceBook = new Pricebook2(
            Name = baseCarePlanPriceBook,
            IsActive = true
        );
        insert testBaseCarePlanPriceBook;
        System.debug('testBaseCarePlanPriceBook' + testBaseCarePlanPriceBook);
        

        Decimal fgDiscount = 0.15;
        Decimal accessoryDiscount = 0.05;
        Decimal partsDiscount = 0.10;
        Decimal protectionPlanDiscount = 0.10;

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 pro : products) {
            pricebookEntries.add(new PricebookEntry(
                Pricebook2Id = testBasePricebook.Id,
                Product2Id = pro.Id,
                UnitPrice = 100.00,
                BWC_BasePrice__c=100.00,
                IsActive = true
            ));
        }
        insert pricebookEntries;
        System.debug('pricebookEntries' + pricebookEntries);

        List<PricebookEntry> memberPricebookEntries = new List<PricebookEntry>(); 
        Integer i=0;     
        for (Product2 pro : products) {   
            if(i<10){
            memberPricebookEntries.add(new PricebookEntry(
                Pricebook2Id = testMemPricebook.Id,
                Product2Id = pro.Id,
                UnitPrice = 100.00,
                IsActive = true                
            ));
            i=i+1;
            }
        }
        insert memberPricebookEntries;
        System.debug('memberPricebookEntries' + memberPricebookEntries);

        List<PricebookEntry> partsPricebookEntries = new List<PricebookEntry>();
        for (Product2 pro : products) {
            partsPricebookEntries.add(new PricebookEntry(
                Pricebook2Id = testBasePartsPriceBook.Id,
                Product2Id = pro.Id,
                UnitPrice = 100.00,
                BWC_BasePrice__c=100.00,
                IsActive = true
            ));
        }
        insert partsPricebookEntries;
        System.debug('partsPricebookEntries' + partsPricebookEntries);

        List<PricebookEntry> memberPartsPricebookEntries = new List<PricebookEntry>(); 
        Integer j=0;     
        for (Product2 pro : products) {   
            if(j<10){
                memberPartsPricebookEntries.add(new PricebookEntry(
                Pricebook2Id = testMemberPartsPriceBook.Id,
                Product2Id = pro.Id,
                UnitPrice = 100.00,
                IsActive = true                
            ));
            j=j+1;
            }
        }
        insert memberPartsPricebookEntries;
        System.debug('memberPartsPricebookEntries' + memberPartsPricebookEntries);


        List<PricebookEntry> subscriptionPricebookEntries = new List<PricebookEntry>();
        for (Product2 pro : products) {
            subscriptionPricebookEntries.add(new PricebookEntry(
                Pricebook2Id = testBaseSuscriptionPriceBook.Id,
                Product2Id = pro.Id,
                UnitPrice = 100.00,
                BWC_BasePrice__c=100.00,
                IsActive = true
            ));
        }
        insert subscriptionPricebookEntries;
        System.debug('subscriptionPricebookEntries' + subscriptionPricebookEntries);

        List<PricebookEntry> carePlanPricebookEntries = new List<PricebookEntry>();
        for (Product2 pro : products) {
            carePlanPricebookEntries.add(new PricebookEntry(
                Pricebook2Id = testBaseCarePlanPriceBook.Id,
                Product2Id = pro.Id,
                UnitPrice = 100.00,
                BWC_BasePrice__c=100.00,
                IsActive = true
            ));
        }
        insert carePlanPricebookEntries;
        System.debug('carePlanPricebookEntries' + carePlanPricebookEntries);

        List<PricebookEntry> memberSubscriptionCarePlanEntries = new List<PricebookEntry>(); 
        Integer k=0;     
        for (Product2 pro : products) {   
            if(k<10){
                memberSubscriptionCarePlanEntries.add(new PricebookEntry(
                Pricebook2Id = testMemberSuscriptionAndCarePlanPriceBook.Id,
                Product2Id = pro.Id,
                UnitPrice = 100.00,
                IsActive = true                
            ));
            k=k+1;
            }
        }
        insert memberSubscriptionCarePlanEntries;
        System.debug('memberSubscriptionCarePlanEntries' + memberSubscriptionCarePlanEntries);
        
        // Step 4: Instantiate the batch class
        BWC_MemberPriceBookUpdate batch = new BWC_MemberPriceBookUpdate();

        // Step 5: Set up test data and execute the batch within System.runAs() block
       // System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();

            // Call the execute method
            Database.executeBatch(batch, 100);

            Test.stopTest();
       // }

        // Step 6: Add assertions to verify the expected results of the batch execution
        // List<PricebookEntry> updatedEntries = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :testMemPricebook.Id];
        // System.assertEquals(pricebookEntries.size(), updatedEntries.size(), 'Number of updated entries should match the original entries');
    
}
}
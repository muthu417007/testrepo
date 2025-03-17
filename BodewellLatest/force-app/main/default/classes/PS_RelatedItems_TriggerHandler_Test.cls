@isTest
private class PS_RelatedItems_TriggerHandler_Test {

    private static final String RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED = 'Superseded';
    private static final String RELATED_ITEMS_CHANNEL_RETAIL = 'Retail';
    private static final String RELATED_ITEMS_CHANNEL_CONTRACT = 'Contract';

    @TestSetup
    static void makeData(){
        Product2 retailNpiTransition = new Product2(
            Name = 'Retail NPI',
            Item_Number__c = '1'
        );
        insert retailNpiTransition;
        List<Product2> products = new List<Product2>();
        products.add(new Product2(
            Name = 'Product',
            Retail_NPI_Transition__c = retailNpiTransition.Id,
            Retail_Additional_NPI_Transitions__c = 'a',
            Contract_Additional_NPI_Transitions__c = 'a',
            Item_Number__c = '2'
        ));
        products.add(new Product2(
            Name = 'Product 2',
            Retail_NPI_Transition__c = retailNpiTransition.Id,
            Retail_Additional_NPI_Transitions__c = 'b',
            Contract_Additional_NPI_Transitions__c = 'b',
            Item_Number__c = '10'
        ));
        products.add(new Product2(
            Name = 'Related Product',
            Item_Number__c = '3'
        ));
        products.add(new Product2(
            Name = 'Related Product 2',
            Item_Number__c = '4'
        ));
        products.add(new Product2(
            Name = 'Related Product 3',
            Item_Number__c = '5'
        ));
        insert products;
    }

    @isTest
    static void onInsert_ShouldUpdateProductWithRelatedProdAndStartDateForSupersededRetailRelatedItems () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];

        Test.startTest();

        Related_Items__c relItem = new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_RETAIL,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today()
        );
        insert relItem;

        Test.stopTest();

        Product2 updatedProd = [SELECT Id, Retail_NPI_Transition__c, Retail_Transition_Date__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(relItem.Related_Product__c, updatedProd.Retail_NPI_Transition__c);
        System.assertEquals(relItem.Start_Date__c, updatedProd.Retail_Transition_Date__c);
    }

    @isTest
    static void onInsert_ShouldUpdateFieldsWithNullIfNotSuperseded () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];

        Test.startTest();

        Related_Items__c relItem = new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = 'Different',
            Channel__c = RELATED_ITEMS_CHANNEL_RETAIL,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today()
        );
        insert relItem;

        Test.stopTest();

        Product2 updatedProd = [SELECT Id, Retail_NPI_Transition__c, Retail_Additional_NPI_Transitions__c, Retail_Transition_Date__c,
                                        Contract_NPI_Transition__c, Contract_Additional_NPI_Transitions__c, Contract_Transition_Date__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(null, updatedProd.Retail_NPI_Transition__c);
        System.assertEquals(null, updatedProd.Retail_Additional_NPI_Transitions__c);
        System.assertEquals(null, updatedProd.Retail_Transition_Date__c);
        System.assertEquals(null, updatedProd.Contract_NPI_Transition__c);
        System.assertEquals(null, updatedProd.Contract_Additional_NPI_Transitions__c);
        System.assertEquals(null, updatedProd.Contract_Transition_Date__c);
    }

    @isTest
    static void onInsert_ShouldUpdateProductWithRelatedProdAndStartDateForSupersededContractRelatedItems () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];

        Test.startTest();

        Related_Items__c relItem = new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_CONTRACT,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today()
        );
        insert relItem;

        Test.stopTest();

        Product2 updatedProd = [SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(relItem.Related_Product__c, updatedProd.Contract_NPI_Transition__c);
        System.assertEquals(relItem.Start_Date__c, updatedProd.Contract_Transition_Date__c);
    }

    @isTest
    static void onInsert_ShouldUpdateProductWithAllRetailFieldsForThreeSupersededRetailRelatedItems () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];
        Product2 relatedProd2 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 2'];
        Product2 relatedProd3 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 3'];

        Test.startTest();

        List<Related_Items__c> relItems = new List<Related_Items__c>();
        relItems.add(new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_RETAIL,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today()
        ));
        relItems.add(new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_RETAIL,
            Related_Product__c = relatedProd2.Id,
            Start_Date__c = Date.today().addDays(1)
        ));
        relItems.add(new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_RETAIL,
            Related_Product__c = relatedProd3.Id,
            Start_Date__c = Date.today().addDays(2)
        ));
        insert relItems;

        Test.stopTest();

        Product2 updatedProd =
            [SELECT Id, Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
               FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(relItems[0].Related_Product__c, updatedProd.Retail_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, updatedProd.Retail_Transition_Date__c);
        System.assertEquals(relatedProd2.Name + ', ' + relatedProd3.Name, updatedProd.Retail_Additional_NPI_Transitions__c);
    }

    @isTest
    static void onInsert_ShouldUpdateProductWithAllContractFieldsForThreeSupersededContractRelatedItems () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];
        Product2 relatedProd2 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 2'];
        Product2 relatedProd3 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 3'];

        Test.startTest();

        List<Related_Items__c> relItems = new List<Related_Items__c>();
        relItems.add(new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_CONTRACT,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today()
        ));
        relItems.add(new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_CONTRACT,
            Related_Product__c = relatedProd2.Id,
            Start_Date__c = Date.today().addDays(1)
        ));
        relItems.add(new Related_Items__c (
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_CONTRACT,
            Related_Product__c = relatedProd3.Id,
            Start_Date__c = Date.today().addDays(2)
        ));
        insert relItems;

        Test.stopTest();

        Product2 updatedProd =
            [SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c
               FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(relItems[0].Related_Product__c, updatedProd.Contract_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, updatedProd.Contract_Transition_Date__c);
        System.assertEquals(relatedProd2.Name + ', ' + relatedProd3.Name, updatedProd.Contract_Additional_NPI_Transitions__c);
    }

    @isTest
    static void onUpdate_ShouldUpdateBothRetailAndContractWhenChannelIsBlank () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 product2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];
        Product2 relatedProd2 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 2'];

        List<Related_Items__c> relItems = new List<Related_Items__c>();
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today()
        ));
        relItems.add(new Related_Items__c(
            Product__c = product2.Id,
            Related_Product__c = relatedProd2.Id,
            Start_Date__c = Date.today().addDays(1)
        ));
        insert relItems;

        Test.startTest();

        relItems[0].Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED;
        relItems[1].Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED;
        update relItems;

        Test.stopTest();


        Product2 updatedProd =
            [SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c, Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
               FROM Product2 WHERE Id = :product.Id];
        Product2 updatedProd2 =
            [SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c, Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
               FROM Product2 WHERE Id = :product2.Id];

        System.assertEquals(relItems[0].Related_Product__c, updatedProd.Retail_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, updatedProd.Retail_Transition_Date__c);
        System.assertEquals(relItems[0].Related_Product__c, updatedProd.Contract_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, updatedProd.Contract_Transition_Date__c);
        System.assertEquals(relItems[1].Related_Product__c, updatedProd2.Retail_NPI_Transition__c);
        System.assertEquals(relItems[1].Start_Date__c, updatedProd2.Retail_Transition_Date__c);
        System.assertEquals(relItems[1].Related_Product__c, updatedProd2.Contract_NPI_Transition__c);
        System.assertEquals(relItems[1].Start_Date__c, updatedProd2.Contract_Transition_Date__c);
    }

    @isTest
    static void onInsert_ShouldClearProductsThatHaveRelatedItemsWithEndDate () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 product2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];
        Product2 relatedProd2 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 2'];

        List<Related_Items__c> relItems = new List<Related_Items__c>();
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today()
        ));
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Related_Product__c = relatedProd2.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(2)
        ));
        relItems.add(new Related_Items__c (
            Product__c = product2.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Channel__c = RELATED_ITEMS_CHANNEL_CONTRACT,
            Related_Product__c = relatedProd2.Id,
            Start_Date__c = Date.today().addDays(2),
            End_Date__c = Date.today().addDays(2)
        ));

        Test.startTest();

        insert relItems;

        Test.stopTest();

        Set<Id> productIds = new Set<Id>{product.Id, product2.Id};

        Map<Id, Product2> idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(relItems[0].Related_Product__c, idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(relItems[0].Related_Product__c, idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_Additional_NPI_Transitions__c);

        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Additional_NPI_Transitions__c);
    }

    @isTest
    static void onInsert_ShouldClearProductsThatHaveAllRelatedItemsWithEndDate () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 product2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];
        Product2 relatedProd2 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 2'];

        List<Related_Items__c> relItems = new List<Related_Items__c>();
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(1)
        ));
        relItems.add(new Related_Items__c(
            Product__c = product2.Id,
            Related_Product__c = relatedProd2.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(2)
        ));

        Test.startTest();

        insert relItems;

        Test.stopTest();

        Set<Id> productIds = new Set<Id>{product.Id, product2.Id};

        Map<Id, Product2> idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_Additional_NPI_Transitions__c);

        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Additional_NPI_Transitions__c);
    }

    @isTest
    static void onUpdate_ShouldClearProductsThatHaveRelatedItemsWithEndDate () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 product2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];
        Product2 relatedProd2 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 2'];

        List<Related_Items__c> relItems = new List<Related_Items__c>();
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Related_Product__c = relatedProd.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Start_Date__c = Date.today()
        ));
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Related_Product__c = relatedProd2.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Start_Date__c = Date.today().addDays(1)
        ));
        relItems.add(new Related_Items__c(
            Product__c = product2.Id,
            Related_Product__c = relatedProd.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Start_Date__c = Date.today().addDays(2)
        ));
        relItems.add(new Related_Items__c(
            Product__c = product2.Id,
            Related_Product__c = relatedProd2.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Start_Date__c = Date.today().addDays(3)
        ));
        insert relItems;

        Set<Id> productIds = new Set<Id>{product.Id, product2.Id};

        Map<Id, Product2> idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(
            relItems[0].Related_Product__c,
            idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c
        );
        System.assertEquals(
            relItems[0].Start_Date__c,
            idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c
        );
        System.assertEquals(
            relatedProd2.Name,
            idToUpdatedProdMap.get(product.Id).Retail_Additional_NPI_Transitions__c
        );
        System.assertEquals(
            relItems[0].Related_Product__c,
            idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c
        );
        System.assertEquals(
            relItems[0].Start_Date__c,
            idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c
        );
        System.assertEquals(
            relatedProd2.Name,
            idToUpdatedProdMap.get(product.Id).Contract_Additional_NPI_Transitions__c
        );

        System.assertEquals(
            relItems[2].Related_Product__c,
            idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c
        );
        System.assertEquals(
            relItems[2].Start_Date__c,
            idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c
        );
        System.assertEquals(
            relatedProd2.Name,
            idToUpdatedProdMap.get(product2.Id).Retail_Additional_NPI_Transitions__c
        );
        System.assertEquals(
            relItems[2].Related_Product__c,
            idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c
        );
        System.assertEquals(
            relItems[2].Start_Date__c,
            idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c
        );
        System.assertEquals(
            relatedProd2.Name,
            idToUpdatedProdMap.get(product2.Id).Contract_Additional_NPI_Transitions__c
        );

        Test.startTest();

        relItems[1].End_Date__c = Date.today().addDays(1);
        relItems[3].End_Date__c = Date.today().addDays(2);
        update relItems;

        Test.stopTest();

        idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(
            relItems[0].Related_Product__c,
            idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c
        );
        System.assertEquals(
            relItems[0].Start_Date__c,
            idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c
        );
        System.assertEquals(
            null,
            idToUpdatedProdMap.get(product.Id).Retail_Additional_NPI_Transitions__c
        );
        System.assertEquals(
            relItems[0].Related_Product__c,
            idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c
        );
        System.assertEquals(
            relItems[0].Start_Date__c,
            idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c
        );
        System.assertEquals(
            null,
            idToUpdatedProdMap.get(product.Id).Contract_Additional_NPI_Transitions__c
        );

        System.assertEquals(
            relItems[2].Related_Product__c,
            idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c
        );
        System.assertEquals(
            relItems[2].Start_Date__c,
            idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c
        );
        System.assertEquals(
            null,
            idToUpdatedProdMap.get(product2.Id).Retail_Additional_NPI_Transitions__c
        );
        System.assertEquals(
            relItems[2].Related_Product__c,
            idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c
        );
        System.assertEquals(
            relItems[2].Start_Date__c,
            idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c
        );
        System.assertEquals(
            null,
            idToUpdatedProdMap.get(product2.Id).Contract_Additional_NPI_Transitions__c
        );
    }

    @isTest
    static void onUpdate_ShouldClearProductsThatHaveAllRelatedItemsWithEndDate () {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 product2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];
        Product2 relatedProd2 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 2'];

        List<Related_Items__c> relItems = new List<Related_Items__c>();
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Related_Product__c = relatedProd.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Start_Date__c = Date.today()
        ));
        relItems.add(new Related_Items__c(
            Product__c = product2.Id,
            Related_Product__c = relatedProd2.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Start_Date__c = Date.today().addDays(1)
        ));
        insert relItems;

        Set<Id> productIds = new Set<Id>{product.Id, product2.Id};

        Map<Id, Product2> idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(
            relItems[0].Related_Product__c,
            idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c
        );
        System.assertEquals(
            relItems[0].Start_Date__c,
            idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c
        );
        System.assertEquals(
            relItems[0].Related_Product__c,
            idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c
        );
        System.assertEquals(
            relItems[0].Start_Date__c,
            idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c
        );

        System.assertEquals(
            relItems[1].Related_Product__c,
            idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c
        );
        System.assertEquals(
            relItems[1].Start_Date__c,
            idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c
        );
        System.assertEquals(
            relItems[1].Related_Product__c,
            idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c
        );
        System.assertEquals(
            relItems[1].Start_Date__c,
            idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c
        );

        Test.startTest();

        relItems[0].End_Date__c = Date.today().addDays(1);
        relItems[1].End_Date__c = Date.today().addDays(2);
        update relItems;

        Test.stopTest();

        idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_Additional_NPI_Transitions__c);

        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Additional_NPI_Transitions__c);
    }

    @isTest
    static void onInsert_ShouldClearProductsThatHadRelatedItemsDeleted() {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product'];
        Product2 product2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        Product2 relatedProd = [SELECT Id FROM Product2 WHERE Name = 'Related Product'];
        Product2 relatedProd2 = [SELECT Id, Name FROM Product2 WHERE Name = 'Related Product 2'];

        List<Related_Items__c> relItems = new List<Related_Items__c>();
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today()
        ));
        relItems.add(new Related_Items__c(
            Product__c = product.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Related_Product__c = relatedProd2.Id,
            Start_Date__c = Date.today().addDays(1)
        ));
        relItems.add(new Related_Items__c(
            Product__c = product2.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Related_Product__c = relatedProd.Id,
            Start_Date__c = Date.today().addDays(2)
        ));
        relItems.add(new Related_Items__c(
            Product__c = product2.Id,
            Sales_Relationship_Type__c = RELATED_ITEMS_SALES_REL_TYPE_SUPERSEDED,
            Related_Product__c = relatedProd2.Id,
            Start_Date__c = Date.today().addDays(3)
        ));
        insert relItems;

        Set<Id> productIds = new Set<Id>{product.Id, product2.Id};

        Map<Id, Product2> idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(relItems[0].Related_Product__c, idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c);
        System.assertEquals(relatedProd2.Name, idToUpdatedProdMap.get(product.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(relItems[0].Related_Product__c, idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c);
        System.assertEquals(relatedProd2.Name, idToUpdatedProdMap.get(product.Id).Contract_Additional_NPI_Transitions__c);

        System.assertEquals(relItems[2].Related_Product__c, idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c);
        System.assertEquals(relItems[2].Start_Date__c, idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c);
        System.assertEquals(relatedProd2.Name, idToUpdatedProdMap.get(product2.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(relItems[2].Related_Product__c, idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c);
        System.assertEquals(relItems[2].Start_Date__c, idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c);
        System.assertEquals(relatedProd2.Name, idToUpdatedProdMap.get(product2.Id).Contract_Additional_NPI_Transitions__c);

        delete relItems[1];
        delete relItems[3];

        idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(relItems[0].Related_Product__c, idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(relItems[0].Related_Product__c, idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c);
        System.assertEquals(relItems[0].Start_Date__c, idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_Additional_NPI_Transitions__c);

        System.assertEquals(relItems[2].Related_Product__c, idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c);
        System.assertEquals(relItems[2].Start_Date__c, idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(relItems[2].Related_Product__c, idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c);
        System.assertEquals(relItems[2].Start_Date__c, idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Additional_NPI_Transitions__c);

        delete relItems[0];
        delete relItems[2];

        idToUpdatedProdMap = new Map<Id, Product2>([
            SELECT Id, Contract_NPI_Transition__c, Contract_Transition_Date__c, Contract_Additional_NPI_Transitions__c,
                Retail_NPI_Transition__c, Retail_Transition_Date__c, Retail_Additional_NPI_Transitions__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product.Id).Contract_Additional_NPI_Transitions__c);

        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Retail_Additional_NPI_Transitions__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_NPI_Transition__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Transition_Date__c);
        System.assertEquals(null, idToUpdatedProdMap.get(product2.Id).Contract_Additional_NPI_Transitions__c);
    }

    @isTest
    static void coverMethodsNotUsedOfTriggerHandler () {
        new PS_RelatedItems_TriggerHandler().beforeInsert(null);
        new PS_RelatedItems_TriggerHandler().beforeUpdate(null, null);
        new PS_RelatedItems_TriggerHandler().beforeDelete(null);
    }
}
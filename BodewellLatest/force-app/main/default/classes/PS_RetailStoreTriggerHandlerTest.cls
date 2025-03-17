@isTest
private class PS_RetailStoreTriggerHandlerTest {

    private static final String LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE = 'Headquarters/Buying Office';

    @TestSetup
    static void makeData() {
        Account acc1 = new Account(
            Name = 'Account 1',
            Direct_Sales_Customer__c = 'Yes',
            Meet_Comp_Eligibility__c = 'National',
            Status__c = 'A'
        );
        insert new List<Account>{acc1};

        Schema.Location testLocation = new Schema.Location(Name = 'Test Location');
        insert testLocation;

        RetailStore rs1 = new RetailStore(
            Name = 'rs1',
            AccountId = acc1.Id,
            LocationId = testLocation.Id,
            Location_Type__c = LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE
        );
        RetailStore rs2 = new RetailStore(
            Name = 'rs2',
            AccountId = acc1.Id,
            LocationId = testLocation.Id,
            Location_Type__c = LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE
        );
        RetailStore rs3 = new RetailStore(
            Name = 'rs3',
            AccountId = acc1.Id,
            LocationId = testLocation.Id,
            Location_Type__c = LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE
        );
        insert new List<RetailStore>{rs1, rs2, rs3};
    }

    @isTest
    static void shouldDeleteAllRetailStores() {
        //GIVEN
        Map<Id, RetailStore> retailStoresToDeleteMap = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore]
        );

        Account acc1 = [SELECT Id FROM Account LIMIT 1];
        Visit v1 = new Visit(
            Subject__c = 'visit1', Status = 'Planned', AccountId = acc1.id,
            PlaceId = retailStoresToDeleteMap.values()[0].Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );

        List<Visit> visits = new List<Visit>{v1};
        insert visits;

        Datetime createdDateInPast = Datetime.now().addMonths(-(PS_RetailStoreTriggerHandler.NUMBER_OF_MONTH_TO_CHECK + 1));
        System.Test.setCreatedDate(v1.Id, createdDateInPast);

        Visit_Task__c vt1 = new Visit_Task__c(
            Visit__c = v1.Id,
            Task_Name__c = 'Task name 2',
            Task_Description__c = 'Task description 2',
            Task_Type__c = 'Text',
            IsRequired__c = false
        );
        insert vt1;

        //WHEN
        delete retailStoresToDeleteMap.values();

        //THEN
        List<RetailStore> deletedRetailStores = [SELECT Id, IsDeleted FROM RetailStore WHERE Id = :retailStoresToDeleteMap.keySet() ALL ROWS];
        for (RetailStore deletedRetailStore : deletedRetailStores) {
            System.assert(deletedRetailStore.IsDeleted, 'Retail Stores should be deleted');
        }
        List<Visit> deletedVisits = [SELECT Id, IsDeleted FROM Visit ALL ROWS];
        for (Visit deletedVisit : deletedVisits) {
            System.assert(deletedVisit.IsDeleted, 'Visit should be deleted');
        }
    }

    @isTest
    static void shouldNotDeleteAnyRetailStore() {
        //GIVEN
        Account acc1 = [SELECT Id FROM Account LIMIT 1];
        Map<Id, RetailStore> retailStoresToDeleteMap = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore ORDER BY Id ASC]
        );

        Visit v1 = new Visit(
            Subject__c = 'visit1', Status = 'Planned', AccountId = acc1.id,
            PlaceId = retailStoresToDeleteMap.values()[0].Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
        Visit v2 = new Visit(
            Subject__c = 'visit2', Status = 'Planned', AccountId = acc1.id,
            PlaceId = retailStoresToDeleteMap.values()[1].Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
 		Visit v3 = new Visit(
            Subject__c = 'visit3', Status = 'Planned', AccountId = acc1.id,
            PlaceId = retailStoresToDeleteMap.values()[2].Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
        Visit v4 = new Visit(
            Subject__c = 'visit4', Status = 'Planned', AccountId = acc1.id,
            PlaceId = retailStoresToDeleteMap.values()[2].Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
        List<Visit> visits = new List<Visit>{v1, v2, v3, v4};
        insert visits;

        Datetime createdDateInPast = Datetime.now().addMonths(-(PS_RetailStoreTriggerHandler.NUMBER_OF_MONTH_TO_CHECK - 2));
        System.Test.setCreatedDate(v1.Id, createdDateInPast);

        Product2 product1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1', Brand__c = 'Amana');
        insert product1;
        StoreProduct sp1 = new StoreProduct(
            ProductId = product1.Id,
            RetailStoreId = retailStoresToDeleteMap.values()[0].Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3));
        StoreProduct sp2 = new StoreProduct(
            ProductId = product1.Id,
            RetailStoreId = retailStoresToDeleteMap.values()[1].Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3)
        );
        StoreProduct sp3 = new StoreProduct(
            ProductId = product1.Id,
            RetailStoreId = retailStoresToDeleteMap.values()[2].Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3)
        );
        StoreProduct sp4 = new StoreProduct(
            ProductId = product1.Id,
            RetailStoreId = retailStoresToDeleteMap.values()[2].Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3)
        );
        List<StoreProduct> storeProducts = new List<StoreProduct>{sp1, sp2, sp3, sp4};
        insert storeProducts;

        //WHEN
        List<Database.DeleteResult> rsDeleteResults = Database.delete(retailStoresToDeleteMap.values(), false);

        //THEN
        System.assertEquals(
            retailStoresToDeleteMap.size(),
            [SELECT count() FROM RetailStore WHERE Id = :retailStoresToDeleteMap.keySet()],
            'Number of not deleted retail stores should be equal ' + retailStoresToDeleteMap.size()
        );
        System.assertEquals(
            visits.size(),
            [SELECT count() FROM Visit],
            'Number of not deleted visits should be equal ' + visits.size()
        );
        System.assertEquals(
            storeProducts.size(),
            [SELECT count() FROM StoreProduct],
            'Number of not deleted store products should be equal ' + storeProducts.size()
        );

        String expectedErrorMsg = String.format(
                Label.PS_CANNOT_DELETE_RETAIL_STORE_WITH_ASSOCIATED_VISITS,
                new List<String>{
                    Schema.RetailStore.getSObjectType().getDescribe().getLabel(),
                    Schema.Visit.getSObjectType().getDescribe().getLabelPlural(),
                    String.valueOf(PS_RetailStoreTriggerHandler.NUMBER_OF_MONTH_TO_CHECK)
                }
            ) + ' ' + String.format(
                Label.PS_CANNOT_DELETE_RETAIL_STORE_WITH_ASSOCIATED_STORE_PRODUCTS,
                new List<String>{
                    Schema.RetailStore.getSObjectType().getDescribe().getLabel(),
                    Schema.StoreProduct.getSObjectType().getDescribe().getLabelPlural(),
                    String.valueOf(PS_RetailStoreTriggerHandler.NUMBER_OF_MONTH_TO_CHECK)
                }
            );

        for (Database.DeleteResult rsDeleteResult : rsDeleteResults) {
            if (rsDeleteResult.isSuccess()) {
                System.assert(false, 'Delete result should not be success');
            } else {
                System.assertEquals(
                    expectedErrorMsg,
                    rsDeleteResult.getErrors()[0].getMessage(),
                    'Error message should be equal \'' + expectedErrorMsg + '\''
                );
            }
        }
    }

    @isTest
    static void shouldNotDeleteAnyRetailStoreWithAssociatedVisists() {
        //GIVEN
        Account acc1 = [SELECT Id FROM Account LIMIT 1];
        Map<Id, RetailStore> retailStoresToDeleteMap = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore ORDER BY Id ASC]
        );

        Visit v1 = new Visit(
            Subject__c = 'visit1', Status = 'Planned', AccountId = acc1.id,
            PlaceId = retailStoresToDeleteMap.values()[0].Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
        Visit v2 = new Visit(
            Subject__c = 'visit2', Status = 'Planned', AccountId = acc1.id,
            PlaceId = retailStoresToDeleteMap.values()[1].Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
        List<Visit> visits = new List<Visit>{v1, v2};
        insert visits;

        //WHEN
        List<Database.DeleteResult> rsDeleteResults = Database.delete(retailStoresToDeleteMap.values(), false);

        //THEN
        System.assertEquals(
            2,
            [SELECT count() FROM RetailStore WHERE Id = :retailStoresToDeleteMap.keySet()],
            'Number of not deleted retail stores should be equal 2'
        );
        System.assertEquals(
            visits.size(),
            [SELECT count() FROM Visit],
            'Number of not deleted visits should be equal ' + visits.size()
        );

        String expectedErrorMsg = String.format(
            Label.PS_CANNOT_DELETE_RETAIL_STORE_WITH_ASSOCIATED_VISITS,
            new List<String>{
                Schema.RetailStore.getSObjectType().getDescribe().getLabel(),
                Schema.Visit.getSObjectType().getDescribe().getLabelPlural(),
                String.valueOf(PS_RetailStoreTriggerHandler.NUMBER_OF_MONTH_TO_CHECK)
            }
        );

        Integer successDeletionCount = 0;
        for (Database.DeleteResult rsDeleteResult : rsDeleteResults) {
            if (rsDeleteResult.isSuccess()) {
                successDeletionCount++;
            } else {
                System.assertEquals(
                    expectedErrorMsg,
                    rsDeleteResult.getErrors()[0].getMessage(),
                    'Error message should be equal \'' + expectedErrorMsg + '\''
                );
            }
        }
        System.assertEquals(1, successDeletionCount, 'Number of success deletions should be equal 1');
    }

    @isTest
    static void shouldCoverEmptyMethods() {
        new PS_RetailStoreTriggerHandler().beforeInsert(null);
        new PS_RetailStoreTriggerHandler().afterInsert(null);
        new PS_RetailStoreTriggerHandler().beforeUpdate(null, null);
        new PS_RetailStoreTriggerHandler().afterUpdate(null, null);
        new PS_RetailStoreTriggerHandler().afterDelete(null);
    }

}
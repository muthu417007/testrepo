@isTest
public class PS_StoreProduct_TriggerHandler_Test {

	@testSetup
	static void setup() {
        Account acc1 = new Account(Name = 'Account 1');
        insert acc1;

        Schema.Location testLocation = new Schema.Location(Name = 'test');
        insert testLocation;
        
        Product2 nonGeProduct = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1', Brand__c = 'Amana');
    	Product2 geProduct = new Product2(Name = 'Product 2', Family = 'Hardware', Item_Number__c = '2', Brand__c = 'GE');
        insert new List<Product2>{geProduct, nonGeProduct};
                
        RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = acc1.Id, LocationId = testLocation.Id);
        RetailStore rs2 = new RetailStore(Name = 'rs2', AccountId = acc1.Id, LocationId = testLocation.Id);
        insert new List<RetailStore> {rs1, rs2};
            
        StoreProduct sp1 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp2 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp3 = new StoreProduct(ProductId = geProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp4 = new StoreProduct(ProductId = geProduct.Id, RetailStoreId = rs2.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp5 = new StoreProduct(ProductId = geProduct.Id, RetailStoreId = rs2.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp6 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs2.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp7 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs2.Id, StartDate = System.today().addDays(4));
        insert new List<StoreProduct>{sp1, sp2, sp3, sp4, sp5, sp6, sp7};        

        Profile prof = [select Id from profile where name LIKE '%System Administrator%'];
        List<User> users = new List<User>();
        users.add(new User(
            firstName = 'Abc',
            lastName = 'xyz',
            Alias = 'abcbc',
            profileId = prof.id,
            username = 'abcabc.xyz@test.com',
            email = 'test@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        users.add(new User(
            firstName = 'Abcd',
            lastName = 'xyza',
            Alias = 'abcbd',
            profileId = prof.id,
            username = 'abcabc.xyz2@test.com',
            email = 'test2@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        insert users;
    }
    
    static testMethod void afterInsert_shouldSetCountOnShowroom () {
        //WHEN - insert store products in @testSetup
        //THEN
        RetailStore rs1 = [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c FROM RetailStore WHERE Name = 'rs1'];
    	RetailStore rs2 = [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c FROM RetailStore WHERE Name = 'rs2'];
        
        System.assertEquals(3, rs1.Count_All_Products__c);
        System.assertEquals(2, rs1.Count_Competitive_Products__c);
        System.assertEquals(1, rs1.Count_GEA_Products__c);

        System.assertEquals(4, rs2.Count_All_Products__c);
        System.assertEquals(2, rs2.Count_Competitive_Products__c);
        System.assertEquals(2, rs2.Count_GEA_Products__c);
    }

    static testMethod void afterUpdate_onProductUpdate () {
        //GIVEN
        RetailStore rs1 = [SELECT Id FROM RetailStore WHERE Name = 'rs1'];
    	RetailStore rs2 = [SELECT Id FROM RetailStore WHERE Name = 'rs2'];
        Product2 nonGeProduct = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Product2 geProduct = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        StoreProduct[] storeProducts = [SELECT RetailStoreId, ProductId FROM StoreProduct WHERE IsActive__c = true];
        
        //WHEN
        for (StoreProduct sp : storeProducts) {
            if (sp.RetailStoreId == rs1.Id) {
                sp.ProductId = geProduct.Id;
            } else {
                sp.ProductId = nonGeProduct.Id;
            }
        }

		update storeProducts;

        //THEN
        rs1 = [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c FROM RetailStore WHERE Name = 'rs1'];
    	rs2 = [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c FROM RetailStore WHERE Name = 'rs2'];
        
        System.assertEquals(3, rs1.Count_All_Products__c);
        System.assertEquals(0, rs1.Count_Competitive_Products__c);
        System.assertEquals(3, rs1.Count_GEA_Products__c);

        System.assertEquals(4, rs2.Count_All_Products__c);
        System.assertEquals(4, rs2.Count_Competitive_Products__c);
        System.assertEquals(0, rs2.Count_GEA_Products__c);
    }

    static testMethod void afterUpdate_onEndDateUpdate () {
        //GIVEN
        RetailStore rs1 = [SELECT Id FROM RetailStore WHERE Name = 'rs1'];
    	RetailStore rs2 = [SELECT Id FROM RetailStore WHERE Name = 'rs2'];
        Product2 nonGeProduct = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Product2 geProduct = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        StoreProduct[] storeProducts = [SELECT RetailStoreId, EndDate FROM StoreProduct WHERE IsActive__c = true];
        
        //WHEN
        for (StoreProduct sp : storeProducts) {
            if (sp.RetailStoreId == rs1.Id) {
                sp.EndDate = System.today();
            } else {
                sp.EndDate = System.today().addDays(5);
            }
        }

		update storeProducts;

        //THEN
        rs1 = [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c FROM RetailStore WHERE Name = 'rs1'];
    	rs2 = [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c FROM RetailStore WHERE Name = 'rs2'];
        
        System.assertEquals(3, rs1.Count_All_Products__c);
        System.assertEquals(2, rs1.Count_Competitive_Products__c);
        System.assertEquals(1, rs1.Count_GEA_Products__c);

        System.assertEquals(3, rs2.Count_All_Products__c);
        System.assertEquals(1, rs2.Count_Competitive_Products__c);
        System.assertEquals(2, rs2.Count_GEA_Products__c);
    }

    static testMethod void afterDelete_shouldUpdateCountOnShowrooom () {
        //GIVEN
        RetailStore rs1 = [SELECT Id FROM RetailStore WHERE Name = 'rs1'];
    	RetailStore rs2 = [SELECT Id FROM RetailStore WHERE Name = 'rs2'];
        Product2 nonGeProduct = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        
        StoreProduct sp1 = [SELECT Id FROM StoreProduct WHERE RetailStoreId = :rs1.Id AND IsActive__c = true AND ProductId = :nonGeProduct.Id LIMIT 1];
        StoreProduct[] rs2StoreProducts = [SELECT Id FROM StoreProduct WHERE RetailStoreId = :rs2.Id AND IsActive__c = true];
        
        //WHEN
        rs2StoreProducts.add(sp1);
        delete rs2StoreProducts;

        //THEN
        rs1 = [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c FROM RetailStore WHERE Name = 'rs1'];
    	rs2 = [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c FROM RetailStore WHERE Name = 'rs2'];
        
        System.assertEquals(2, rs1.Count_All_Products__c);
        System.assertEquals(1, rs1.Count_Competitive_Products__c);
        System.assertEquals(1, rs1.Count_GEA_Products__c);

        System.assertEquals(0, rs2.Count_All_Products__c);
        System.assertEquals(0, rs2.Count_Competitive_Products__c);
        System.assertEquals(0, rs2.Count_GEA_Products__c);
    }

}
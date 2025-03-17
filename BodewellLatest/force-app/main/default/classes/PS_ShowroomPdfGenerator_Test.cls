@isTest
public class PS_ShowroomPdfGenerator_Test {
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
        insert rs1;
            
        StoreProduct sp1 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp2 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp3 = new StoreProduct(ProductId = geProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        insert new List<StoreProduct>{sp1, sp2, sp3};
    }

    static testMethod void ctrl_shouldReturnProductsRelatedToShowroom () {
        //GIVEN
        RetailStore rs = [SELECT Id FROM RetailStore];
        ApexPages.StandardController stdController = new ApexPages.StandardController(rs);
        
        //WHEN
    	PS_ShowroomPdfGenerator_ctrl ctrl = new PS_ShowroomPdfGenerator_ctrl(stdController);
        
        //THEN
        System.assertEquals(3, ctrl.products.size(),
        	'Should pull products related to current RetailStore');	
    }
}
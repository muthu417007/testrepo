@isTest
private class ContactDashboardController_test {
	static testMethod void test1() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        PageReference vfPage = Page.caseDashboard;
        Test.setCurrentPage(vfPage);
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.currentPage().getParameters().put('id',c.id);
        ContactDashboardController controller = new ContactDashboardController();
        controller.resetError();
        System.assertEquals(controller.caseError,false);

        pageReference p1 = controller.addAsset();
        pageReference p2 = controller.addLocation();
        pageReference p3 = controller.cancel();
        pageReference p4 = controller.cancelAddAsset();
        
        pageReference p5 = controller.cancelAddLocation();
        System.assertEquals(controller.renderAddLocation,false);
        pageReference p6 = controller.removeLocation();
        pageReference p7 = controller.relocateAsset();
        pageReference p8 = controller.relocateAssetButton();
        
        
        Test.stopTest();
        

        //System.assert(modelNumber != null);
        
    }
    
    static testMethod void test2() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        PageReference vfPage = Page.caseDashboard;
        Test.setCurrentPage(vfPage);
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.currentPage().getParameters().put('id',c.id);
        ContactDashboardController controller = new ContactDashboardController();
        controller.resetError();
        System.assertEquals(controller.caseError,false);

        pageReference p1 = controller.addAsset();
        pageReference p2 = controller.addLocation();
        pageReference p3 = controller.cancel();
        pageReference p4 = controller.cancelAddAsset();
        
        pageReference p5 = controller.cancelAddLocation();
        System.assertEquals(controller.renderAddLocation,false);
        controller.locationsList[0].selected = true;
        pageReference p6 = controller.removeLocation();
        pageReference p7 = controller.relocateAsset();
        pageReference p8 = controller.relocateAssetButton();
        
        
        Test.stopTest();
        

        //System.assert(modelNumber != null);
        
    }  
        
    static testMethod void test3() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        PageReference vfPage = Page.caseDashboard;
        Test.setCurrentPage(vfPage);
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.currentPage().getParameters().put('id',c.id);
        ContactDashboardController controller = new ContactDashboardController();
        controller.resetError();
        System.assertEquals(controller.caseError,false);

        pageReference p1 = controller.addAsset();
        pageReference p2 = controller.addLocation();
        pageReference p3 = controller.cancel();
        pageReference p4 = controller.cancelAddAsset();
        
        pageReference p5 = controller.cancelAddLocation();
        System.assertEquals(controller.renderAddLocation,false);
        controller.assetsList[0].selected = true;
        
        pageReference p7 = controller.relocateAsset();
        pageReference p8 = controller.relocateAssetButton();
        
        
        Test.stopTest();
        

        //System.assert(modelNumber != null);
    } 
    
    static testMethod void test4() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        PageReference vfPage = Page.caseDashboard;
        Test.setCurrentPage(vfPage);
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.currentPage().getParameters().put('id',c.id);
        ContactDashboardController controller = new ContactDashboardController();
        controller.resetError();
        System.assertEquals(controller.caseError,false);
 
        pageReference p1 = controller.searchContact();
        pageReference p2 = controller.redirectSearch();
               
        Test.stopTest();  
    } 
    
    static testMethod void test5() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        PageReference vfPage = Page.caseDashboard;
        Test.setCurrentPage(vfPage);
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.currentPage().getParameters().put('id',c.id);
        ContactDashboardController controller = new ContactDashboardController();
        controller.resetError();
        System.assertEquals(controller.caseError,false);

        pageReference p1 = controller.addAsset();
        pageReference p2 = controller.addLocation();
        pageReference p3 = controller.cancel();
        pageReference p4 = controller.cancelAddAsset();
        
        pageReference p5 = controller.cancelAddLocation();
        System.assertEquals(controller.renderAddLocation,false);
        controller.assetsList[0].selected = true;
        controller.caseSubject = 'test';
        controller.caseNotes = 'test';
        pageReference p7 = controller.createCase();
        
        
        
        Test.stopTest();
        

        //System.assert(modelNumber != null);
    } 
        
    static testMethod void test6() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        PageReference vfPage = Page.caseDashboard;
        Test.setCurrentPage(vfPage);
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.currentPage().getParameters().put('id',c.id);
        ContactDashboardController controller = new ContactDashboardController();
        controller.resetError();
        System.assertEquals(controller.caseError,false);
        
        //fail
		pageReference p1 = controller.verifyServiceLocation();
        //success
        controller.streetName = '1 test';
        controller.zipCode = '32137';
        pageReference p2 = controller.verifyServiceLocation();

        Test.stopTest();
    }
    
    static testMethod void test7() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        PageReference vfPage = Page.caseDashboard;
        Test.setCurrentPage(vfPage);
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.currentPage().getParameters().put('id',c.id);
        ContactDashboardController controller = new ContactDashboardController();
        controller.resetError();
        System.assertEquals(controller.caseError,false);
        
        //fail
		pageReference p1 = controller.verifyAsset();
        //success
        controller.modelNumber = 'ABC';
        pageReference p2 = controller.verifyAsset();
		List<SelectOption> testOptions = controller.getLocationSelections();
        Test.stopTest();
    }
    

}
@isTest
private class CaseDashboardController_test {
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
        ApexPages.currentPage().getParameters().put('id',caseRec.id);
        caseDashboardController controller = new caseDashboardController();
        controller.phone = '1231231231';
        controller.search();
        controller.getArchivedContacts();
        pageReference p1 = controller.restoreContact();
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
        ApexPages.currentPage().getParameters().put('id',caseRec.id);
        caseDashboardController controller = new caseDashboardController();
        controller.email = 'test@test.com';
        controller.search();
        controller.getArchivedContactsEmail();
        pageReference p1 = controller.restoreContactEmail();
        controller.clearSearch();
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
        ApexPages.currentPage().getParameters().put('id',caseRec.id);
        caseDashboardController controller = new caseDashboardController();
        pageReference p1 = controller.createContact();
        controller.street = '1 Main';
        controller.zip = '32137';
        controller.firstName = 'test';
        controller.lastName = 'test';
        controller.phone = '1231231231';
        //controller.showCreateContact = true;
        pageReference p2 = controller.createContact();
        pageReference p3 = controller.verifyAsset();
        controller.modelNumber = 'PVM9179FLDS';
        pageReference p4 = controller.verifyAsset();
        controller.selectedContactId = c.id;
        pageReference p5 = controller.linkContact();
        controller.additionalAssetsWrapper[0].isSelected = true;
        pageReference p6 = controller.attachAsset();
        Test.stopTest();
        

        //System.assert(modelNumber != null);
        
    }
   
}
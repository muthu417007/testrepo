@isTest
private class SearchControllerVFAuth0_test {
  static testMethod void testSuccess() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        
        // Perform test
        Test.startTest();
        PageReference vfPage = Page.contactSearch;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('ani','1231234');
        SearchControllerVFAuth0 controller = new SearchControllerVFAuth0();
        pageReference p1 = controller.redirectSearch();
        controller.search();
        controller.getArchivedContacts();
        controller.email = 'test@test.com';
        controller.getArchivedContactsEmail();
        pageReference p2 = controller.clearSearch();
        Test.stopTest();
        

        //System.assert(modelNumber != null);
        
    }
    
    
    
    static testMethod void testCreateContact() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        
        // Perform test
        Test.startTest();
        PageReference vfPage = Page.contactSearch;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('ani','1231234');
        SearchControllerVFAuth0 controller = new SearchControllerVFAuth0();
        pageReference p1 = controller.createContact();
        controller.street = '1 Main';
        controller.zip = '32137';
        controller.firstName = 'test';
        controller.lastName = 'test';
        controller.phone = '1231231231';
        controller.showCreateContact = true;
        pageReference p2 = controller.createContact();
        pageReference p3 = controller.search();
        pageReference p4 = controller.restoreContact();
        Test.stopTest();
        

        //System.assert(modelNumber != null);
        
    }
    
    static testMethod void testCreateContact2() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        
        // Perform test
        Test.startTest();
        PageReference vfPage = Page.contactSearch;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('ani','1231234');
        SearchControllerVFAuth0 controller = new SearchControllerVFAuth0();
        pageReference p1 = controller.createContact();
        controller.street = '1 Main';
        controller.zip = '32137';
        controller.firstName = 'test';
        controller.lastName = 'test';
        controller.phone = '1231231231';
        controller.showCreateContact = true;
        controller.createUnknownAddress = false;
        pageReference p2 = controller.createContact();
        pageReference p3 = controller.search();
        pageReference p4 = controller.restoreContact();
        Test.stopTest();
        

        //System.assert(modelNumber != null);
        
    }
    
    static testMethod void testSearchEmail() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        
        // Perform test
        Test.startTest();
        PageReference vfPage = Page.contactSearch;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('ani','1231234');
        SearchControllerVFAuth0 controller = new SearchControllerVFAuth0();
        pageReference p1 = controller.createContact();
        controller.street = '1 Main';
        controller.zip = '32137';
        controller.firstName = 'test';
        controller.lastName = 'test';
        controller.email = 'test@test.com';
        controller.showCreateContact = true;
        pageReference p3 = controller.search();
        //pageReference p4 = controller.restoreContact();
        pageReference p5 = controller.restoreContactEmail();
        Test.stopTest();

        
    }
}
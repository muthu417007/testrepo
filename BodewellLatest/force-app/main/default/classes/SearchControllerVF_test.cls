@isTest
private class SearchControllerVF_test {
    static testMethod void testSuccess() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        
        // Perform test
        Test.startTest();
        PageReference vfPage = Page.contactSearch;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('ani','1231231231');
        SearchControllerVF controller = new SearchControllerVF();
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
        SearchControllerVF controller = new SearchControllerVF();
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
        SearchControllerVF controller = new SearchControllerVF();
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
        ApexPages.currentPage().getParameters().put('ani','1231231231');
        SearchControllerVF controller = new SearchControllerVF();
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

    private static testMethod void testsetUnknown() {
        Test.startTest();
        SearchControllerVF controller = new SearchControllerVF();
        controller.createUnknownAddress= true;
        pageReference p1 = controller.setUnknown();
        Test.stopTest();
        

        //System.assert(modelNumber != null);
    }
    
    private static testMethod void testsetCountry() {
        Test.startTest();
        SearchControllerVF controller = new SearchControllerVF();
        pageReference p1 = controller.setCountry();
        Test.stopTest();
        

        //System.assert(modelNumber != null);
    }
        /**
 * @author         Neha Chowdhury
 * @company        Ge-appliances
 * @created        07.01.2022
 * @description    This is for testing the setCanadaCountryFunction
 */
     private static testMethod void testsetCountryCanada() {
        Test.startTest();
        SearchControllerVF controller = new SearchControllerVF();
       	controller.selectedCountry= 'Canada';
		pageReference p1 = controller.setCountry();
        Test.stopTest();
        

        //System.assert(modelNumber != null);
    }

   private static testMethod void testcreateUnknownContactAddress() {
       // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        
        // Perform test
        Test.startTest();
        PageReference vfPage = Page.contactSearch;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('ani','1231234');
        SearchControllerVF controller = new SearchControllerVF();
        //pageReference p1 = controller.createUnknownContactAddress();
        controller.street = 'Unknown';
        controller.zip = '32137';
        controller.firstName = 'Unknown';
        controller.LastName = 'Unknown';
        controller.phone = '1231231231';
        controller.email = 'test@geappliances.com';
        controller.showCreateContact = true;
        controller.createUnknownAddress=true;
        pageReference p2 = controller.createContact();
        pageReference p3 = controller.search();
        pageReference p4 = controller.restoreContact();
        Test.stopTest();

        //System.assert(modelNumber != null);
    }
            /**
 * @author         Neha Chowdhury
 * @company        Ge-appliances
 * @created        07.01.2022
 * @description    This is for testing the Creation of the contcat when the country is Canada
 */
       private static testMethod void testcreateCanadaContact() {
       // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        
        // Perform test
        Test.startTest();
        PageReference vfPage = Page.contactSearch;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('ani','1231234');
        SearchControllerVF controller = new SearchControllerVF();
       	controller.street = 'Ontario';
        controller.selectedCountry = 'Canada';
        controller.zip = 'A1A 1A1';
        controller.state = 'Ontario';
        controller.city = 'Chicoutimi';
        controller.firstName = 'Unknown';
        controller.LastName = 'Unknown';
        controller.phone = '1231231231';
        controller.email = 'test@geappliances.com';
        controller.showCreateContact = true;
        pageReference p2 = controller.createContact();
        pageReference p3 = controller.search();
        pageReference p4 = controller.restoreContact();
        Test.stopTest();

        //System.assert(modelNumber != null);
    }
            /**
 * @author         Neha Chowdhury
 * @company        Ge-appliances
 * @created        07.01.2022
 * @description    This is for testing the errors when the country is canada like state and city is blank/Null
 */
    private static testMethod void testcreateCanadaContactCheckErrors() {
       // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        
        // Perform test
        Test.startTest();
        PageReference vfPage = Page.contactSearch;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('ani','1231234');
        SearchControllerVF controller = new SearchControllerVF();
       	controller.street = 'Ontario';
        controller.selectedCountry = 'Canada';
        controller.zip = 'A1A 1A1';
        controller.firstName = 'Unknown';
        controller.LastName = 'Unknown';
        controller.phone = '1231231231';
        controller.email = 'test@geappliances.com';
        controller.showCreateContact = true;
        pageReference p2 = controller.createContact();
        pageReference p3 = controller.search();
        pageReference p4 = controller.restoreContact();
        Test.stopTest();

        //System.assert(modelNumber != null);
    }
}
@isTest
public class Contact_ext_test {

    static testMethod void test1() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.StandardController stdContact = new ApexPages.StandardController(c);
        Contact_ext controller = new Contact_ext(stdContact);
        PageReference p1 = controller.contactDashboard();
        Test.stopTest();
    }
}
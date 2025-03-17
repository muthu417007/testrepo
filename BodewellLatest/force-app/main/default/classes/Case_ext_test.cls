@isTest
public class Case_ext_test {

    static testMethod void test1() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.StandardController stdCase = new ApexPages.StandardController(caseRec);
        Case_ext controller = new Case_ext(stdCase);
        PageReference p1 = controller.caseDashboard();
        Test.stopTest();
    }
}
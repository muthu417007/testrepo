@isTest
public class Asset_ext_test {

    static testMethod void test1() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.StandardController stdAsset = new ApexPages.StandardController(assets[0]);
        Asset_ext controller = new Asset_ext(stdAsset);
        
        Test.stopTest();
    }
}
@isTest
private class AssetCallout_test {
	static testMethod void test1() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        List<String> assetString = new List<String>();
        assetString.add(assets[0].id);
        
        // Perform test
        Test.startTest();
        
		AssetCallout.updateAsset(assetString);
        
        Test.stopTest();
        

        //System.assert(modelNumber != null);
        
    }
}
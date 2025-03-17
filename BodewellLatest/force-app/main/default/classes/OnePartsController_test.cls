@isTest
private class OnePartsController_test{
    @isTest static void testSuccess() {
        // Test data setup
      
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
   
        // Perform test
        Test.startTest();
        String modelNumber = onePartsController.getModelNumber(assets[0].id);
        Test.stopTest();
        
        // Verify that the deletion should have been stopped by the trigger,
        // so check that we got back an error.
        
        System.assert(modelNumber != null);
        
    }
    @isTest static void testFail() {
        // Test data setup
      
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);

        // Perform test
        Test.startTest();
        String modelNumber = onePartsController.getModelNumber(null);
        Test.stopTest();
        
        // Verify that the deletion should have been stopped by the trigger,
        // so check that we got back an error.
        
        System.assert(modelNumber == null);
        
    }             
}
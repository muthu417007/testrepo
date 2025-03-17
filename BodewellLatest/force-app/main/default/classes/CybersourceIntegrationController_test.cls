@isTest
public class CybersourceIntegrationController_test {

    static testMethod void test1() {
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        CybersourceIntegrationController controller = new CybersourceIntegrationController();
        CybersourceIntegrationController.MakeCallout();
        String testResult = CybersourceIntegrationController.getBody();
        CybersourceIntegrationController.sign('1234test');
        List<Integer> testResult2 = CybersourceIntegrationController.B64ToBytes ('test');
        List<Integer> testResult3 = CybersourceIntegrationController.BlobToBytes (blob.valueOf('test'));
        Test.stopTest();
    }
}
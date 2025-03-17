@isTest
public class ConnectedAppliance_ext_test {

    static testMethod void test1() {
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.StandardController stdAsset = new ApexPages.StandardController(assets[0]);
        ConnectedAppliance_ext controller = new ConnectedAppliance_ext(stdAsset);
        PageReference p1 = controller.checkStatus();
        Test.stopTest();
    }
    static testMethod void test2() {
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        assets[0].MACAddress__c = '12345';
        update assets[0];
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.StandardController stdAsset = new ApexPages.StandardController(assets[0]);
        ConnectedAppliance_ext controller = new ConnectedAppliance_ext(stdAsset);
        PageReference p1 = controller.checkStatus();
        ConnectedApplianceResponse testResponse = new ConnectedApplianceResponse();
        testResponse.applianceId = 'test';
        testResponse.brandId = 2;
        testResponse.brandName = 'test';
        testResponse.country = 'test';
        testResponse.environment = 'test';
        testResponse.kind = 'test';
        testResponse.poolId = 'test';
        testResponse.presence = 'test';
        testResponse.region = 'test';
        testResponse.userId = 'test';
        Test.stopTest();
    }
    static testMethod void test3() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        assets[0].MACAddress__c = null;
        update assets[0];
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.StandardController stdAsset = new ApexPages.StandardController(assets[0]);
        ConnectedAppliance_ext controller = new ConnectedAppliance_ext(stdAsset);
        PageReference p1 = controller.checkStatus();
        ConnectedApplianceResponse testResponse = new ConnectedApplianceResponse();
        testResponse.applianceId = 'test';
        testResponse.brandId = 2;
        testResponse.brandName = 'test';
        testResponse.country = 'test';
        testResponse.environment = 'test';
        testResponse.kind = 'test';
        testResponse.poolId = 'test';
        testResponse.presence = 'test';
        testResponse.region = 'test';
        testResponse.userId = 'test';
        Test.stopTest();
    }
    static testmethod void fetchcasetest(){
        String res=ConnectedAppliance_ext.fetchCase('5000n000009fIh6AAE');
        System.assertNotEquals(null, res);
    }
}
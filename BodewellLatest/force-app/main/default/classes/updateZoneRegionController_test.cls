@isTest
public class updateZoneRegionController_test {

    static testMethod void test1() {
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ApexPages.StandardController stdCase = new ApexPages.StandardController(caseRec);
        updateZoneRegionController controller = new updateZoneRegionController(stdCase);
        PageReference p1 = controller.updateZoneRegion();
        Case updatedCaseRec = [SELECT account.zone__c 
                             FROM case
                             WHERE id = :caseRec.id LIMIT 1];
        System.assertNotEquals(null,updatedCaseRec.account.zone__c);
        Test.stopTest();
    }
}
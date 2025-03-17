@isTest
private class CX_LocationAndAssetsControllerTest {
    
    @isTest
    static void givenContactIdGetRelatedLocation () {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com');
        insert testContact;
        Account testAccount = new Account(
            Name = 'Location Account',
            RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId()
        );
        insert testAccount;
        GEA_AccountContactRelation__c accCtcRelation = new GEA_AccountContactRelation__c(
            Contact__c = testContact.Id,
            Account__c = testAccount.Id
        );
        insert accCtcRelation;
        
        Test.startTest();
        
        List<Account> locations = CX_LocationAndAssetsController.getLocations(testContact.Id);

        Test.stopTest();

        System.assertNotEquals(null, locations, 'Locations returned can not be null');
        System.assertEquals(1, locations.size(), 'One location is expected to be returned');
        System.assertEquals(testAccount.Id, locations[0].Id, 'Location record must be the same inserted for the test');
    }

    @isTest
    static void givenContactIdGetRelatedAssets () {
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com',AccountId = testaccount.id);
        insert testContact;
        insert new GEA_AccountContactRelation__c(
            Contact__c = testContact.Id,
            Account__c = testAccount.Id
        );

        List<Asset> testAssets = new List<Asset>();
        testAssets.add(new Asset(
            ContactId = testContact.Id
        ));
        testAssets.add(new Asset(
            AccountId = testAccount.Id
        ));
        insert testAssets;

        Test.startTest();
        
        List<Asset> assets = CX_LocationAndAssetsController.getAssets(testContact.Id);

        Test.stopTest();

        System.assertNotEquals(null, assets, 'Assets returned can not be null');
        System.assertEquals(2, assets.size(), 'Two assets are expected to be returned');
    }

    @isTest
    static void givenNullContactIdTestGetRelatedLocation () {
        Exception e;
        Test.startTest();
        
        try {
            List<Account> locations = CX_LocationAndAssetsController.getLocations(null);
        } catch (Exception ex) {
            e = ex;
        }

        Test.stopTest();

        System.assertNotEquals(null, e, 'Exception should have been thrown and not be null');
    }

    @isTest
    static void givenNullContactIdTestGetRelatedAssets () {
        Exception e;
        Test.startTest();
        
        try {        
            List<Asset> assets = CX_LocationAndAssetsController.getAssets(null);
        } catch (Exception ex) {
            e = ex;
        }

        Test.stopTest();

        System.assertNotEquals(null, e, 'Exception should have been thrown and not be null');
    }
}
@isTest
private class CX_CaseCreationControllerTest {

    @isTest
    static void givenCaseRecordTestCreatingWithoutRelationships () {

        Test.startTest();

        CX_CaseCreationController.createCase('case subject', 'Parts', null, null, null);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(1, cases.size(), 'There should exist one Case record');
    }
    
    @isTest
    static void givenCaseRecordContactLocationAndAssetsTestCaseCreationAndRelationships () {
        Contact ctc = new Contact (
            LastName = 'testCtc'
        );
        insert ctc;
        Account acc = new Account (
            Name = 'location acc test',
            RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId()
        );
        insert acc;
        List<Asset> assets = new List<Asset>();
        assets.add(new Asset(Model_Number__c = 'modelNum1'));
        assets.add(new Asset(Model_Number__c = 'modelNum2'));
        assets.add(new Asset(Model_Number__c = 'modelNum3'));
        insert assets;

        Test.startTest();

        CX_CaseCreationController.createCase('case subject', 'Parts', ctc.Id, acc, assets);

        Test.stopTest();

        List<Case> cases = [SELECT Id, ContactId, AccountId FROM Case];
        System.assertEquals(1, cases.size(), 'There should exist one Case record');
        System.assertEquals(ctc.Id, cases[0].ContactId, 'The Case should be related to the Contact created in the test');
        System.assertEquals(acc.Id, cases[0].AccountId, 'The Case should be related to the Location account created in the test');
        List<Case_Asset__c> caseAssets = [SELECT Id, Case__c, Asset__c FROM Case_Asset__c];
        System.assertEquals(3, caseAssets.size(), 'There should be 3 Assets related to the Case');
        Integer firstAssetMatches = 0;
        Integer secondAssetMatches = 0;
        Integer thirdAssetMatches = 0;
        for (Case_Asset__c asset : caseAssets) {
            System.assertEquals(cases[0].Id, asset.Case__c, 'The created Case_Asset__c records should all be related to the created Case');
            System.assert(asset.Asset__c == assets[0].Id || asset.Asset__c == assets[1].Id || asset.Asset__c == assets[2].Id, 'Case_Asset__c objects created should link to one of the GEA_Assets created');
            if (asset.Asset__c == assets[0].Id) {
                firstAssetMatches++;
            } else if (asset.Asset__c == assets[1].Id) {
                secondAssetMatches++;
            } else if (asset.Asset__c == assets[2].Id) {
                thirdAssetMatches++;
            }
        }
        System.assertEquals(1, firstAssetMatches, 'Each GEA Asset should only have one Case Asset created as junction');
        System.assertEquals(1, secondAssetMatches, 'Each GEA Asset should only have one Case Asset created as junction');
        System.assertEquals(1, thirdAssetMatches, 'Each GEA Asset should only have one Case Asset created as junction');
    }
}
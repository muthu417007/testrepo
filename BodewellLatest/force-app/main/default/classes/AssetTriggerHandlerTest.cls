@isTest
public class AssetTriggerHandlerTest {

    static testMethod void test1() {
        // Test data setup
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        List<String> assetString = new List<String>();
        assetString.add(assets[0].id);
        
        // Perform test

        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.outdoor_unit_model__c = '1U12TE1VHA';
        dfs_reg.outdoor_unit_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        List<Model_Rel__c> ModeRel = new List<Model_Rel__c>();
       Model_Rel__c m1 = new Model_Rel__c(MN__c = 'TESTMODEL1', MR_PKMOD__c='TESTMODEL1.1');
        Model_Rel__c m2 = new Model_Rel__c(MN__c = 'TESTMODEL2.1', MR_PKMOD__c='TESTMODEL2');
        ModeRel.add(m1);
        ModeRel.add(m2);
        insert ModeRel;
        
        List<Asset> assets2 = new List<Asset>();
        for(Integer i=0;i<2;i++) {
            Asset a = new Asset( model_number__c = 'TESTMODEL'+string.valueOf(i),accountid = accounts[0].id,OriginalModelNumber__c = 'TESTMODEL'+string.valueOf(i),
                                             installdate = date.today(),Ductless_product_registration__c = dfs_reg.ID);
            assets2.add(a);
        }
        insert assets2;
        
        Asset assets1 = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets1 ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets1.Id), assets1.DFS_Primary_Asset__c); 
        assets1.DFS_Primary_Asset__c = 'Outdoor 1';
        update assets1;       
        Asset a1 = new Asset( model_number__c = 'TESTMODEL3342',accountid = accounts[0].id,OriginalModelNumber__c = 'TESTMODEL3342',
                                             installdate = date.today());
        List<Asset> assets3 = new List<Asset>();
        assets3.add(a1);
        AssetUtility.validateModelNumber(assets3);
        Insert Assets3;
        Test.stopTest();
       
}
}
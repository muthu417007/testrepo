@isTest 
private class ConcessionRACall_test {
    static testMethod void test1() {
        Concession_Code__c cc = new Concession_Code__c();
        cc.Code__c = 'A14';
        cc.Description__c = 'Fault';
        insert cc;
        
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        account a = accounts[0];
        
        Contact con = [SELECT ID 
                      FROM Contact LIMIT 1];
        
        List<Asset> assets = TestDataFactory.createAssets(1, a);
        case case1 = TestDataFactory.createCase(con, assets[0]);
        
        Concession__c c = new Concession__c();
       
        c.Region__c = 25;
        c.Concession_Code_Desc__c = cc.id;
        c.zone__c = 09;
        c.CustDistrict__c = 81;
        c.CustCode__c = '57777';
        c.Case__c = case1.id;
        c.Concession_Location__c = a.id;
        
        insert c;
        
        List<String> test = new List<String>();
        test.add(c.id);
        List<String> result = ConcessionRACall.submit(test);
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
    
    static testMethod void test2() {
        Concession_Code__c cc = new Concession_Code__c();
        cc.Code__c = 'A14';
        cc.Description__c = 'Fault';
        insert cc;
        
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        account a = accounts[0];
        
        Contact con = [SELECT ID 
                      FROM Contact LIMIT 1];
        
        List<Asset> assets = TestDataFactory.createAssets(1, a);
        case case1 = TestDataFactory.createCase(con, assets[0]);
        
        
        Case_Asset__c caseAssetRecord = new Case_Asset__c();
        caseAssetRecord.name = 'test';
        caseAssetRecord.Case__c = case1.id;
        caseAssetRecord.Asset__c = assets[0].id;
        caseAssetRecord.Install_Date__c = date.today();
        caseAssetRecord.Serial_Number__c = '123';
        caseAssetRecord.In_Warranty_CaseAsset__c = 'no';
        caseAssetRecord.Model_Number__c = 'abc';
        caseAssetRecord.Age_Of_Product__c = 1;
        
        insert caseAssetRecord;
        
        Concession__c c = new Concession__c();
        c.Case_Asset__c = caseAssetRecord.id;
        c.Region__c = 25;
        c.Concession_Code_Desc__c = cc.id;
        c.zone__c = 09;
        c.CustDistrict__c = 81;
        c.CustCode__c = '57777';
        c.Case__c = case1.id;
        c.Concession_Location__c = a.id;
        c.ReplZip__c = '32137';
        
        insert c;
        
        List<String> test = new List<String>();
        test.add(c.id);
        List<String> result = ConcessionRACall.submit(test);
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
    
    
    
}
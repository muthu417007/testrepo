@isTest 
private class ConcessionBuyBackCall_test {
    static testMethod void test1() {
        /*Concession_Code__c cc = new Concession_Code__c();
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
        
        insert c;*/
        
        Concession__c c = testDataFactory.createConcession();
        
        
        List<String> test = new List<String>();
        test.add(c.id);
        List<String> result = ConcessionBuyBackCall.submit(test);
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
    
    static testMethod void test2() {
        
        Concession__c c = testDataFactory.createConcession();
        
        c.ReplZip__c = '32137';
        
        update c;
        
        List<String> test = new List<String>();
        test.add(c.id);
        List<String> result = ConcessionBuyBackCall.submit(test);
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
    
    static testMethod void test3() {
        //blank zone error
        Concession__c c = testDataFactory.createConcession();
        c = [SELECT Concession_Location__C 
            FROM Concession__c
            WHERE ID = :c.id LIMIT 1];
        Account a = [SELECT id,zone__c
                    FROM Account
                    WHERE id = :c.Concession_Location__C LIMIT 1];
        a.Zone__c = null;
        update a;
        
        List<String> test = new List<String>();
        test.add(c.id);
        List<String> result = ConcessionBuyBackCall.submit(test);
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
    
    static testMethod void test4() {
        //blank region error
        Concession__c c = testDataFactory.createConcession();
        c = [SELECT Concession_Location__C 
            FROM Concession__c
            WHERE ID = :c.id LIMIT 1];
        Account a = [SELECT id,region__c
                    FROM Account
                    WHERE id = :c.Concession_Location__C LIMIT 1];
        a.Region__c = null;
        update a;
        
        List<String> test = new List<String>();
        test.add(c.id);
        List<String> result = ConcessionBuyBackCall.submit(test);
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
    
        static testMethod void test5() {
        //blank CustDistrict__c error
        Concession__c c = testDataFactory.createConcession();
        c = [SELECT Concession_Location__C 
            FROM Concession__c
            WHERE ID = :c.id LIMIT 1];
        c.CustDistrict__c = null;
        update c;
        
        List<String> test = new List<String>();
        test.add(c.id);
        List<String> result = ConcessionBuyBackCall.submit(test);
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
    
    
    
}
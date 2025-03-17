@isTest
private class GEAAssetTriggerHandler_test {
    
  static testMethod void test1() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.outdoor_unit_model__c = '1U12TE1VHA';
        dfs_reg.outdoor_unit_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Outdoor 1';
        update assets;       
        Test.stopTest();   
        
    }
    
    static testMethod void test2() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_1_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_1_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 1';
        update assets;       
        Test.stopTest();   
        
    }
    
    static testMethod void test3() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_2_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_2_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 2';
        update assets;       
        Test.stopTest();
   
        
    }
    
    static testMethod void test4() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_3_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_3_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 3';
        update assets;       
        Test.stopTest();   
        
    }
    
    static testMethod void test5() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_4_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_4_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 4';
        update assets;       
        Test.stopTest();   
        
    }
    
    static testMethod void test6() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_5_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_5_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 5';
        update assets;       
        Test.stopTest();   
        
    }
    
    static testMethod void test7() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_6_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_6_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 6';
        update assets;       
        Test.stopTest();   
        
    }
    
    static testMethod void test8() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_7_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_7_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 7';
        update assets;       
        Test.stopTest();   
        
    }
    
    static testMethod void test9() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_8_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_8_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 8';
        update assets;       
        Test.stopTest();   
        
    }
    
    static testMethod void test10() {
        
        
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.indoor_unit_9_model__c = '1U12TE1VHA';
        dfs_reg.indoor_unit_9_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        
       
        Asset assets = new Asset(Ductless_product_registration__c = dfs_reg.ID);
        
        insert assets ;
        
        // Perform test
        Test.startTest();
        
        GEAAssetTriggerHandler.sendGEAAssetInfo(String.valueOf(dfs_reg.ID), String.valueOf(assets.Id), assets.DFS_Primary_Asset__c); 
        assets.DFS_Primary_Asset__c = 'Indoor 9';
        update assets;       
        Test.stopTest();   
        
    }
    
    
    
}
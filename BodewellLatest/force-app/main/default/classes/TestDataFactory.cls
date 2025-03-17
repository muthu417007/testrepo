@isTest
public class TestDataFactory {
    public static List<Account> createAccountsWithContacts(Integer numAccts, Integer numContactsPerAcct) {
        List<Account> accts = new List<Account>();
        List<GEA_AccountContactRelation__c> acr = new List<GEA_AccountContactRelation__c>();
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account();
            a.Name ='TestAccount' + i;
            a.BillingStreet = 'Test Street';
            a.BillingCity = 'AIEA';
            a.BillingState = 'HI';
            a.BillingPostalCode = '96701';
            a.Region__c = 125;
            a.Zone__c = '09';
            accts.add(a);
        }
        insert accts;
        
        List<Contact> cons= new List<Contact>();
        //SELECT Id, Contact__c, ID_Type__c, Identifier__c, PersonDetailID__c, Identifier2__c 
          //                                              FROM Contact_Information__c 
          //                                              where ID_Type__c = 'Ge Consumer Number'
          //                                              AND Contact__c = :conId]
        List<Contact_Information__c> ci = new List<Contact_Information__c>();
        
        
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            // For each account just inserted, add contacts
            for (Integer k=0;k<numContactsPerAcct;k++) {
                cons.add(new Contact(firstName='test', lastName = 'last'  + k, phone = '9986140140',Email = 'test@test.com',
                                       AccountId=acct.Id));
            }
        }
        
       
        insert cons;
        integer count = 1;
        for(Contact c: cons){
            count++;
            GEA_AccountContactRelation__c gea_acr = new GEA_AccountContactRelation__c();
            gea_acr.account__c = c.AccountId;
            gea_acr.Contact__c = c.id;
            acr.add(gea_acr);
            
            Contact_Information__c ciRec = new Contact_Information__c();
            ciRec.Contact__c = c.id;
            ciRec.ID_Type__c = 'Ge Consumer Number';
            
            ciRec.Identifier__c = string.valueOf(count);
            ci.add(ciRec);
        }
        
        insert acr;
        insert ci;
        
        return accts;
    }
    
    public static List<Asset> createAssets(Integer numAssets, Account acc) {
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c(); 
        dfs_reg.install_date__c = Date.newInstance(2016, 12, 9);
        dfs_reg.outdoor_unit_model__c = '1U12TE1VHA';
        dfs_reg.outdoor_unit_serial__c = '1U12TE1VHA';
        insert dfs_reg;
        List<Asset> assets = new List<Asset>();
        
        for(Integer i=0;i<numAssets;i++) {
            Asset a = new Asset( model_number__c = string.valueOf(i),accountid = acc.id,
                                             installdate = date.today(),Ductless_product_registration__c = dfs_reg.ID);
            assets .add(a);
        }
        
        
        insert assets ;
        

        return assets ;
    }
    
    public static Case createCase(Contact con, Asset asset) {
  
        Case c = new Case( subject = 'test case', contactID = con.id, origin = 'Phone' );
        insert c;
        //Case_Asset__c ca = new Case_Asset__c();
        //ca.Case__c = c.id;
        //ca.Assetid = asset.id;
        //ca.name = 'test';
        //ca.Serial_Number__c = '123';
        //ca.Model_Number__c = 'MWF';
        
        Case_Asset__c caseAssetRecord = new Case_Asset__c();
        caseAssetRecord.name = 'test';
        caseAssetRecord.Case__c = c.id;
        caseAssetRecord.Asset__c = asset.id;
        caseAssetRecord.Install_Date__c = date.today();
        caseAssetRecord.Serial_Number__c = '123';
        caseAssetRecord.In_Warranty_CaseAsset__c = 'no';
        caseAssetRecord.Model_Number__c = 'abc';
        caseAssetRecord.Age_Of_Product__c = 1;
        
        insert caseAssetRecord;
        //insert ca;
  
        return c ;
    }
    
    public static Concession__c createConcession() {
  
        Concession_Code__c cc = new Concession_Code__c();
        cc.Code__c = 'A14';
        cc.Description__c = 'Fault';
        cc.Concession_Account__c = '123-123';
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
        c.case_asset__c = caseAssetRecord.id;
        c.Region__c = 25;
        c.Concession_Code_Desc__c = cc.id;
        c.zone__c = 09;
        c.CustDistrict__c = 81;
        c.CustCode__c = '57777';
        c.Case__c = case1.id;
        c.Concession_Location__c = a.id;
        
        insert c;
        return c ;
    }
    
    
}
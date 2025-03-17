@isTest
public class Mya_ProductDetails_Test {
    //test class
    @isTest
    public static void Mya_ProductDetails_Test1()
    {
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert cont;
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';        
        User u1 = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
            ContactId=cont.Id);
        insert u1;
        
        User u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Marketing User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        
        
        //account creation
        Account a=new Account();
        a.Name='testName';
        a.BillingStreet='test street';
        a.BillingCity='test City';
        a.BillingState='OH';
        a.BillingPostalCode='12345';
        a.Country_Code__c='United States Of America';   
        insert a;        
       
        //GEA_AccountContactRelation__c  creation  
        GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
        contactLoc.Name='testName';  
        contactLoc.Account__c=a.Id;
        contactLoc.Contact__c=u1.ContactId;
        contactLoc.MYA_Included__c=true;
        contactLoc.Nick_Name__c='testName';
        insert contactLoc; 
        
        //Product 2 creation
        //Changes are part of CCOE-1213-(Product2 replaced by Model_Rel__c Object)-Yogesh Sharma/TCS/26.09.2022
        Product2 m1 = new Product2();
        m1.StockKeepingUnit='QFW150SSNWW1';
        m1.Name = 'QFW150SSNWW1';
        m1.Item_Number__c = 'QFW150SSNWW1';
        insert m1;
        
        //asset creation    
        Asset ast=new Asset();
        ast.AccountId=a.Id;
        ast.Model_Number__c='QFW150SSNWW1';
        ast.SerialNumber='SL87537HG6';
        ast.AssetNickname__c='testnick';
        insert ast;
        
        // Switch to the runtime context
        Test.startTest();  
        system.debug('mya product ');
        Mya_ProductDetails.isGeaProduct(ast.Id);
        // run as a different user to test security and rights
        System.runAs(u1) 
        {
            list<user> userList1=Mya_ProductDetails.MYA_GetAccountProduct(u1.Id);
            list<user> userList=Mya_ProductDetails.MYA_GetContactName(u1.Id);
            //Changes are part of CCOE-1213-(Product2 replaced by Model_Rel__c Object)-Yogesh Sharma/TCS/26.09.2022
            //Model_Rel__c modelNumber=Mya_ProductDetails.Mya_GetManufactureModel(ast.Model_Number__c);
            Product2 modelNumber=Mya_ProductDetails.Mya_GetManufactureModel(ast.Model_Number__c);
            Mya_ProductDetails.Mya_DeleteAsset(ast.Id);
            MYA_Configuration__mdt configs = Mya_ProductDetails.getmyaConfigs();
        }
        System.runAs(u2) 
        {
            list<user> userList1=Mya_ProductDetails.MYA_GetAccountProduct(u2.id);
            list<user> userList=Mya_ProductDetails.MYA_GetContactName(u2.id);
            //Changes are part of CCOE-1213-(Product2 replaced by Model_Rel__c Object)-Yogesh Sharma/TCS/26.09.2022
            //Model_Rel__c modelNumber=Mya_ProductDetails.Mya_GetManufactureModel(ast.Model_Number__c);
            Product2 modelNumber=Mya_ProductDetails.Mya_GetManufactureModel(ast.Model_Number__c);
            Mya_ProductDetails.Mya_DeleteAsset(ast.Id);            
            MYA_Configuration__mdt configs = Mya_ProductDetails.getmyaConfigs();
        }
        
        Test.stopTest();
        
    }
    
}
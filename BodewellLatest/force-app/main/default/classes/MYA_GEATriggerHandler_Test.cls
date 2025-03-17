@isTest
private class MYA_GEATriggerHandler_Test {

    @isTest
    static void test1() {
        
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
        
        GEA_Asset__c GeaAssetObj = new GEA_Asset__c();
      	GeaAssetObj.OriginalModelNumber__c = 'TEST123';
       	GeaAssetObj.Serial_Number__c = 'SLTEST123';
        GeaAssetObj.Install_Date__c = date.parse('07/07/2022');
      	GeaAssetObj.OwnershipStartedOn__c = date.parse('07/07/2022');
       	GeaAssetObj.DataSourceCode__c = 'TEST';
        GeaAssetObj.Account_Location__C = acc.Id;
       	GeaAssetObj.Owner_Contact__c = u1.ContactId;
       	//GeaAssetObj.MYA_Included__c = true; 
        insert GeaAssetObj;
    }
    
    @isTest
    static void test2() {
        
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
        
        Model_Rel__c modelRelObj = new Model_Rel__c();
        modelRelObj.MN__c = 'TEST123';
        modelRelObj.MR_PKMOD__c = 'TEST1234';
        insert modelRelObj;
        
        SMCModelCA__c smcModelObj = new SMCModelCA__c();
        smcModelObj.Brand_Code__c = 'TEST';
        smcModelObj.Product_Line_Code__c = '34';
        smcModelObj.Model_No__c = 'TEST';
        insert smcModelObj;
        
        GEA_Asset__c GeaAssetObj = new GEA_Asset__c();
      	GeaAssetObj.OriginalModelNumber__c = 'TEST123';
       	GeaAssetObj.Serial_Number__c = 'SLTEST123';
        GeaAssetObj.Install_Date__c = date.parse('07/07/2022');
      	GeaAssetObj.OwnershipStartedOn__c = date.parse('07/07/2022');
       	GeaAssetObj.DataSourceCode__c = 'TEST';
        GeaAssetObj.Account_Location__C = acc.Id;
       	GeaAssetObj.Owner_Contact__c = u1.ContactId;
       	//GeaAssetObj.MYA_Included__c = true;
        insert GeaAssetObj;
    }
    
    @isTest
    static void test3() {
        
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
        
        Model_Rel__c modelRelObj = new Model_Rel__c();
        modelRelObj.MN__c = 'TEST123';
        modelRelObj.MR_PKMOD__c = 'TEST1235';
        insert modelRelObj;
        
        SMCModelCA__c smcModelObj = new SMCModelCA__c();
        smcModelObj.Brand_Code__c = 'TEST';
        smcModelObj.Product_Line_Code__c = '34';
        smcModelObj.Model_No__c = 'TEST12';
        insert smcModelObj;
        
        GEA_Asset__c GeaAssetObj = new GEA_Asset__c();
      	GeaAssetObj.OriginalModelNumber__c = 'TEST1235';
       	GeaAssetObj.Serial_Number__c = 'SLTEST123';
        GeaAssetObj.Install_Date__c = date.parse('07/07/2022');
      	GeaAssetObj.OwnershipStartedOn__c = date.parse('07/07/2022');
       	GeaAssetObj.DataSourceCode__c = 'TEST';
        GeaAssetObj.Account_Location__C = acc.Id;
       	GeaAssetObj.Owner_Contact__c = u1.ContactId;
       	//GeaAssetObj.MYA_Included__c = true;
        insert GeaAssetObj;
    }
    
    @isTest
    static void test4() {
        
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
        
        Model_Rel__c modelRelObj = new Model_Rel__c();
        modelRelObj.MN__c = 'TEST222';
        modelRelObj.MR_PKMOD__c = 'TEST2';
        insert modelRelObj;
        
        SMCModelCA__c smcModelObj = new SMCModelCA__c();
        smcModelObj.Brand_Code__c = 'TEST';
        smcModelObj.Product_Line_Code__c = '34';
        smcModelObj.Model_No__c = 'TEST22';
        insert smcModelObj;
        
        GEA_Asset__c GeaAssetObj = new GEA_Asset__c();
      	GeaAssetObj.OriginalModelNumber__c = 'TEST2225';
       	GeaAssetObj.Serial_Number__c = 'SLTEST123';
        GeaAssetObj.Install_Date__c = date.parse('07/07/2022');
      	GeaAssetObj.OwnershipStartedOn__c = date.parse('07/07/2022');
       	GeaAssetObj.DataSourceCode__c = 'TEST';
        GeaAssetObj.Account_Location__C = acc.Id;
       	GeaAssetObj.Owner_Contact__c = u1.ContactId;
       	//GeaAssetObj.MYA_Included__c = true;
        insert GeaAssetObj;
    }
}
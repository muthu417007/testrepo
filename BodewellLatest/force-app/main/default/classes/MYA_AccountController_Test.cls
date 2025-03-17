@isTest
private class MYA_AccountController_Test {
    
	@isTest
    static void saveAssetsTest1() {  
        
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
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
        
		Asset geaAssetObj = new Asset();
      	geaAssetObj.OriginalModelNumber__c = 'TEST123';
       	geaAssetObj.SerialNumber = 'SLTEST123';
        geaAssetObj.InstallDate = date.parse('07/07/2022');
      	geaAssetObj.OwnershipStartedOn__c = date.parse('07/07/2022');
       	geaAssetObj.DataSourceCode__c = 'TEST';
        geaAssetObj.AccountId = acc.Id;
       	geaAssetObj.ContactId = u1.ContactId;
       	//geaAssetObj.MYA_Included__c = true;  
        insert geaAssetObj; 
        
        Test.startTest(); 
        
        System.runAs(u1) {
        	MYA_AccountController.SaveAssetResponse response1 = new MYA_AccountController.SaveAssetResponse();
            response1 = MYA_AccountController.saveAssets('TEST123', 'SLTEST', '07/07/2022', 'TEST', acc.Id, u1.ContactId, true);
            
            MYA_AccountController.SaveAssetResponse response2 = new MYA_AccountController.SaveAssetResponse();
            response2 = MYA_AccountController.saveAssets('TEST123', 'SLTEST', '700/40/2022', 'TEST', 'werwe', u1.ContactId, false);
            
            MYA_AccountController.SaveAssetResponse response3 = new MYA_AccountController.SaveAssetResponse();
            response3 = MYA_AccountController.saveAssets('TEST123', 'SLTEST123', '07/07/2022', 'TEST', acc.Id, u1.ContactId, false);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void saveAssetsTest2() {
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
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
        
        Test.startTest();  
        
        System.runAs(u1) {
        	MYA_AccountController.SaveAssetResponse response2 = new MYA_AccountController.SaveAssetResponse();
            response2 = MYA_AccountController.saveAssets('TEST123', 'SLTEST', '700/40/2022', 'TEST', 'werwe', u1.ContactId, false);
       	}
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void registerAssetsTest1() {
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
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
        
        Test.startTest();  
        
        System.runAs(u1) {
            MYA_AccountController.AssetRegisterInput assetInput = new MYA_AccountController.AssetRegisterInput();
            assetInput.SerialNumber = 'SLTEST';
            assetInput.ModelNumber = 'TEST123';
            assetInput.InstallationDate = '07/07/2022';
            
            MYA_AccountController.AssetRegisterAddressInput addressInput = new MYA_AccountController.AssetRegisterAddressInput();
            addressInput.Address1 = 'Test Address1';
            addressInput.City = 'Test City';
            addressInput.State = 'CA';
            addressInput.PostalCode = '123456';
            addressInput.Firstname = 'Test first name';
            addressInput.Lastname = 'Test last name';
            addressInput.Email = 'test@test.com';
            addressInput.Phone = '1234567890';
            
            String qrUrl = 'https://mya-appliances.cs44.force.com/GEA/s/mya-qrlanding-page?language=en_US&P=P&K=PSB42YSNSS&M=PSB42YSNSS&S=MV123&L=123&D=123';
        	MYA_AccountController.SaveAssetResponse response3 = new MYA_AccountController.SaveAssetResponse();
            response3 = MYA_AccountController.registerAssets(assetInput, addressInput, 'TEST', acc.Id, u1.ContactId, true, qrUrl);
       	}
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void registerAssetsTest2() {
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
        Test.startTest();  
        
        System.runAs(u1) {
            MYA_AccountController.AssetRegisterInput assetInput = new MYA_AccountController.AssetRegisterInput();
            assetInput.SerialNumber = 'SLTEST';
            assetInput.ModelNumber = 'TEST123';
            assetInput.InstallationDate = '700/700/2022';
            
            MYA_AccountController.AssetRegisterAddressInput addressInput = new MYA_AccountController.AssetRegisterAddressInput();
            addressInput.Address1 = 'Test Address1';
            addressInput.City = 'Test City';
            addressInput.State = 'CA';
            addressInput.PostalCode = '1234556';
            addressInput.Firstname = 'Test first name';
            addressInput.Lastname = 'Test last name';
            addressInput.Email = 'test@test.com';
            addressInput.Phone = '1234567890';
            
            String qrUrl = 'https://mya-appliances.cs44.force.com/GEA/s/mya-qrlanding-page?language=en_US&P=P&K=PSB42YSNSS&M=PSB42YSNSS&S=MV123&L=123&D=123';
        	MYA_AccountController.SaveAssetResponse response4 = new MYA_AccountController.SaveAssetResponse();
            response4 = MYA_AccountController.registerAssets(assetInput, addressInput, 'TEST', acc.Id, u1.ContactId, true, qrUrl);
       	}
        
        Test.stopTest();
		   			
     }
}
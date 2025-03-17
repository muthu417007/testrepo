@isTest
private class MYA_ProductRegistrationController_Test {
	@isTest
    static void getAccountInfoTest() { 
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
        
		Asset GeaAssetObj = new Asset();
      	GeaAssetObj.Model_Number__c = 'TEST123';
      	GeaAssetObj.SerialNumber = 'TESTSL';
     	GeaAssetObj.InstallDate = date.parse('07/07/2022');
        GeaAssetObj.DataSourceCode__c = 'DT';
       	GeaAssetObj.AccountId = acc.Id;
     	GeaAssetObj.ContactId = u1.ContactId;
     	GeaAssetObj.ModelValidityFlag__c = true;
   		//GeaAssetObj.MYA_Included__c = true;
    	insert GeaAssetObj;  
        
        MYA_ProductRegistrationController.AssetInput Input = new MYA_ProductRegistrationController.AssetInput();
        Input.ModelNumber = GeaAssetObj.Model_Number__c;
        Input.SerialNumber = GeaAssetObj.SerialNumber;
        
        MYA_ProductRegistrationController.AssetInput[] Inputs = new MYA_ProductRegistrationController.AssetInput[]{Input};
  
        
        Test.startTest();  
        
        System.runAs(u1) {
        	MYA_ProductRegistrationController.AccountInfoResponse response1 = new MYA_ProductRegistrationController.AccountInfoResponse();
            response1 = MYA_ProductRegistrationController.getAccountInfo(u1.Id); 
            
            MYA_ProductRegistrationController.AccountInfoResponse response2 = new MYA_ProductRegistrationController.AccountInfoResponse();
            response2 = MYA_ProductRegistrationController.getAccountInfo(u1.ContactId);
            
            MYA_ProductRegistrationController.ConsentVerificationResponse response3 = new MYA_ProductRegistrationController.ConsentVerificationResponse();
            response3 = MYA_ProductRegistrationController.userConsentVerification();
            
            MYA_ProductRegistrationController.CheckAssetExistingResponse response4 = new MYA_ProductRegistrationController.CheckAssetExistingResponse();
            response4 = MYA_ProductRegistrationController.checkAssets(Inputs, acc.Id);
            
            MYA_ProductRegistrationController.CheckAssetExistingResponse response5 = new MYA_ProductRegistrationController.CheckAssetExistingResponse();
            response5 = MYA_ProductRegistrationController.checkAssets(null, acc.Id);
        }
        
        Test.stopTest();
		   			
     }
}
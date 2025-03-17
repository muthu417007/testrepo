@isTest
private class MYA_ProductRegistrationConfig_Test {
	@isTest
    static void getProductRegistrationConfigTest() { 

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
        	MYA_ProductRegistrationConfig.ProductRegistrationConfigResponse response1 = new MYA_ProductRegistrationConfig.ProductRegistrationConfigResponse();
            response1 = MYA_ProductRegistrationConfig.getProductRegistrationConfig(true); 
            
            MYA_ProductRegistrationConfig.ProductRegistrationConfigResponse response2 = new MYA_ProductRegistrationConfig.ProductRegistrationConfigResponse();
            response2 = MYA_ProductRegistrationConfig.getProductRegistrationConfig(false); 
            
            String[] keys = new String[] {'PT916WMWW','PYE22PMKBES'};
            MYA_ProductRegistrationConfig.SMCConfigResponse response3 = new MYA_ProductRegistrationConfig.SMCConfigResponse();
            response3 = MYA_ProductRegistrationConfig.getSMCData(keys);
            
            String[] errorKey = new String[] {'P'};
            MYA_ProductRegistrationConfig.SMCConfigResponse response4 = new MYA_ProductRegistrationConfig.SMCConfigResponse();
            response4 = MYA_ProductRegistrationConfig.getSMCData(errorKey);
        }
        
        Test.stopTest();
		   			
     }
}
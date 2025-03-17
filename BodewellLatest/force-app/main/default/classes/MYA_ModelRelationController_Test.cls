@isTest
private class MYA_ModelRelationController_Test {
	@isTest
    static void searchModelNumberTest() { 

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
        	List<Model_Rel__c> response1 = MYA_ModelRelationController.searchModelNumber('TBX14');
            List<Model_Rel__c> response2 = MYA_ModelRelationController.searchModelNumber('%');
       	}
        
        Test.stopTest();
		   			
     }
}
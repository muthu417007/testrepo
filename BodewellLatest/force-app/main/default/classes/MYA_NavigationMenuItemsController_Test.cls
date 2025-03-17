@isTest
private class MYA_NavigationMenuItemsController_Test {
	@isTest
    static void getNavigationMenuItemsTest1() { 
        
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
        	List<NavigationMenuItem> response1 = MYA_NavigationMenuItemsController.getNavigationMenuItems('Test Menu','Draft');
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void getNavigationMenuItemsTest2() { 
        
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
        	List<NavigationMenuItem> response1 = MYA_NavigationMenuItemsController.getNavigationMenuItems(null,null);
        }
        
        Test.stopTest();
		   			
     }
}
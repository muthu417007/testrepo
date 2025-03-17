@isTest
public class SearchInVFController_test {
   @isTest 
    private static void testVFController(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TAG'];
        User testUser3 = new User(Alias = 'newUser', FirstName='test',FederationIdentifier='2140067579',IsActive=True,SSO_ID__c='2140067579',Email='Test1@gmail.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'Test1243test@gmail.com');
        
        insert testUser3;
        
        string searchkey='Test1@gmail.com';
        string searchkey4='';
       	list<User>usr=new list<user>();
        string s ='SELECT FirstName,LastName,Name,Email,FederationIdentifier,IsActive,ProfileId,SSO_ID__c,Username, Profile.UserLicense.Name FROM User where Email like  \'%' + String.escapeSingleQuotes(searchKey) + '%\'  ';
		 Usr=Database.query(s);
        Test.startTest();
        SearchInVFController controller= new SearchInVFController();
        if(searchkey!=null){
        controller.searchUser();
        }
        if(Usr.size()>0){
            controller.clear();}
        Test.stopTest();
        //system.assertEquals(Usr.size(), 1);
        
        
    }
  

}
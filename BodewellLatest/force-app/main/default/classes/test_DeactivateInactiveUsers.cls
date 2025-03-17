@isTest
public class test_DeactivateInactiveUsers {

    @isTest public static void testdeactivate(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TAG'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@testDeactivateUser.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@testDeactivateUser.com');
        
        Database.SaveResult userInsertResult = Database.insert(testUser);
        
        test.startTest();
        DeactivateInactiveUser.deactivate();
        test.stopTest();
        
        User assertUser = [Select Id, UserName, IsActive 
                         From User Where id= :testUser.id][0];
      
      	System.assertEquals(false, assertUser.IsActive);
        
    }


}
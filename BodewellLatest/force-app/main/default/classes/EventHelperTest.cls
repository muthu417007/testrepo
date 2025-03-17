@isTest
public class EventHelperTest {
    @isTest 
    public static void BulkTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser;
         
        Id userId = testuser.Id; 
         
        list<event> events=new list<event>();
        for(integer i=0;i<1000;i++){
        Event e = new Event();
        
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.ownerId=userId;
        e.subject='test';
        events.add(e);
        }
        insert events;
        
        
        Test.startTest(); 
        system.runas(testuser){
			try
			{
				delete  events;       
			}
			catch(Exception ex)
			{
				Boolean expectedExceptionThrown =  ex.getMessage().contains('You Do not have the Permission to Delete the Event') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);                
			}
		Test.stopTest();  
    }
    }
     @isTest 
    public static void NegativeTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TAG'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser;
         
        Id userId = testuser.Id; 
         
        list<event> events=new list<event>();
        Event e = new Event();
        
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.ownerId=userId;
        e.subject='test';
        insert e;
         events.add(e);
        
        
        Test.startTest(); 
        system.runas(testuser){
			try
			{
				delete  e;       
			}
			catch(Exception ex)
			{
				Boolean expectedExceptionThrown =  ex.getMessage().contains('You Do not have the Permission to Delete the Event') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);                
			}
		Test.stopTest();  
    }
    }
     @isTest 
    public static void PositiveTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser;
         
        Id userId = testuser.Id; 
         
        list<event> events=new list<event>();
        Event e = new Event();
        
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.ownerId=userId;
        e.subject='test';
        insert e;
         events.add(e);
        
        
        Test.startTest(); 
        system.runas(testuser){
			try
			{
				delete  e;       
			}
			catch(Exception ex)
			{
				Boolean expectedExceptionThrown =  ex.getMessage().contains('You Do not have the Permission to Delete the Event') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);                
			}
		Test.stopTest();  
    }
    }
    }
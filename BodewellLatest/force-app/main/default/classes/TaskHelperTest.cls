@isTest
public class TaskHelperTest{
    @isTest 
    public static void BulkTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser;
         
        Id userId = testuser.Id; 
        
         list<task> Tasklist=new list<task>();
        for(Integer i=0;i<1000;i++){
        task t=new task();
         
         t.Subject='Message Sent';
         t.status='Complete'; 
         t.priority='Normal';
         //t.WhoId= userId;
         t.ownerId=userId;
         Tasklist.add(t);
        }
        
        insert Tasklist;
        

        Test.startTest();
        system.runas(testuser){
        try{
            delete Tasklist;
             
        }catch(DMLException ex){
             Boolean expectedExceptionThrown =  ex.getMessage().contains('You Do not have the Permission to Delete the Task') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
        }
        }
        Test.stopTest();
        
    }
     @isTest 
    public static void NegativeTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TAG'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser;
         
        Id userId = testuser.Id; 
        // list<task> Tasklist=new list<task>();
        task t=new task();
         
         t.Subject='Message Sent';
         t.status='Complete'; 
         t.priority='Normal';
         //t.WhoId= userId;
         t.ownerId=userId;
        
        insert t;
        //Tasklist.add(t);

        Test.startTest();
        system.runas(testuser){
        try{
            delete t;
             
        }catch(DMLException ex){
             Boolean expectedExceptionThrown =  ex.getMessage().contains('You Do not have the Permission to Delete the Task') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
        }
        }
        Test.stopTest();
        
    }
    @isTest 
    public static void positiveTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser;
         
        Id userId = testuser.Id; 
        // list<task> Tasklist=new list<task>();
        task t=new task();
         
         t.Subject='Message Sent';
         t.status='Complete'; 
         t.priority='Normal';
         //t.WhoId= userId;
         t.ownerId=userId;
        
        insert t;
        //Tasklist.add(t);

        Test.startTest();
        system.runas(testuser){
        try{
            delete t;
             
        }catch(DMLException ex){
             Boolean expectedExceptionThrown =  ex.getMessage().contains('You Do not have the Permission to Delete the Task') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
        }
        }
        Test.stopTest();
        
    }
}
@isTest
public class EmailHelperTest {
     @isTest(SeeAllData=True) 
    public static void bulkTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser;
         
        Id userId = testuser.Id;
             
        list<EmailMessage> emails=new list<EmailMessage>();
        for( Integer e1=0;e1<1000;e1++)
        {
        EmailMessage e = new EmailMessage();
        e.FromAddress='nalinig@gmail.com';
        e.subject='test';
        e.ToAddress='ttt@gmail.com';
        e.TextBody = '23456 ';
         emails.add(e);
        }
        
       // e.parentId=c.Id;
        insert emails;
        Test.startTest(); 
        system.runas(testuser){
            try
            {
                delete  emails;       
            }
            catch(Exception ex)
            {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('You Do not have necessary Permission to Delete the Email') ? true : false;
                System.assertEquals(expectedExceptionThrown, true) ;                
                
                //System.Assert(ex.getMessage().contains('You Do not have the Permission to Delete the Email'));
            }
            
           // HelperDeleteEmail.NoDeleteEmail(events);
        }
        Test.stopTest(); 
    
    }
     @isTest 
    public static void positiveTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser1 = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser1;
         
        Id userId = testuser1.Id;
             
        list<EmailMessage>emails=new list<EmailMessage>();
        EmailMessage e = new EmailMessage();
        e.FromAddress='nalinig@gmail.com';
        e.subject='test';
        e.ToAddress='ttt@gmail.com';
        e.TextBody = '23456 ';
        
       // e.parentId=c.Id;
        insert e;
        emails.add(e);
        
        
        Test.startTest(); 
        system.runas(testuser1){
            try
            {
                delete  e;       
            }
            catch(Exception ex)
            {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('You Do not have necessary Permission to Delete the Email') ? true : false;
                System.assertEquals(expectedExceptionThrown, true) ;
                //System.Assert(ex.getMessage().contains('You Do not have the Permission to Delete the Email'));
            }
            
           // HelperDeleteEmail.NoDeleteEmail(events);
        }
        Test.stopTest(); 
    
    }
    @isTest 
    public static void negativeTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'IT'];
        User testUser1 = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser1;
         
        Id userId = testuser1.Id;
             
        list<EmailMessage>emails=new list<EmailMessage>();
        EmailMessage e = new EmailMessage();
        e.FromAddress='nalinig@gmail.com';
        e.subject='test';
        e.ToAddress='ttt@gmail.com';
        e.TextBody = '23456 ';
        
       // e.parentId=c.Id;
        insert e;
        emails.add(e);
        
        
        Test.startTest(); 
        system.runas(testuser1){
            try
            {
                delete  e;       
            }
            catch(Exception ex)
            {
                Boolean expectedExceptionThrown =  ex.getMessage()!=NULL? true : false;
                system.debug(ex.getMessage());
                System.assertEquals(expectedExceptionThrown, true) ;
            }
            
           // HelperDeleteEmail.NoDeleteEmail(events);
        }
        Test.stopTest(); 
    
    }
}
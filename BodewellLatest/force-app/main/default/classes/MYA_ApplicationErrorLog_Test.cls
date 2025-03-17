@isTest
private class MYA_ApplicationErrorLog_Test {
    private class MyException extends Exception {}
	@isTest
    static void ErrorLogTest() {
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
        	Boolean response1 = MYA_ApplicationErrorLog.ErrorLog(
                '400', 
                'Test Message', 
                'Test class', 
                'Test function', 
                'TEST123', 
                'SLTEST', 
                '07/07/2022', 
                'TEST Name', 
                'TEST Lastname', 
                'test@test.com', 
                '1234567890', 
                'Test Street', 
                'Test City', 
                'Test State',
                'TEST'
            );
            
            Boolean response2 = MYA_ApplicationErrorLog.ErrorLog(
                '400', 
                'Test Message', 
                'Test class', 
                'Test function', 
                'TEST123', 
                'SLTEST',
                '2022/07/07', 
                'TEST Name', 
                'TEST Lastname', 
                'test@test.com', 
                '12345', 
                'Test Street', 
                'Test City', 
                'Test State',
                'TEST'
            );
            
            MyException e = new MyException();            
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Test class', 'Test function');
            
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Test class', 'Test function');
            
            MYA_ApplicationErrorLog.Mya_CustomExHandler('Test info', 'Test class', 'Test function');
        }
        
        Test.stopTest();
    }
}
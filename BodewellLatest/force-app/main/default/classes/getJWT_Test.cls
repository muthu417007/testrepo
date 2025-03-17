@isTest
private class getJWT_Test {

    @isTest
    static void generateJWTTokenTest() { 
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
        	String token = getJWT.generateJWTToken('GETJWTTEST', 'requestType', 120, 'This is a test jwt');
            System.assert(token != Null);
        }
        
        Test.stopTest();
    }
}
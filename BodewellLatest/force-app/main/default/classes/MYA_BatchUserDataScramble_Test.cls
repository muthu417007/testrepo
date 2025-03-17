/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        23.09.2022
 * @description    For user data scramble batch apex test
 */
@isTest 
public class MYA_BatchUserDataScramble_Test {
    //First test method
    @isTest
    static void testBatchUserDataScramble() 
    {
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
            IsActive=false,
            ContactId=cont.Id);
        insert u1;
        
        Test.startTest();

            MYA_BatchUserDataScramble obj = new MYA_BatchUserDataScramble();
            dataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}
@isTest
public class MYA_CR_Cases_Test {
    @isTest
    static void CaselistTest() { 
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Account acc = new Account (Name = 'newAcc1');
        insert acc;
        Contact c = new Contact(AccountId = acc.id,LastName='Das');
        insert c;
        String uniqueUserName = 'baishali' + DateTime.now().getTime() + '@testorg.com';
        User usr = new User(Alias = 'standt', Email='baishali.das@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Das', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,ContactId = c.Id);
        insert usr;
        Test.startTest(); 
        System.runAs(usr){           
            try{
                MYA_CR_Cases.getCaseList();
           	} catch(exception e){
                
            }
        }
        Test.stopTest();
      }
   
}
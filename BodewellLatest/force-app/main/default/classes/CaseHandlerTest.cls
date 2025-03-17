@isTest
public class CaseHandlerTest{
    static testmethod void ValidateCasePhNum()
    {   
        Profile prof = [select Id from profile where name LIKE '%System Administrator%'];
        User user = new User();
        user.firstName = 'Abc';
        user.lastName = 'xyz';
        user.Alias = 'abcbc';
        user.profileId = prof.id;
        user.username = 'abcabc.xyz@test.com';
        user.email = 'test@test.com';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        insert user;                        
        
        Account accObj = new Account(Name='Test Account');
        insert accObj;
        
        
        list<case> clist=new List<case>();
        
        Case caseObj = new Case();
        if(accObj != NULL)
        {
            caseObj.AccountId = accObj.Id;
            caseObj.Origin = 'Phone';
            caseObj.OwnerId = User.Id; 
            caseObj.Phone_Number__c='1232432432*';
            caseObj.Alternative_Phone_Number__c='3435435*';
            insert caseObj;            
        }
        
        CaseHandler.phNum(clist);
        CaseHandler.AltphNum(clist);
        
        
       
    }                
}
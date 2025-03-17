/**
*@description : Class has been created to test 'MYA_BatchPortalUserFlag' Functionality created for MYA project.
Name: Kanishtika Gupta
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
Task :- IDMSF-1634
**********************************************
Purpose: Class has been created to test 'MYA_BatchPortalUserFlag' Functionality created for MYA project.
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 21/09/2022   Created
**********************************************
**********************************************/
@isTest
public class MYA_BatchPortalUserFlag_Test {
  @isTest
    static void mya_BatchPortalUserFlag(){
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Account acc = new Account (Name = 'testuser-account1');
        insert acc;
        Contact c = new Contact(AccountId = acc.id,LastName='Gupta',Is_Portal_User__c = false);
        insert c;
        String uniqueUserName = 'kanishtika' + DateTime.now().getTime() + '@testorg.com';
        User usr = new User(Alias = 'standt', Email='kanishtika.gupta@gmail.com',
        EmailEncodingKey='UTF-8', LastName='Gupta', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,ContactId = c.Id);
        insert usr;
        System.runAs(usr){  
           Test.startTest();
                MYA_BatchPortalUserFlag pf = new MYA_BatchPortalUserFlag();
                Database.executeBatch(pf,200);
           Test.stopTest();
         Contact con = [select id,Is_Portal_User__c from contact where id =:c.id];
         system.assertEquals(true, con.Is_Portal_User__c,'Portal User Flag should true');
     }
    }
 }
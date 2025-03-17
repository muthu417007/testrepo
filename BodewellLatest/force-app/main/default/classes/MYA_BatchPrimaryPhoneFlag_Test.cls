/**
*@description : Class has been created to test 'MYA_BatchPrimaryPhoneFlag' Functionality created for MYA project.
Name: Kanishtika Gupta
Copyright: @ 2022 GE Appliances
**********************************************
Req: 

**********************************************
Purpose: Class has been created to test 'MYA_BatchPrimaryPhoneFlag' Functionality created for MYA project.
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 22/09/2022   Created
**********************************************
**********************************************/
@isTest
public class MYA_BatchPrimaryPhoneFlag_Test {
  @isTest
    static void mya_BatchPrimaryPhoneFlag(){
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Account acc = new Account (Name = 'testuser-account');
        insert acc;
        Contact c = new Contact(AccountId = acc.id,LastName='Gupta',Phone_is_Primary__c = false,Phone='8736477867');
        insert c;
        String uniqueUserName = 'kanishtika' + DateTime.now().getTime() + '@testorg.com';
        User usr = new User(Alias = 'standt', Email='kanishtika.gupta@gmail.com',
        EmailEncodingKey='UTF-8', LastName='Gupta', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,ContactId = c.Id);
        insert usr;
        System.runAs(usr){  
           Test.startTest();
                MYA_BatchPrimaryPhoneFlag primaryflag = new MYA_BatchPrimaryPhoneFlag();
                Database.executeBatch(primaryflag,200);
           Test.stopTest();
         Contact con = [select id,Phone_is_Primary__c from contact where id =:c.id];
         system.assertEquals(true, con.Phone_is_Primary__c,'Primary Phone Flag should true');
     }
    }
 }
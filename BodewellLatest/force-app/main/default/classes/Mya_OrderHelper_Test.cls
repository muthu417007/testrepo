//******************************************************************************************
//Name : Mya_OrderHelper_Test
//Requirement : To Test Mya_OrderHelper Class
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//  Version		Author				Date		        Detail
//  1.0			Yogesh Sharma		07/11/2022			Initial
//******************************************************************************************
//@description : Test Class  to Test Mya_OrderHelper Class
@isTest
Private class Mya_OrderHelper_Test {
    //@description : To Test Mya_OrderHelper
    @isTest
    static void Mya_OrderHelper_Test() {

        //Profile p = [select Id from profile where name='Default Customer Login User'];
        //User U1=[select Id,Name,ContactId from user where profileid=:p.Id Limit 1];
        
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


        System.runAs(u1){
            List<Contact> con =  Mya_OrderHelper.getContact(u1.Id);
            MYA_Configuration__mdt details = Mya_OrderHelper.getURL();
            User u = Mya_OrderHelper.getUser(u1.ContactId);
        }
    }
}
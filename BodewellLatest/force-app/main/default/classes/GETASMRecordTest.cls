@isTest
public class GETASMRecordTest {
	
     public static testmethod void getAsmRecordUser(){
         User adminUser = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
         System.runAs(adminUser){
                User asmuser=new User(
                ProfileId= [Select Id from Profile where Name='System Administrator'].Id,
                LastName='Test User',
                UserRoleId = [SELECT Id
                    FROM UserRole
                    WHERE PortalType = 'None'
                    LIMIT 1 ].Id,
            
                Email='santhosh.kanne@geappliances.com',
                CompanyName='Test',
                Username='test@test.com.test245',
                Title='title',
                Alias='alias',
                //UserRoleId = [SELECT Id FROM UserRole WHERE Name ='CEO' ].Id,
                TimeZoneSidKey='America/Los_Angeles',
                EmailEncodingKey='UTF-8',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US'
                );
                insert asmuser;
                
             	Account acc=new Account(
                Name='Test Distributor',
                RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Air and Water').getRecordTypeId() ,
                Phone= '01123123',
                ASM_Name__c=asmuser.Id,
                OwnerId=asmuser.Id
             );
             insert acc;
             Contact cnt=new Contact(
                 AccountId=acc.Id,
                 FirstName='TestUser',
                 LastName='Test',
                 Email='test@test.com',
                 RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Air and Water Distributor').getRecordTypeId()
        
             );
             insert cnt;
             
            User portaluser=new User(
        	ProfileId= [Select Id from Profile where Name='Default Customer Login User'].Id,
            LastName='Test User',
            Email='santhosh.kanne@geappliances.com',
            CompanyName='Test',
            Username='test@test.com.test',
            Title='title',
            Alias='alias',
            TimeZoneSidKey='America/Los_Angeles',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ContactId=cnt.Id
        );
        insert portaluser;
        Test.startTest();
        User res=GetASMRecord.getASMRecordDetails(portaluser.Id);
        system.assertNotEquals(null, res);
           
        String accdata=GetASMRecord.getAccountAndContactData(portaluser.Id);
        system.assertNotEquals(null, accdata);
        Test.stopTest();
             
         }
         
    }
    
    public static testmethod void generateUserPassword(){
        User userrec=new User(
        	ProfileId= [Select Id from Profile where Name='System Administrator'].Id,
            LastName='Test User',
            Email='santhosh.kanne@geappliances.com',
            CompanyName='Test',
            Username='test@test.com.test2412',
            Title='title',
            Alias='alias',
            TimeZoneSidKey='America/Los_Angeles',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US'
        );
        insert userrec;
        Test.startTest();
        GenerateUserPassword.userResetPassword(new List<Id>{userrec.Id});
        Test.stopTest();
        
        
    }
}
@isTest
private class MYA_UserDetailsController_Test {

    private class Mya_updateEmailApiResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('Success');
            res.setStatusCode(200);
            return res;
            }
    }
    
    @isTest
    static void getUserDetailsTest() { 

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
        	List<User> response1 = MYA_UserDetailsController.getUserDetails(u1.Id);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void getContactDetailsTest() { 

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
        	List<Contact> response1 = MYA_UserDetailsController.getContactDetails(u1.ContactId);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void getContactPointByContactIdTest() { 

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
        
        Contact_Point__c ContactPointObj = new Contact_Point__c();
        ContactPointObj.Contact__c = u1.ContactId;
        ContactPointObj.Phone__c = '1122334455';
        ContactPointObj.MYA_Included__c = true;
        ContactPointObj.MYAISPrimary__c = true;
        insert ContactPointObj;
        
        Contact_Point__c ContactPointObj1 = new Contact_Point__c();
        ContactPointObj1.Contact__c = u1.ContactId;
        ContactPointObj1.Phone__c = '1122334455';
        ContactPointObj1.MYA_Included__c = true;
        ContactPointObj1.MYAISPrimary__c = false;
        insert ContactPointObj1;
        
        Test.startTest();  
        
        System.runAs(u1) {
        	List<Contact_Point__c> response1 = MYA_UserDetailsController.getContactPointByContactId(u1.ContactId);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void createContactTest() { 

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
        
        Contact_Point__c ContactPointObj = new Contact_Point__c();
        ContactPointObj.Contact__c = u1.ContactId;
        ContactPointObj.Phone__c = '1122334455';
        ContactPointObj.MYA_Included__c = true;
        ContactPointObj.MYAISPrimary__c = false;
        insert ContactPointObj;
        
        Contact_Point__c ContactPointObj1 = new Contact_Point__c();
        ContactPointObj1.Contact__c = u1.ContactId;
        ContactPointObj1.Phone__c = '1122334456';
        ContactPointObj1.MYA_Included__c = true;
        ContactPointObj1.MYAISPrimary__c = false;
        insert ContactPointObj1;
        
        Contact_Point__c ContactPointObj2 = new Contact_Point__c();
        ContactPointObj2.Contact__c = u1.ContactId;
        ContactPointObj2.Phone__c = '1122334457';
        ContactPointObj2.MYA_Included__c = true;
        ContactPointObj2.MYAISPrimary__c = false;
        ContactPointObj2.MYA_IsDeleted__c = true;
        insert ContactPointObj2;
        
        Test.startTest();  
        
        System.runAs(u1) {
        	Contact_Point__c response1 = MYA_UserDetailsController.createContact(u1.ContactId, '1122334457', true);
            Contact_Point__c response2 = MYA_UserDetailsController.createContact(u1.ContactId, '9977886655', true);
            Contact_Point__c response3 = MYA_UserDetailsController.createContact(u1.ContactId, '1122334457', false);
            Contact_Point__c response4 = MYA_UserDetailsController.createContact(u1.ContactId, '9977886658', false);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void setPrimaryOnDeleteTest() { 

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
        
        Contact_Point__c ContactPointObj = new Contact_Point__c();
        ContactPointObj.Contact__c = u1.ContactId;
        ContactPointObj.Phone__c = '1122334455';
        ContactPointObj.MYA_Included__c = true;
        ContactPointObj.MYAISPrimary__c = false;
        insert ContactPointObj;
        
        Contact_Point__c ContactPointObj1 = new Contact_Point__c();
        ContactPointObj1.Contact__c = u1.ContactId;
        ContactPointObj1.Phone__c = '1122334455';
        ContactPointObj1.MYA_Included__c = true;
        ContactPointObj1.MYAISPrimary__c = false;
        insert ContactPointObj1;
        
        Test.startTest();  
        
        System.runAs(u1) {
        	List<Contact_Point__c> response1 = MYA_UserDetailsController.setPrimaryOnDelete(u1.ContactId);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void setPrimaryOnCreateTest() { 

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
        
        Contact_Point__c ContactPointObj = new Contact_Point__c();
        ContactPointObj.Contact__c = u1.ContactId;
        ContactPointObj.Phone__c = '1122334455';
        ContactPointObj.MYA_Included__c = true;
        ContactPointObj.MYAISPrimary__c = true;
        insert ContactPointObj;
        
        Contact_Point__c ContactPointObj1 = new Contact_Point__c();
        ContactPointObj1.Contact__c = u1.ContactId;
        ContactPointObj1.Phone__c = '1122334455';
        ContactPointObj1.MYA_Included__c = true;
        ContactPointObj1.MYAISPrimary__c = true;
        insert ContactPointObj1;
        
        Test.startTest();  
        
        System.runAs(u1) {
        	//List<Contact_Point__c> response1 = MYA_UserDetailsController.setPrimaryOnCreate(u1.ContactId, ContactPointObj.Id);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void getContactDetailsByUserIdTest() { 

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
        	List<Contact> response1 = MYA_UserDetailsController.getContactDetailsByUserId();
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void getContactPointByUserIdTest() { 

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
        
        Contact_Point__c ContactPointObj = new Contact_Point__c();
        ContactPointObj.Contact__c = u1.ContactId;
        ContactPointObj.Phone__c = '1122334455';
        ContactPointObj.MYA_Included__c = true;
        ContactPointObj.MYAISPrimary__c = true;
        insert ContactPointObj;
        
        Contact_Point__c ContactPointObj1 = new Contact_Point__c();
        ContactPointObj1.Contact__c = u1.ContactId;
        ContactPointObj1.Phone__c = '1122334455';
        ContactPointObj1.MYA_Included__c = true;
        ContactPointObj1.MYAISPrimary__c = false;
        insert ContactPointObj1;
        
        Test.startTest();  
        
        System.runAs(u1) {
        	List<Contact_Point__c> response1 = MYA_UserDetailsController.getContactPointByUserId();
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void updateEmailTest() { 

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
            Test.setMock(HttpCalloutMock.class, new Mya_updateEmailApiResponseGenerator());
        	MYA_UserDetailsController.EmailUpdateResponse response1 = MYA_UserDetailsController.updateEmail(u1.ContactId, 'test1@test.com');
            System.assertEquals(response1.Success, true);
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    static void sendEmailVerification_Test() { 

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
        
        Network network = new Network(
                Id = '0DBRM000000015i',
                VerificationEmailTemplateId = '00XRM000000hxnG'
        );
        
        Test.startTest();
        System.runAs(u1) {
        	Boolean response1 = MYA_UserDetailsController.sendEmailVerification(u1.Id, 'GEA', 'test.com');
            System.assertEquals(response1, true);
        }        
        Test.stopTest();		   			
     }
}
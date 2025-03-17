@isTest
public class CX_CN1CustomerNumberWrapperTest {
    
    private static final RecordTypeInfo ACCOUNT_LOCATION_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');
    //private static final RecordTypeInfo PERSON_ACCOUNT_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person Account');
    private static final Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    @isTest
    static void testPreparePayload() {
        // Create test data (Contact, Account, User)
        
        Account testPAAcc = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john.doe@example.com',
            Phone = '1234567890',
            RecordTypeId = acctRecordTypeId
        );
        
        insert testPAAcc;
        
        
        Account accLocation = new Account(Name = 'Test2', BillingPostalCode = '10117', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        
        
        insert accLocation;
        
       		Id conId = [SELECT Id FROM CONTACT WHERE AccountId = :testPAAcc.id Limit 1].Id;   
        	
        	Profile profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User'];
        
        	User testUser = new User(
            ProfileId = profile.Id,
            LastName = 'tuser',
            Username = 'testuser@example.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            SSO_ID__c = '12345',
            contactId = conId
        );
        insert testUser;
        // Call the method to be tested
        CX_CN1CustomerNumberWrapper.Request result = CX_CN1CustomerNumberWrapper.preparePayload(testPAAcc, accLocation, testUser);
        
    
    }
}
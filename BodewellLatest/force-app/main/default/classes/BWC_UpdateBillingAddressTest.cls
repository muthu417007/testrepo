@isTest
public class BWC_UpdateBillingAddressTest {
    @testSetup static void setup() {
        
        Id p = [SELECT Id
                FROM Profile 	
                WHERE Name='Bodewell Commerce D2C Login User'].Id;
        
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        User userWithRole = new User(alias = 'hasrole', 
                                     email='userwithrole@roletest.com', 
                                     userroleid = r.id,
                                     emailencodingkey='UTF-8',
                                     lastname='Testing',
                                     languagelocalekey='en_US', 
                                     localesidkey='en_US',
                                     profileid = UserInfo.getProfileId(), 
                                     timezonesidkey='America/Los_Angeles',
                                     username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account ac;
        System.runAs(userWithRole){
            
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            ac= new Account(
                RecordTypeID=recordTypeId ,
                FirstName='Test FName',
                LastName='Test LName',
                PersonMailingStreet='test@yahoo.com',
                PersonMailingPostalCode='12345',
                PersonMailingCity='SFO',
                PersonEmail='test@yahoo.com',
                PersonHomePhone='1234567',
                PersonMobilePhone='12345678',
                EBS_X_PARTY_ID__pc='123',
                EBS_X_CUST_ACCOUNT_ID__pc='1234'
            );
            
            insert ac;
        }
        
        Account acc = [SELECT PersonContactId 
                       FROM Account 
                       WHERE Id = :ac.Id];
        
        
        User user = new User(alias = 'demo',
                             email='demo123@noemail.com',
                             emailencodingkey='UTF-8',
                             lastname='demo',
                             languagelocalekey='en_US',
                             localesidkey='en_US',
                             profileid = p,
                             country='United States',
                             IsActive =true,
                             ContactId = acc.PersonContactId,
                             timezonesidkey='America/Los_Angeles',
                             username='demo@noemail.com');
        insert user;
        
    }
    @isTest
    static void testGetADC_Details() {
        User u = [SELECT Id,
                  AccountId
                  FROM User
                  WHERE alias = 'demo'
                  LIMIT 1];
        ContactPointAddress conPointAddress1 = new ContactPointAddress(Name = 'test',
                                                                       city = 'Green Bay',
                                                                       country = 'US',
                                                                       street = 'TestS Street',
                                                                       state = 'test State',
                                                                       PostalCode = '123',
                                                                       AddressType = 'Billing',
                                                                       ParentId = u.AccountId,
                                                                       IsDefault = True);
        insert conPointAddress1;
        
        ContactPointAddress conPointAddress2 = new ContactPointAddress(Name = 'test1',
                                                                       city = 'Green Bay',
                                                                       country = 'US',
                                                                       street = 'TestS Street',
                                                                       state = 'test State',
                                                                       PostalCode = '123',
                                                                       IsDefault = true,
                                                                       AddressType = 'Shipping',
                                                                       ParentId = u.AccountId);
        insert conPointAddress2;
        
        System.runAs(u){
            System.Test.startTest();
            BWC_UpdateBillingAddress.checkAndHitUpdateConsumer();
            System.Test.stopTest();
        }
    }
}
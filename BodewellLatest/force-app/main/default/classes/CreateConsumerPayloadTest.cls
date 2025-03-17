@isTest
public class CreateConsumerPayloadTest {
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
            ContactPointAddress shippingAddressInstance = new ContactPointAddress();
            shippingAddressInstance.City = 'test';
            shippingAddressInstance.Street = 'test';
            shippingAddressInstance.State = 'test';
            shippingAddressInstance.PostalCode = 'test';
            shippingAddressInstance.Country = 'test';
            shippingAddressInstance.IsDefault = true;
            shippingAddressInstance.AddressType = 'Shipping';
            shippingAddressInstance.Name = 'Shipping';
            insert shippingAddressInstance;
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
    static void CreateConsumerAPITestMethod() {
        test.startTest();
        List<ContactPointAddress> cpa = [SELECT Id,
                                         City,
                                         Street,
                                         State,
                                         PostalCode,
                                         Country,
                                         IsDefault,
                                         AddressType,
                                         Name 
                                         FROM ContactPointAddress];
        CreateConsumerPayload.getConsumerCreatePayload(cpa);
        test.stopTest();
    }
}
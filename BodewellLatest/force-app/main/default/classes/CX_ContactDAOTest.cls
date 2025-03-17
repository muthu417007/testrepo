/**
 * @author         Deepak Wadar
 * @company        GEA
 * @created        22.09.2023
 * @description    CX_ContactDAO tests
 */
@isTest
public class CX_ContactDAOTest {
    @TestSetup
    static void setupTestData() {
        // Create test data (e.g., Contact records)
        List<Contact> testContacts = new List<Contact> { 
            new Contact(FirstName = 'Test', LastName = 'PolSources 1', Email = 'test1@polsource.com', Phone = '7887401008'),
            new Contact(FirstName = 'Test', LastName = 'PolSources 2', Email = 'test2@polsource.com', Phone = '9130335008') 
        };
        insert testContacts;
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', Phone = '1234567890');
        insert testContact;
        Contact_Information__c testContactInfo = new Contact_Information__c(
            Contact__c = testContact.Id,
            Identifier__c = '12345',
            ID_Type__c = 'GE Consumer Number'
        );
        insert testContactInfo;
    }

    @isTest
   	static void testGetContactByEmailOrPhone() {
        // Create test data (e.g., Contact records)
        //List<Contact> contacts = new List<Contact>();
        List<Contact> testContacts = new List<Contact> { 
            new Contact(FirstName = 'Test', LastName = 'PolSources 1', Email = 'test1@polsource.com', Phone = '7887401008'),
            new Contact(FirstName = 'Test', LastName = 'PolSources 2', Email = 'test2@polsource.com', Phone = '9130335008') 
        };
        Test.startTest();
        insert testContacts;
        Test.stopTest();
        // Call the method to be tested with email and phone parameters
        String testEmail = 'test@example.com';
        String testPhone = '123-456-7890';

        List<Contact> result = CX_ContactDAO.getInstance().getContactByEmailOrPhone(testEmail, testPhone);

        // Assert the results
        //System.assertEquals(contacts.size(), result.size());
    }

    @isTest
    static void testGetContact() {
        Contact testContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Email = 'john.doe@example.com' LIMIT 1];

        Test.startTest();
        Contact result = CX_ContactDAO.getInstance().getContact(testContact.Id);
        Test.stopTest();

        // Assert the results
        System.assertEquals(testContact.FirstName, result.FirstName);
        System.assertEquals(testContact.LastName, result.LastName);
        System.assertEquals(testContact.Email, result.Email);
        System.assertEquals(testContact.Phone, result.Phone);
    }

    @isTest
    static void testGetContactInformation() {
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'john.doe@example.com' LIMIT 1];

        Test.startTest();
        List<Contact_Information__c> result = CX_ContactDAO.getInstance().getContactInformation(testContact.Id);
        Test.stopTest();

        // Assert the results
        System.assertEquals(1, result.size());
        System.assertEquals('12345', result[0].Identifier__c);
        System.assertEquals('GE Consumer Number', result[0].ID_Type__c);
    }
}
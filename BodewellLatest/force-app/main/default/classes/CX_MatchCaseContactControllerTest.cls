/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        25.05.2021
 * @description    Match case and contact test
 */
@IsTest
public with sharing class CX_MatchCaseContactControllerTest {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        02.06.2021
     * @description    
     * Test case:
     *  1. Creates a Case
     *  2. Calls the getCase method with the case's email and phone
     *  3. Assert the returned contacts quantity that should be 3
     */
    @IsTest
    static void getCaseTest() {
        Case testCase = new Case(CX_Contact_Email__c = 'test@polsource.com', CX_Contact_Phone__c = '1111237496', CX_MultipleMatchedContacts__c = true);
        insert testCase;
        
        Test.startTest();
        Case returnedCase = CX_MatchCaseContactController.getCase(testCase.Id);
        Test.stopTest();
        
        System.assertEquals(testCase.Id, returnedCase.Id);
    }
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    
     * Test case:
     *  1. Creates 4 contacts (1 that should not return)
     *  2. Creates a Case
     *  3. Calls the getContacts method with the case's email and phone
     *  4. Assert the returned contacts quantity that should be 3
     */
    @IsTest
    static void getContactsTest() {
        List<Contact> testContacts = new List<Contact>{ new Contact(LastName = 'Test 1', Email = 'test@polsource.com'), 
                                new Contact(LastName = 'Test 2', Phone = '1111237496'), 
                                new Contact(LastName = 'Test 3', Email = 'test@polsource.com', Phone = '1111237496'), 
                                new Contact(LastName = 'Test 4', Email = 'test2@polsource.com', Phone = '1111237488') };

        insert testContacts;

        Test.setFixedSearchResults(new List<Id> {testContacts[0].Id, testContacts[1].Id, testContacts[2].Id});

        Case testCase = new Case(CX_Contact_Email__c = 'test@polsource.com', CX_Contact_Phone__c = '1111237496', CX_MultipleMatchedContacts__c = true);
        insert testCase;
        
        Test.startTest();
        String contactsStr = CX_MatchCaseContactController.getContacts(testCase.CX_Contact_Email__c, testCase.CX_Contact_Phone__c);
        Test.stopTest();

        List<Contact> contacts = (List<Contact>) JSON.deserialize(contactsStr, List<Contact>.class);
        System.assertEquals(3, contacts.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        10.06.2021
     * @description    
     * Test case:
     *  1. Mocks the http callout
     *  2. Calls the getExternalContacts method with the case's email and phone
     *  3. Assert the returned contacts quantity that should be 2
     */
    @IsTest
    static void getExternalContactsTest() {
        String mockJson = '{"data":{"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}],"HouseHoldByPhone":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}';
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(200, 'OK', mockJson, null));

        Test.startTest();
        String resultJson = CX_MatchCaseContactController.getExternalContacts('test@polsource.com', '4251234567');
        Test.stopTest();

        List<CX_ContactSearchWrapper.HouseHold> contactsData = (List<CX_ContactSearchWrapper.HouseHold>) JSON.deserialize(resultJson, List<CX_ContactSearchWrapper.HouseHold>.class);
        System.assertEquals(2, contactsData.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        10.06.2021
     * @description    
     * Test case:
     *  1. Mocks with a error response
     *  2. Call the method to get external contacts
     *  3. Assert if a handled exception is thrown
     */
    @IsTest
    static void getExternalContactsErrorTest() {
        String mockJson = '{"errors":[]}';
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(400, 'Bad Request', mockJson, null));

        Boolean handledExceptionFired = false;
        Test.startTest();
        try {
            CX_MatchCaseContactController.getExternalContacts('test@polsource.com', '4251234567');
        } catch(AuraHandledException ex) {
            handledExceptionFired = true;
        }
        Test.stopTest();

        System.assertEquals(true, handledExceptionFired);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    
     * Test case:
     *  1. Inserts a contact
     *  2. Inserts a case
     *  3. Calls the matchContact method with the case id and contact
     *  4. Assert the old/new case values
     */
    @IsTest
    static void matchSFContactTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com');
        insert testContact;

        Case testCase = new Case(CX_Contact_Email__c = 'test@polsource.com', CX_Contact_Phone__c = '1111237496', CX_MultipleMatchedContacts__c = true);
        insert testCase;
        
        Test.startTest();
        CX_MatchCaseContactController.matchContact(testCase.Id, JSON.serialize(testContact), null);
        Test.stopTest();

        testContact = [SELECT Id FROM Contact];
        Case newCase = [SELECT Id, ContactId, CX_MultipleMatchedContacts__c FROM Case];
        
        System.assertEquals(null, testCase.ContactId);
        System.assertEquals(true, testCase.CX_MultipleMatchedContacts__c);

        System.assertEquals(testContact.Id, newCase.ContactId);
        System.assertEquals(true, newCase.CX_MultipleMatchedContacts__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    
     * Test case:
     *  1. Creates 1 contact (doesn't insert it)
     *  2. Inserts a case
     *  3. Calls the matchContact method with the case id and contact
     *  4. Assert if a handled exception is thrown
     */
    @IsTest
    static void matchSFContactErrorTest() {
        Boolean exceptionThrown = false;
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com');

        Case testCase = new Case(CX_Contact_Email__c = 'test@polsource.com', CX_Contact_Phone__c = '1111237496', CX_MultipleMatchedContacts__c = true);
        insert testCase;
        
        Test.startTest();
        try {
            CX_MatchCaseContactController.matchContact(testCase.Id, JSON.serialize(testContact), null);
        } catch(AuraHandledException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionThrown);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        10.06.2021
     * @description    
     * Test case:
     *  1. Creates a contact record (doesn't insert it)
     *  2. Prepares the external contact mock
     *  3. Inserts a case
     *  4. Calls the matchContact method with the case id, contact and search contact result
     *  5. Assert the old/new case values
     */
    @IsTest
    static void matchExternalContactTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com', PersonId__c = '1234567');

        String mockJson = '[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]';
        List<CX_ContactSearchWrapper.HouseHold> contactsData = (List<CX_ContactSearchWrapper.HouseHold>) JSON.deserialize(mockJson, List<CX_ContactSearchWrapper.HouseHold>.class);
        
        Case testCase = new Case(CX_Contact_Email__c = 'test@polsource.com', CX_Contact_Phone__c = '1111237496', CX_MultipleMatchedContacts__c = true);
        insert testCase;

        Test.startTest();
        CX_MatchCaseContactController.matchContact(testCase.Id, JSON.serialize(testContact), JSON.serialize(contactsData));
        Test.stopTest();

        testContact = [SELECT Id FROM Contact];
        Case newCase = [SELECT Id, ContactId, CX_MultipleMatchedContacts__c FROM Case];
        
        System.assertEquals(null, testCase.ContactId);
        System.assertEquals(true, testCase.CX_MultipleMatchedContacts__c);

        System.assertEquals(testContact.Id, newCase.ContactId);
        System.assertEquals(true, newCase.CX_MultipleMatchedContacts__c);
    }
}
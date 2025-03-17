/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        01.06.2021
 * @description    Contact match test
 */
@IsTest
public with sharing class CX_ContactMatchQueueableTest {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    
     * Test case:
     *  1. Mock the external callouts: contact search, location search and new contact info
     *  2. Creates a valid case with address information
     *  3. Inserts the case
     *  4. Asserts that a contact was created with the correct values and related to the case and to a location
     */
    @IsTest
    static void handleNewContactMatchWithAddressTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null);
        CX_SingleRequestMock mockLocationSearch = new CX_SingleRequestMock(200, 'OK', '{"CityName":"NEW YORK","StateCode":"NY","PostalAreaCode":"10017","RegionNo":"109","ZoneCode":"03"}', null);
        CX_SingleRequestMock mockNewContactInfo = new CX_SingleRequestMock(200, 'OK', '{"ConsumerNo":"193426717","AddressId":"01934267170001","PhoneId":"01934267170001"}', null);

        Map<String, String> calloutStrings = getCalloutStrings();

        Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
        mocksMap.put(calloutStrings.get('mockContactSearch'), mockContactSearch);
        mocksMap.put(calloutStrings.get('mockLocationSearch'), mockLocationSearch);
        mocksMap.put(calloutStrings.get('mockNewContactInfo'), mockNewContactInfo);
        Test.setMock(HttpCalloutMock.class,  new CX_MultiRequestMock(mocksMap));

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Street_Address__c = '2007 E 17th St', Zip_Postal_Code__c = '787021319', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Test.startTest();
        insert testCase;
        Test.stopTest();

        Contact newContact = [SELECT FirstName, LastName, Email, Phone, Identifier_Number__c, AccountId FROM Contact];
        testCase = [SELECT ContactId FROM Case];

        System.assertEquals(newContact.Id, testCase.ContactId);

        System.assertEquals('Test', newContact.FirstName);
        System.assertEquals('PolSource', newContact.LastName);
        System.assertEquals('test@polsource.com', newContact.Email);
        System.assertEquals('1111237496', newContact.Phone);
        System.assertEquals(193426717, newContact.Identifier_Number__c);

        List<Account> location = [SELECT Id FROM Account];
        System.assertEquals(1, location.size());
        System.assertEquals(newContact.AccountId, location[0].Id);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    
     * Test case:
     *  1. Mock the external contact search callout
     *  2. Creates a valid case without address information
     *  3. Inserts the case
     *  4. Asserts that a contact was created with the correct values and related to the case and to a dummy location
     */
    @IsTest
    static void handleNewContactMatchWithoutAddressTest() {
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null));

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Test.startTest();
        insert testCase;
        Test.stopTest();

        Contact newContact = [SELECT FirstName, LastName, Email, Phone, Identifier_Number__c, AccountId FROM Contact];
        testCase = [SELECT ContactId FROM Case];

        System.assertEquals(newContact.Id, testCase.ContactId);

        System.assertEquals('Test', newContact.FirstName);
        System.assertEquals('PolSource', newContact.LastName);
        System.assertEquals('test@polsource.com', newContact.Email);
        System.assertEquals('1111237496', newContact.Phone);

        List<Account> location = [SELECT Id, Name FROM Account];
        System.assertEquals(1, location.size());
        System.assertEquals(newContact.AccountId, location[0].Id);
        System.assertEquals('NoAddress City ST 00000', location[0].Name);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search
     *  2. Creates a valid case 
     *  3. Creates a contact that matches the case email
     *  4. Inserts the case
     *  5. Asserts that the SF contact was matched with the case
     */
    @IsTest
    static void handleSingleContactMatchSFEmailTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'PolSource', Email = 'test@polsource.com');
        insert testContact;

        Test.setFixedSearchResults(new List<Id> {testContact.Id});

        Test.startTest();
        insert testCase;
        Test.stopTest();

        testCase = [SELECT ContactId FROM Case];

        System.assertEquals(testContact.Id, testCase.ContactId);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search
     *  2. Creates a valid case 
     *  3. Creates a contact that matches the case phone
     *  4. Inserts the case
     *  5. Asserts that the contact was matched with the case
     */
    @IsTest
    static void handleSingleContactMatchSFPhoneTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(Phone_Number__c = '1111237496', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'PolSource', Phone = '1111237496');
        insert testContact;

        Test.setFixedSearchResults(new List<Id> {testContact.Id});

        Test.startTest();
        insert testCase;
        Test.stopTest();

        testCase = [SELECT ContactId FROM Case];

        System.assertEquals(testContact.Id, testCase.ContactId);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search
     *  2. Creates a valid case 
     *  3. Creates a contact that matches the case email and phone
     *  4. Inserts the case
     *  5. Asserts that the contact was matched with the case
     */
    @IsTest
    static void handleSingleContactMatchSFEmailPhoneTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'PolSource', Email = 'test@polsource.com', Phone = '1111237496');
        insert testContact;

        Test.setFixedSearchResults(new List<Id> {testContact.Id});

        Test.startTest();
        insert testCase;
        Test.stopTest();

        testCase = [SELECT ContactId FROM Case];

        System.assertEquals(testContact.Id, testCase.ContactId);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search
     *  2. Creates a valid case 
     *  3. Creates 2 contacts that matches the case email
     *  4. Inserts the case
     *  5. Asserts that the case was updated without a contact and with the Multiple Matched contacts field to true, and the email was set in the field used by the match case and contact component
     */
    @IsTest
    static void handleMultipleContactMatchEmailTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        List<Contact> testContacts = new List<Contact> { new Contact(FirstName = 'Test', LastName = 'PolSource 1', Email = 'test@polsource.com'), 
                                                         new Contact(FirstName = 'Test', LastName = 'PolSource 2', Email = 'test@polsource.com') };

        insert testContacts;
        Test.setFixedSearchResults(new List<Id> {testContacts[0].Id, testContacts[1].Id});

        Test.startTest();
        insert testCase;
        Test.stopTest();

        testCase = [SELECT ContactId, CX_Contact_Email__c, CX_MultipleMatchedContacts__c FROM Case];

        System.assertEquals(null, testCase.ContactId);
        System.assertEquals('test@polsource.com', testCase.CX_Contact_Email__c);
        System.assertEquals(true, testCase.CX_MultipleMatchedContacts__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search
     *  2. Creates a valid case 
     *  3. Creates 4 contacts that matches the case Phone (1 for each field)
     *  4. Inserts the case
     *  5. Asserts that the case was updated without a contact and with the Multiple Matched contacts field to true, and the phone was set in the field used by the match case and contact component
     */
    @IsTest
    static void handleMultipleContactMatchSFPhoneTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);
        
        Case testCase = new Case(Phone_Number__c = '(111) 123-7496', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        List<Contact> testContacts = new List<Contact> { new Contact(FirstName = 'Test', LastName = 'PolSource 2', Phone = '1111237496'),
                                                         new Contact(FirstName = 'Test', LastName = 'PolSource 2', MobilePhone = '1111237496'),
                                                         new Contact(FirstName = 'Test', LastName = 'PolSource 2', OtherPhone = '1111237496'),
                                                         new Contact(FirstName = 'Test', LastName = 'PolSource 2', VOIP_Phone__c = '1111237496')};

        insert testContacts;
        Test.setFixedSearchResults(new List<Id> {testContacts[0].Id, testContacts[1].Id, testContacts[2].Id, testContacts[3].Id});

        Test.startTest();
        insert testCase;
        Test.stopTest();

        testCase = [SELECT ContactId, CX_Contact_Email__c, CX_Contact_Phone__c, CX_MultipleMatchedContacts__c FROM Case];

        System.assertEquals(null, testCase.ContactId);
        System.assertEquals(null, testCase.CX_Contact_Email__c);
        System.assertEquals('1111237496', testCase.CX_Contact_Phone__c);
        System.assertEquals(true, testCase.CX_MultipleMatchedContacts__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search
     *  2. Creates a valid case 
     *  3. Creates 2 contacts that matches the case email and Phone (1 for each field)
     *  4. Inserts the case
     *  5. Asserts that the case was updated without a contact and with the Multiple Matched contacts field to true, and the email and phone were set in the fields used by the match case and contact component
     */
    @IsTest
    static void handleMultipleContactMatchSFEmailPhoneTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);
        
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '(111) 123-7496', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        List<Contact> testContacts = new List<Contact> { new Contact(FirstName = 'Test', LastName = 'PolSource 1', Email = 'test@polsource.com'), 
                                                         new Contact(FirstName = 'Test', LastName = 'PolSource 2', Phone = '1111237496') };

        insert testContacts;
        Test.setFixedSearchResults(new List<Id> {testContacts[0].Id, testContacts[1].Id});

        Test.startTest();
        insert testCase;
        Test.stopTest();

        testCase = [SELECT ContactId, CX_Contact_Email__c, CX_Contact_Phone__c, CX_MultipleMatchedContacts__c FROM Case];

        System.assertEquals(null, testCase.ContactId);
        System.assertEquals('test@polsource.com', testCase.CX_Contact_Email__c);
        System.assertEquals('1111237496', testCase.CX_Contact_Phone__c);
        System.assertEquals(true, testCase.CX_MultipleMatchedContacts__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        10.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search with a valid contact
     *  2. Creates a valid case 
     *  3. Inserts the case
     *  4. Asserts that the external contact was created and matched with the case
     */
    @IsTest
    static void handleSingleContactMatchExternalEmailTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Test.startTest();
        insert testCase;
        Test.stopTest();

        Contact testContact = [SELECT Id, MobilePhone FROM Contact];
        testCase = [SELECT ContactId FROM Case];

        System.assertEquals(testContact.Id, testCase.ContactId);
        System.assertEquals('4251234567', testContact.MobilePhone);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        10.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search with a valid contact
     *  2. Creates a valid case 
     *  3. Inserts the case
     *  4. Asserts that the external contact was created and matched with the case
     */
    @IsTest
    static void handleSingleContactMatchExternalPhoneTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(Phone_Number__c = '4251234567', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Test.startTest();
        insert testCase;
        Test.stopTest();

        Contact testContact = [SELECT Id, MobilePhone FROM Contact];
        testCase = [SELECT ContactId FROM Case];

        Account location = [SELECT LocationID__c FROM Account];

        System.assertEquals(testContact.Id, testCase.ContactId);
        System.assertEquals('4251234567', testContact.MobilePhone);
        System.assertEquals('5122473', location.LocationID__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        10.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search with a valid contact
     *  2. Creates a valid case 
     *  3. Inserts the case
     *  4. Asserts that the external contact was created and matched with the case
     */
    @IsTest
    static void handleSingleContactMatchExternalEmailPhoneTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}],"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '4251234567', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Test.startTest();
        insert testCase;
        Test.stopTest();

        Contact testContact = [SELECT Id, MobilePhone, Email FROM Contact];
        testCase = [SELECT ContactId FROM Case];

        System.assertEquals(testContact.Id, testCase.ContactId);
        System.assertEquals('4251234567', testContact.MobilePhone);
        System.assertEquals('test@polsource.com', testContact.Email);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        10.06.2021
     * @description    
     * Test case:
     *  1. Mock the external search with a valid contact
     *  2. Creates a valid case 
     *  3. Creates a valid contact in SF 
     *  4. Inserts the case
     *  5. Asserts that the case was updated without a contact and with the Multiple Matched contacts field to true, and phone was set in the field used by the match case and contact component
     */
    @IsTest
    static void handleMultipleContactMatchExternalSFTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}],"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(Phone_Number__c = '4251234567', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'PolSource', Phone = '4251234567');
        insert testContact;

        Test.setFixedSearchResults(new List<Id> {testContact.Id});

        Test.startTest();
        insert testCase;
        Test.stopTest();


        testCase = [SELECT ContactId, CX_Contact_Phone__c, CX_MultipleMatchedContacts__c FROM Case];

        System.assertEquals(null, testCase.ContactId);
        System.assertEquals('4251234567', testCase.CX_Contact_Phone__c);
        System.assertEquals(true, testCase.CX_MultipleMatchedContacts__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    Method that returns the callout string to be used in the test (to use along the CX_MultiRequestMock class)
     * @return         Map<String, String> - the callout strings map
     */
    private static Map<String, String> getCalloutStrings() {
        Map<String, String> calloutStrings = new Map<String, String>();

        if(CX_Utils.isSandbox()) {
            calloutStrings = new Map<String, String> { 'mockContactSearch' => 'callout:Sandbox_GraphQL_Search', 'mockNewContactInfo' => 'callout:Sandbox_CN1_Customer_Number', 'mockLocationSearch' => 'callout:Sandbox_ZoneDetails' };
        } else {
            calloutStrings = new Map<String, String> { 'mockContactSearch' => 'callout:Production_GraphQL_Search', 'mockNewContactInfo' => 'callout:Production_CN1_Customer_Number', 'mockLocationSearch' => 'callout:Production_ZoneDetails' };
        }
        
        return calloutStrings;
    }
}
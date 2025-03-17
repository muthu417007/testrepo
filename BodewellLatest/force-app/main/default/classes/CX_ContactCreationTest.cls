/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        25.06.2021
 * @description    Contact creation tests
 */
@IsTest
public with sharing class CX_ContactCreationTest {
    private static final RecordTypeInfo ACCOUNT_LOCATION_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');
    private static final RecordTypeInfo ACCOUNT_PERSON_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account');
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    
     * Test case:
     *  1. Creates a case
     *  2. Calls the createContact method, with a mocked wrapper and a unknown address
     *  3. Asserts that a contact was created with the correct values and related to the case and to a location
     */
    @IsTest
    static void createUnknownAddressContactTest() {
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        Test.startTest();
        Contact testContact = CX_ContactCreation.getInstance().createContact(getWrapper(true, true), testCase);
        Test.stopTest();

        testCase = [SELECT ContactId FROM Case];
        System.assertEquals(testContact.Id, testCase.ContactId);
                   
        List<Account> location = [SELECT Id FROM Account where recordTypeId =: ACCOUNT_PERSON_RT.getRecordTypeId()];
        System.assertEquals(1, location.size());

        //System.assertEquals(testContact.AccountId, location[0].Id);
        //System.assertEquals('test@polsource.com', testContact.Email);
        //System.assertEquals('1111237496', testContact.Phone);
        //System.assertEquals('City', testContact.MailingCity);
    }
     /**
     * @author         Neha Chowdhury
     * @company        Ge-Appliances
     * @created        07.01.2022
     * @description    
     * Test case:
     *  1. Calls the createContact method, with a mocked wrapper and country is canada
     *  2. Asserts that a contact was created with the correct values
     */
     @IsTest
    static void createCanadaContactTest() {
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;
        CX_ContactCreationWrapper mockWrapper = getWrapper(false, true);
        mockWrapper.country = 'Canada';
        mockWrapper.state = 'MONTREAL';
        mockWrapper.zip = 'H3Z 2Y7';
        mockWrapper.city ='QC';
        mockWrapper.street = 'Test Street';
        mockWrapper.usePhoneField = true;
      	mockWrapper.phone = '1111237496';
        mockWrapper.email = 'test@polsource.com';
        mockWrapper.firstName = 'Test';
        mockWrapper.lastName = 'PolSource';
        mockWrapper.unknownAddress = false;
      
        Test.startTest();
       	Contact testContact = CX_ContactCreation.getInstance().createContact(mockWrapper, testCase);
        Test.stopTest();
       	System.assertEquals('test@polsource.com', testContact.Email);
        System.assertEquals('1111237496', testContact.Phone);
        //System.assertEquals('QC', testContact.MailingCity);
        //System.assertEquals('Canada', testContact.MailingCountry);
        //System.assertEquals('MONTREAL', testContact.MailingState);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    
     * Test case:
     *  1. Creates a case
     *  2. Calls the createContact method, with a invalid mocked wrapper
     *  3. Asserts that a handled exception was thrown
     */
    @IsTest
    static void createContactInvalidStreetTest() {
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        CX_ContactCreationWrapper mockWrapper = getWrapper(false, true);
        mockWrapper.street = null;

        String errorMessage;

        Test.startTest();
        try {
            CX_ContactCreation.getInstance().createContact(mockWrapper, testCase);
        } catch(CX_ContactCreation.CX_ContactCreationException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Street Required.', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    
     * Test case:
     *  1. Creates a case
     *  2. Calls the createContact method, with a invalid mocked wrapper
     *  3. Asserts that a handled exception was thrown
     */
    @IsTest
    static void createContactInvalidPhoneTest() {
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        CX_ContactCreationWrapper mockWrapper = getWrapper(false, true);
        mockWrapper.phone = null;

        String errorMessage;

        Test.startTest();
        try {
            CX_ContactCreation.getInstance().createContact(mockWrapper, testCase);
        } catch(CX_ContactCreation.CX_ContactCreationException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Phone Required.', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    
     * Test case:
     *  1. Creates a case
     *  2. Calls the createContact method, with a invalid mocked wrapper
     *  3. Asserts that a handled exception was thrown
     */
    @IsTest
    static void createContactInvalidZipCodeTest() {
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        CX_ContactCreationWrapper mockWrapper = getWrapper(false, true);
        mockWrapper.zip = null;

        String errorMessage;

        Test.startTest();
        try {
            CX_ContactCreation.getInstance().createContact(mockWrapper, testCase);
        } catch(CX_ContactCreation.CX_ContactCreationException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Zip Required.', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    
     * Test case:
     *  1. Creates a case
     *  2. Calls the createContact method, with a invalid mocked wrapper
     *  3. Asserts that a handled exception was thrown
     */
    @IsTest
    static void createContactInvalidFirstNameTest() {
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        CX_ContactCreationWrapper mockWrapper = getWrapper(false, true);
        mockWrapper.firstName = null;

        String errorMessage;

        Test.startTest();
        try {
            CX_ContactCreation.getInstance().createContact(mockWrapper, testCase);
        } catch(CX_ContactCreation.CX_ContactCreationException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('First Name Required.', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    
     * Test case:
     *  1. Creates a case
     *  2. Calls the createContact method, with a invalid mocked wrapper
     *  3. Asserts that a handled exception was thrown
     */
    @IsTest
    static void createContactInvalidLastNameTest() {
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        CX_ContactCreationWrapper mockWrapper = getWrapper(false, true);
        mockWrapper.lastName = null;

        String errorMessage;

        Test.startTest();
        try {
            CX_ContactCreation.getInstance().createContact(mockWrapper, testCase);
        } catch(CX_ContactCreation.CX_ContactCreationException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Last Name Required.', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:
     *  1. Mocks the CN1 contact creation callout
     *  2. Creates a case
     *  3. Creates a location
     *  4. Calls the createContact method, with a mocked wrapper with the same address
     *  5. Asserts that a contact was created with the correct values and related to the case and to a location
     */
    @IsTest
    static void createContactExistingLocationAddressTest() {
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(200, 'OK', '{"ConsumerNo":"193426717","AddressId":"01934267170001","PhoneId":"01934267170001"}', null));

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        Account location = new Account(Name = 'Test', BillingPostalCode = '787021319', BillingStreet = 'Test Street', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;
                      
        Account personacc = new Account(LastName = 'TestLast', RecordTypeId = ACCOUNT_PERSON_RT.getRecordTypeId());
        insert personacc;
        Contact  con = [SELECT Id,FirstName,LastName,phone,email FROM Contact WHERE Accountid = :personacc.Id];
        
       /* Test.startTest();
        Contact testContact = CX_ContactCreation.getInstance().createContact(getWrapper(false, true), testCase);
        Test.stopTest();

        testCase = [SELECT ContactId FROM Case];
        System.assertEquals(testContact.Id, testCase.ContactId);

        Contact_Information__c  contactInformation = [SELECT Identifier__c FROM Contact_Information__c WHERE Contact__c = :testContact.Id];
        System.assertEquals('193426717', contactInformation.Identifier__c);

        List<GEA_AccountContactRelation__c> relations = [SELECT Id FROM GEA_AccountContactRelation__c WHERE Contact__c = :testContact.Id AND Account__c = :location.Id];
        System.assertEquals(1, relations.size());
        
        System.assertEquals(testContact.AccountId, location.Id);
        System.assertEquals('test@polsource.com', testContact.Email);
        System.assertEquals('1111237496', testContact.Phone);  */ 
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        02.07.2021
     * @description    
     * Test case:
     *  1. Mocks the CN1 contact creation callout with an error response
     *  2. Creates a case
     *  3. Creates a location
     *  4. Calls the createContact method, with a mocked wrapper
     *  5. Asserts that a Callout exception was thrown
     */
    @IsTest
    static void createContactErrorTest() {
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(200, 'OK', '{"ConsumerNo":"","AddressId":"01934267170001","PhoneId":"01934267170001"}', null));

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        Account location = new Account(Name = 'Test', BillingPostalCode = '787021319', BillingStreet = 'Test Street', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;

        Boolean calloutExceptionFired = false;

       /* Test.startTest();
        try {
            CX_ContactCreation.getInstance().createContact(getWrapper(false, true), testCase);
        } catch(CalloutException ex) {
            calloutExceptionFired = true;
        }
        Test.stopTest();
        System.assertEquals(true, calloutExceptionFired);*/
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:
     *  1. Mocks the CN1 contact creation callout
     *  2. Creates a case
     *  3. Creates a location
     *  4. Calls the createContact method, with a mocked wrapper with the same phone number as the location
     *  5. Asserts that a contact was created with the correct values and related to the case and to a location
     */
    @IsTest
    static void createContactExistingLocationPhoneTest() {
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(200, 'OK', '{"ConsumerNo":"193426717","AddressId":"01934267170001","PhoneId":"01934267170001"}', null));
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;
        Account location = new Account(Name = 'Test', BillingPostalCode = '454654644', Phone = '1111237496', BillingStreet = 'Test Street', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;
        /*Test.startTest();
        Contact testContact = CX_ContactCreation.getInstance().createContact(getWrapper(false, true), testCase);
        Test.stopTest();

        testCase = [SELECT ContactId FROM Case];
        System.assertEquals(testContact.Id, testCase.ContactId);

        Contact_Information__c  contactInformation = [SELECT Identifier__c FROM Contact_Information__c WHERE Contact__c = :testContact.Id];
        System.assertEquals('193426717', contactInformation.Identifier__c);

        List<GEA_AccountContactRelation__c> relations = [SELECT Id FROM GEA_AccountContactRelation__c WHERE Contact__c = :testContact.Id AND Account__c = :location.Id];
        System.assertEquals(1, relations.size());

        System.assertEquals(testContact.AccountId, location.Id);
        System.assertEquals('test@polsource.com', testContact.Email);
        System.assertEquals('1111237496', testContact.Phone);  */ 
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:
     *  1. Mocks the CN1 contact creation callout
     *  2. Mocks the location validation callout
     *  3. Creates a case
     *  4. Calls the createContact method, with a mocked wrapper
     *  5. Asserts that a contact was created with the correct values and related to the case and to a location
     */
    @IsTest
    static void createContactNewLocationTest() {
        CX_SingleRequestMock mockLocationSearch = new CX_SingleRequestMock(200, 'OK', '{"CityName":"NEW YORK","StateCode":"NY","PostalAreaCode":"787021319","RegionNo":"109","ZoneCode":"03"}', null);
        CX_SingleRequestMock mockNewContactInfo = new CX_SingleRequestMock(200, 'OK', '{"ConsumerNo":"193426717","AddressId":"01934267170001","PhoneId":"01934267170001"}', null);

        Map<String, String> calloutStrings = getCalloutStrings();

        Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
        mocksMap.put(calloutStrings.get('mockLocationSearch'), mockLocationSearch);
        mocksMap.put(calloutStrings.get('mockNewContactInfo'), mockNewContactInfo);
        Test.setMock(HttpCalloutMock.class,  new CX_MultiRequestMock(mocksMap));

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

       /* Test.startTest();
        Contact testContact = CX_ContactCreation.getInstance().createContact(getWrapper(false, true), testCase);
        Test.stopTest();

        testCase = [SELECT ContactId FROM Case];
        System.assertEquals(testContact.Id, testCase.ContactId);

        Contact_Information__c  contactInformation = [SELECT Identifier__c FROM Contact_Information__c WHERE Contact__c = :testContact.Id];
        System.assertEquals('193426717', contactInformation.Identifier__c);

        Account location = [SELECT Name, Service_Region_Zone__c FROM Account];
        System.assertEquals('Test Street New York NY 787021319', location.Name);
        System.assertEquals('Factory Service', location.Service_Region_Zone__c);

        List<GEA_AccountContactRelation__c> relations = [SELECT Id FROM GEA_AccountContactRelation__c WHERE Contact__c = :testContact.Id AND Account__c = :location.Id];
        System.assertEquals(1, relations.size());

        System.assertEquals(testContact.AccountId, location.Id);
        System.assertEquals('test@polsource.com', testContact.Email);
        System.assertEquals('1111237496', testContact.Phone);   */
    }
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    
     * Test case:
     *  1. Mocks a callout error
     *  2. Creates a case
     *  3. Calls the createContact method
     *  4. Asserts that a handled exception was thrown
     */
    @IsTest
    static void createContactCalloutErrorTest() {
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(500, 'Internal Server Error', '', null));

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        String errorMessage;

        Test.startTest();
        try {
            CX_ContactCreation.getInstance().createContact(getWrapper(false, true), testCase);
        } catch(CalloutException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Error while retrieving location info!', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.06.2021
     * @description    Returns a mocked wrapper
     * @param          Boolean - Is the address known?
     * @param          Boolean - should use Phone?
     * @return         CX_ContactCreationWrapper - A mocked wrapper
     */
    private static CX_ContactCreationWrapper getWrapper(Boolean unknownAddress, Boolean usePhoneField) {
        CX_ContactCreationWrapper wrapper = new CX_ContactCreationWrapper();
        wrapper.street = 'Test Street';
        wrapper.zip = '787021319';
        wrapper.phone = usePhoneField ? '1111237496' : null;
        wrapper.email = 'test@polsource.com';
        wrapper.firstName = 'Test';
        wrapper.lastName = 'PolSource';
        wrapper.unknownAddress = unknownAddress;
        wrapper.usePhoneField = usePhoneField;

        return wrapper;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        28.06.2021
     * @description    Method that returns the callout string to be used in the test (to use along the CX_MultiRequestMock class)
     * @return         Map<String, String> - the callout strings map
     */
    private static Map<String, String> getCalloutStrings() {
        Map<String, String> calloutStrings = new Map<String, String>();

        if(CX_Utils.isSandbox()) {
            calloutStrings = new Map<String, String> { 'mockNewContactInfo' => 'callout:Sandbox_CN1_Customer_Number', 'mockLocationSearch' => 'callout:Sandbox_ZoneDetails' };
        } else {
            calloutStrings = new Map<String, String> { 'mockNewContactInfo' => 'callout:Production_CN1_Customer_Number', 'mockLocationSearch' => 'callout:Production_ZoneDetails' };
        }
        
        return calloutStrings;
    }
}
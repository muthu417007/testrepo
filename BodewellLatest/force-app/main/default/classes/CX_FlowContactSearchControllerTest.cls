/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        29.05.2021
 * @description    Flow contact search test
 */
@IsTest(IsParallel = true)
public with sharing class CX_FlowContactSearchControllerTest {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        29.05.2021
     * @description    
     * Test case:
     *  1. Creates 4 contacts (1 that should not return)
     *  2. Calls the getContacts method with the  email
     *  3. Assert the returned contacts quantity that should be 3
     */
    @IsTest
    static void getContactsEmailTest() {
        List<Contact> testContacts = new List<Contact>{ new Contact(LastName = 'Test 1', Email = 'test@polsource.com'), 
                                new Contact(LastName = 'Test 2', Phone = '1111237496'), 
                                new Contact(LastName = 'Test 3', Email = 'test@polsource.com', Phone = '1111237496'), 
                                new Contact(LastName = 'Test 4', Email = 'test@polsource.com', Phone = '1111237488') };

        insert testContacts;

        Test.setFixedSearchResults(new List<Id> {testContacts[0].Id, testContacts[2].Id, testContacts[3].Id});
        
        Test.startTest();
        String contactsStr = CX_FlowContactSearchController.getContacts('test@polsource.com', null);
        Test.stopTest();

        List<Contact> contacts = (List<Contact>) JSON.deserialize(contactsStr, List<Contact>.class);
        System.assertEquals(3, contacts.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        29.05.2021
     * @description    
     * Test case:
     *  1. Creates 4 contacts (1 that should not return)
     *  2. Calls the getContacts method with the  phone
     *  3. Assert the returned contacts quantity that should be 3
     */
    @IsTest
    static void getContactsPhoneTest() {
        List<Contact> testContacts = new List<Contact>{ new Contact(LastName = 'Test 1', Email = 'test@polsource.com'), 
                                new Contact(LastName = 'Test 2', Phone = '1111237496'), 
                                new Contact(LastName = 'Test 3', Email = 'test@polsource.com', Phone = '1111237496'), 
                                new Contact(LastName = 'Test 4', Email = 'test@polsource.com', Phone = '1111237496') };

        insert testContacts;

        Test.setFixedSearchResults(new List<Id> {testContacts[1].Id, testContacts[2].Id, testContacts[3].Id});
        
        Test.startTest();
        String contactsStr = CX_FlowContactSearchController.getContacts(null, '1111237496');
        Test.stopTest();

        List<Contact> contacts = (List<Contact>) JSON.deserialize(contactsStr, List<Contact>.class);
        System.assertEquals(3, contacts.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        29.06.2021
     * @description    
     * Test case:
     *  1. Mocks the http callout
     *  2. Calls the getExternalContacts method with the email
     *  3. Assert the returned contacts quantity that should be 1
     */
    @IsTest
    static void getExternalContactsEmailTest() {
        String mockJson = '{"data":{"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}],"HouseHoldByPhone":[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}';
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(200, 'OK', mockJson, null));

        Test.startTest();
        String resultJson = CX_FlowContactSearchController.getExternalContacts('test@polsource.com', null);
        Test.stopTest();

        List<CX_ContactSearchWrapper.HouseHold> contactsData = (List<CX_ContactSearchWrapper.HouseHold>) JSON.deserialize(resultJson, List<CX_ContactSearchWrapper.HouseHold>.class);
        System.assertEquals(1, contactsData.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        29.06.2021
     * @description    
     * Test case:
     *  1. Mocks the http callout
     *  2. Calls the getExternalContacts method with the phone
     *  3. Assert the returned contacts quantity that should be 1
     */
    @IsTest
    static void getExternalContactsPhoneTest() {
        String mockJson = '{"data":{"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}],"HouseHoldByPhone":[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}';
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(200, 'OK', mockJson, null));

        Test.startTest();
        String resultJson = CX_FlowContactSearchController.getExternalContacts(null, '4251234561');
        Test.stopTest();

        List<CX_ContactSearchWrapper.HouseHold> contactsData = (List<CX_ContactSearchWrapper.HouseHold>) JSON.deserialize(resultJson, List<CX_ContactSearchWrapper.HouseHold>.class);
        System.assertEquals(1, contactsData.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        29.06.2021
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
            CX_FlowContactSearchController.getExternalContacts(null, '4251234567');
        } catch(AuraHandledException ex) {
            handledExceptionFired = true;
        }
        Test.stopTest();

        System.assertEquals(true, handledExceptionFired);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        29.06.2021
     * @description    
     * Test case:
     *  1. Creates a contact record (doesn't insert it)
     *  2. Prepares the external contact mock
     *  3. Calls the restoreContact method with the contact and search contact result
     *  4. Assert the returned Id
     */
    @IsTest
    static void restoreExternalContactTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com', PersonId__c = '1234567');

        String mockJson = '[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]';

        Test.startTest();
        Id contactId = CX_FlowContactSearchController.restoreContact(JSON.serialize(testContact), mockJson);
        Test.stopTest();

        testContact = [SELECT Id FROM Contact];
        System.assertEquals(contactId, testContact.Id);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        29.06.2021
     * @description    
     * Test case:
     *  1. Creates a contact record (doesn't insert it)
     *  2. Prepares the external contact mock
     *  3. Calls the restoreContact method with the contact and search contact result
     *  4. Assert an exception was fired
     */
    @IsTest
    static void restoreExternalContactErrorTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com', PersonId__c = '1234567');

        String mockJson = null;
        Boolean exceptionFired = false;

        Test.startTest();
        try {
            CX_FlowContactSearchController.restoreContact(JSON.serialize(testContact), mockJson);
        } catch(AuraHandledException ex) {
            exceptionFired = true;
        }

        System.assertEquals(true, exceptionFired);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.07.2021
     * @description    
     * Test case:
     *  1. Creates a contact record and a case
     *  2. Calls the relate method
     *  3. Asserts if the contact and case were related
     */
    @IsTest
    static void relateContactCaseTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com', PersonId__c = '1234567');
        insert testContact;

        Case testCase = new Case();
        insert testCase;

        Test.startTest();
        CX_FlowContactSearchController.relateContactCase(testCase.Id, testContact.Id);
        Test.stopTest();

        testCase = [SELECT ContactId FROM Case];
        System.assertEquals(testContact.Id, testCase.ContactId);
    }
}
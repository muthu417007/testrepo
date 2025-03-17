/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        08.06.2021
 * @description    Contact match utils utils class tests
 */
@IsTest
public with sharing class CX_ContactMatchUtilsTest {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        09.06.2021
     * @description    
     * Test case:
     *  1. Creates a wrapper from the mock JSON string
     *  2. Calls the method to find the contact data by using the personId
     *  3. Asserts if the returned contact is the expected
     */
    @IsTest
    static void searchByPersonIdTest() {
        String contactSearchSuccessMock = '{"data":{"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}';
        CX_ContactSearchWrapper wrapper = (CX_ContactSearchWrapper) JSON.deserialize(contactSearchSuccessMock, CX_ContactSearchWrapper.class);

        Test.startTest();
        CX_ContactSearchWrapper.HouseHold contactData = CX_ContactMatchUtils.searchByPersonId(wrapper.data.HouseHoldByEmail, '1234567');
        Test.stopTest();

        System.assertEquals('Test', contactData.FirstName);
        System.assertEquals(null, contactData.ClientPersonCode);
        System.assertEquals(false, contactData.IsDead);
        System.assertEquals('First', contactData.plevel);
        System.assertEquals('', contactData.Salutation);

        System.assertEquals(false, contactData.EmailAddresses[0].IsPrimaryPerson);
        System.assertEquals(null, contactData.EmailAddresses[0].MYAMyAccountId);

        System.assertEquals('', contactData.Details[0].COPSPersonNumber);
        System.assertEquals('1234567', contactData.Details[0].PersonID);
        
        System.assertEquals('Test St', contactData.Orders[0].AddressLine1);
        System.assertEquals('OSBP-IN', contactData.Orders[0].DataSourceCode);
        System.assertEquals('OSB Parts sales via the internet/web', contactData.Orders[0].DataSourceName);
        System.assertEquals('Test', contactData.Orders[0].FirstName);
        System.assertEquals('PolSource', contactData.Orders[0].LastName);
        System.assertEquals('Austin', contactData.Orders[0].Locality);
        System.assertEquals('502325253', contactData.Orders[0].OrderCreatedBy);
        System.assertEquals('2021-01-11T00:00:00.000Z', contactData.Orders[0].OrderDate);
        System.assertEquals('0.00', contactData.Orders[0].OrderDiscountAmount);
        System.assertEquals('24.50', contactData.Orders[0].OrderGrossAmount);
        System.assertEquals('7654321', contactData.Orders[0].OrderID);
        System.assertEquals('24.50', contactData.Orders[0].OrderNetAmount);
        System.assertEquals('1234567890', contactData.Orders[0].OrderNumber);
        System.assertEquals('C', contactData.Orders[0].OrderPaymentMethod);
        System.assertEquals('2021-01-10T00:00:00.000Z', contactData.Orders[0].OrderPlacedOn);
        System.assertEquals('BUY17', contactData.Orders[0].OrderPromoCode);
        System.assertEquals('12.95', contactData.Orders[0].OrderShipmentAmount);
        System.assertEquals('3.09', contactData.Orders[0].OrderTaxAmount);
        System.assertEquals('', contactData.Orders[0].OrderUniqueKey);
        System.assertEquals('1234567', contactData.Orders[0].PersonID);
        System.assertEquals('963852741', contactData.Orders[0].PostalCode);
        System.assertEquals('TX', contactData.Orders[0].Region);

        System.assertEquals('987654321', contactData.Orders[0].OrderDetails[0].AssetID);
        System.assertEquals('', contactData.Orders[0].OrderDetails[0].BrandName);
        System.assertEquals('', contactData.Orders[0].OrderDetails[0].CleansedModelNumber);
        System.assertEquals('0.00', contactData.Orders[0].OrderDetails[0].DiscountPercent);
        System.assertEquals('1', contactData.Orders[0].OrderDetails[0].InvoiceLine);
        System.assertEquals('134280171', contactData.Orders[0].OrderDetails[0].InvoiceNumber);
        System.assertEquals('2.91', contactData.Orders[0].OrderDetails[0].ManufacturerCost);
        System.assertEquals('24.50', contactData.Orders[0].OrderDetails[0].NetInvoiceValue);
        System.assertEquals('7654321', contactData.Orders[0].OrderDetails[0].OrderID);
        System.assertEquals('WD12X24058', contactData.Orders[0].OrderDetails[0].OriginalModelNumber);
        System.assertEquals('WD12X24058', contactData.Orders[0].OrderDetails[0].PartNumber);
        System.assertEquals('', contactData.Orders[0].OrderDetails[0].ProductCategoryName);
        System.assertEquals('', contactData.Orders[0].OrderDetails[0].ProductDescription);
        System.assertEquals('', contactData.Orders[0].OrderDetails[0].ProductLineName);
        System.assertEquals('3.09', contactData.Orders[0].OrderDetails[0].TaxAmount);

        System.assertEquals(null, contactData.Assets[0].IsProductReturned);
        System.assertEquals('Microwave Ovens', contactData.Assets[0].ProductCategoryName);

        System.assertEquals('', contactData.Locations[0].AddressLine2);
        System.assertEquals('USA', contactData.Locations[0].CountryCode);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        09.06.2021
     * @description    
     * Test case:
     *  1. Creates a wrapper from the mock JSON string
     *  2. Calls the method to restore the contact structure
     *  3. Asserts if the whole structure was created correctly
     */
    @IsTest
    static void restoreContactTest() {
        String mockJson = '{"data":{"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"},{"PhoneNumber": "4251234562","IsPrimaryPhone": "0","PhoneTypeName": "LAND LINE","PhoneUseTypeName": "MAIN"},{"PhoneNumber": "4251234563","IsPrimaryPhone": "0","PhoneTypeName": "UNKNOWN","PhoneUseTypeName": "MAIN"},{"PhoneNumber": "4251234564","IsPrimaryPhone": "0","PhoneTypeName": "VOIP","PhoneUseTypeName": "MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}';
        CX_ContactSearchWrapper wrapper = (CX_ContactSearchWrapper) JSON.deserialize(mockJson, CX_ContactSearchWrapper.class);
        CX_ContactSearchWrapper.HouseHold contactData = wrapper.data.HouseHoldByEmail[0];

        Test.startTest();
        Contact newContact = CX_ContactMatchUtils.restoreContact(contactData);
        Test.stopTest();

        // Contact
        System.assertNotEquals(null, newContact.Id);
        System.assertEquals('Test', newContact.FirstName);
        System.assertEquals('PolSource', newContact.LastName);
        System.assertEquals('1234567', newContact.PersonID__c);
        System.assertEquals('test@polsource.com', newContact.Email);

        System.assertEquals('4251234561', newContact.MobilePhone);
        System.assertEquals('4251234562', newContact.Phone);
        System.assertEquals('4251234563', newContact.OtherPhone);
        System.assertEquals('4251234564', newContact.VOIP_Phone__c);

        // Location
        List<GEA_AccountContactRelation__c> relations = [SELECT Account__c, Account__r.Name, Account__r.LocationID__c FROM GEA_AccountContactRelation__c];
        System.assertEquals(1, relations.size());

        System.assertEquals('Test St Austin TX 963852741', relations[0].Account__r.Name);
        System.assertEquals('5122473', relations[0].Account__r.LocationID__c);

        // Assets
        List<Asset> assets = [SELECT AssetID__c, AccountId,  AssetShippedOn__c, OwnershipStartedOn__c FROM Asset];
        System.assertEquals(1, assets.size());

        System.assertEquals('987654321', assets[0].AssetID__c);
        System.assertEquals(relations[0].Account__c, assets[0].AccountId);

        Date testDate = Date.newInstance(1951, 1, 1);
        //System.assertEquals(testDate, assets[0].AssetScrappedOn__c);
        System.assertEquals(testDate, assets[0].AssetShippedOn__c);
        System.assertEquals(testDate, assets[0].OwnershipStartedOn__c);

        // Contact Info
        List<Contact_Information__c> contactInfos = [SELECT PersonDetailID__c FROM Contact_Information__c WHERE Contact__c = :newContact.Id];
        System.assertEquals(1, contactInfos.size());

        System.assertEquals('123456789', contactInfos[0].PersonDetailID__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        09.06.2021
     * @description    
     * Test case:
     *  1. Creates a wrapper from the mock JSON string
     *  2. Calls the method to parse the data to Contacts
     *  3. Asserts if the returned contact are the expected
     */
    @IsTest
    static void parseToContactsTest() {
        String mockJson = '{"data":{"HouseHoldByEmail":[{"Phone":[{"PhoneNumber":"4251234561","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}],"HouseHoldByPhone":[{"Phone":[{"PhoneNumber":"4251234567","IsPrimaryPhone":"1","PhoneTypeName":"CELLULAR","PhoneUseTypeName":"MAIN"}],"Details":[{"COPSPersonNumber":"","GEConsumerNo":"0","PersonDetailID":"123456789","PersonID":"1234567"}],"ClientPersonCode":null,"FirstName":"Test 2","Gender":"M","IsDead":false,"LastName":"PolSource","MiddleName":"","PersonID":"1234567","Orders":[{"AddressLine1":"Test St","DataSourceCode":"OSBP-IN","DataSourceName":"OSB Parts sales via the internet/web","FirstName":"Test","LastName":"PolSource","Locality":"Austin","OrderCreatedBy":"502325253","OrderDate":"2021-01-11T00:00:00.000Z","OrderDetails":[{"AssetID":"987654321","BrandName":"","CleansedModelNumber":"","DiscountPercent":"0.00","InvoiceLine":"1","InvoiceNumber":"134280171","ManufacturerCost":"2.91","NetInvoiceValue":"24.50","OrderID":"7654321","OriginalModelNumber":"WD12X24058","PartNumber":"WD12X24058","ProductCategoryName":"","ProductDescription":"","ProductLineName":"","TaxAmount":"3.09"}],"OrderDiscountAmount":"0.00","OrderGrossAmount":"24.50","OrderID":"7654321","OrderNetAmount":"24.50","OrderNumber":"1234567890","OrderPaymentMethod":"C","OrderPlacedOn":"2021-01-10T00:00:00.000Z","OrderPromoCode":"BUY17","OrderShipmentAmount":"12.95","OrderTaxAmount":"3.09","OrderUniqueKey":"","PersonID":"1234567","PostalCode":"963852741","Region":"TX"}],"EmailAddresses":[{"EmailAddress":"test@polsource.com","IsPrimaryEmail":"1","IsPrimaryPerson":false,"MYAMyAccountId":null}],"plevel":"First","Salutation":"","Assets":[{"AssetClassName":"Major Appliances","AssetID":"987654321","AssetScrappedOn":"1951-01-01T00:00:00.000Z","AssetShippedOn":"1951-01-01T00:00:00.000Z","BrandName":"GE","CleansedModelNumber":null,"IsProductReturned":null,"LocationID":"5122473","MACAddress":null,"OriginalEngineeringModelNumber":null,"OwnershipStartedOn":"1951-01-01T00:00:00.000Z","ProductCategoryName":"Microwave Ovens","ProductDescription":"MICROWAVE OVEN","ProductLineName":"Cooking","SerialNumber":null}],"Locations":[{"LocationID":"5122473","AddressLine1":"Test St","AddressLine2":"","Locality":"Austin","Region":"TX","PostalCode":"963852741","CountryCode":"USA"}]}]}}';
        CX_ContactSearchWrapper wrapper = (CX_ContactSearchWrapper) JSON.deserialize(mockJson, CX_ContactSearchWrapper.class);

        Test.startTest();
        List<Contact> contactsPhone = CX_ContactMatchUtils.parseToContacts(wrapper.data, 'phone', true);
        List<Contact> contactsEmail = CX_ContactMatchUtils.parseToContacts(wrapper.data, 'email');
        Test.stopTest();

        System.assertEquals(1, contactsEmail.size());
        System.assertEquals(1, contactsPhone.size());

        System.assertEquals('Test', contactsEmail[0].FirstName);
        System.assertEquals('Test 2', contactsPhone[0].FirstName);
    }
}
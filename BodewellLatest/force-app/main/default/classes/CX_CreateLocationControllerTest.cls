/**
 * @author         Gabriel Alves
 * @company        PolSource
 * @created        24.06.2021
 * @description    CX_CreateLocationController tests
 */
@isTest
private class CX_CreateLocationControllerTest {
    private static final RecordTypeInfo ACCOUNT_LOCATION_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');
    
    @isTest
    static void givenLocationInformationCreateNewLocationAccountWithoutServiceResponse () {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"status-code":"100","error-field":null,"error-text":"ORA-01403: NO DATA FOUND"}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());

        Test.startTest();

        CX_CreateLocationController.createLocation(location);

        Test.stopTest();

        List<Account> locations = [SELECT Id, Region__c, Zone__c, Service_Region_Zone__c FROM Account WHERE RecordTypeId = :ACCOUNT_LOCATION_RT.getRecordTypeId()];
        System.assertEquals(1, locations.size(), 'Only a single location is supposed to be created');
        System.assertEquals(null, locations[0].Region__c);
        System.assertEquals(null, locations[0].Zone__c);
        System.assertEquals(null, locations[0].Service_Region_Zone__c);
    }

    @isTest
    static void givenLocationInformationCreateNewLocationAccountWithServiceResponse () {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"CityName":"NEW YORK","StateCode":"NY","PostalAreaCode":"10017","RegionNo":"109","ZoneCode":"03"}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());

        Test.startTest();

        CX_CreateLocationController.createLocation(location);

        Test.stopTest();

        List<Account> locations = [SELECT Id, Region__c, Zone__c, Service_Region_Zone__c FROM Account WHERE RecordTypeId = :ACCOUNT_LOCATION_RT.getRecordTypeId()];
        System.assertEquals(1, locations.size(), 'Only a single location is supposed to be created');
        System.assertEquals(109, locations[0].Region__c);
        System.assertEquals('03', locations[0].Zone__c);
        System.assertEquals('Factory Service', locations[0].Service_Region_Zone__c);
    }

    @isTest
    static void givenLocationWithoutBillingPostalCodeCatchException () {
        Account location = new Account(Name = 'Test', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());

        Exception e;
        Test.startTest();

        try {
            CX_CreateLocationController.createLocation(location);
        } catch (Exception ex) {
            e = ex;
        }

        Test.stopTest();

        System.assertNotEquals(null, e, 'Exception should have been thrown and not be null');
        System.assertEquals('System.AuraHandledException', e.getTypeName());
        System.assertEquals('Error creating Case: Zip Code is required', e.getMessage());
    }

    @isTest
    static void givenLocationWithoutNameCheckItAutoFillsTheNameBeforeSaving () {        
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"CityName":"NEW YORK","StateCode":"NY","PostalAreaCode":"10017","RegionNo":"109","ZoneCode":"03"}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Account location = new Account(BillingPostalCode = '10017', BillingStreet = 'test street', BillingCity = 'Las Vegas', BillingState = 'NV', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        
        Test.startTest();

        CX_CreateLocationController.createLocation(location);

        Test.stopTest();

        List<Account> locations = [SELECT Id, Name, Region__c, Zone__c, Service_Region_Zone__c FROM Account WHERE RecordTypeId = :ACCOUNT_LOCATION_RT.getRecordTypeId()];
        System.assertEquals(1, locations.size(), 'Only a single location is supposed to be created');
        System.assertEquals(location.BillingStreet + ' ' + location.BillingCity + ', ' + location.BillingState + ' ' + location.BillingPostalCode, locations[0].Name);
    }
}
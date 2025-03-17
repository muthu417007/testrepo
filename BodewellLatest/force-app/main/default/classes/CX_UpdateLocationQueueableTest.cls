/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.06.2021
 * @description    Location zone/region update tests
 */
@IsTest(IsParallel = true)
public with sharing class CX_UpdateLocationQueueableTest {
    private static final RecordTypeInfo CASE_GENERAL_RT =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General');
    private static final RecordTypeInfo ACCOUNT_LOCATION_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Mocks the location integration
     *  2. Creates a location that is valid for the update location zone/region trigger
     *  3. Inserts the location
     *  4. Asserts that the zone and region fields were updated
     */
    @IsTest
    static void updateLocationZoneRegionValidTest() {
        CX_SingleRequestMock mockLocationSearch = new CX_SingleRequestMock(200, 'OK', '{"CityName":"NEW YORK","StateCode":"NY","PostalAreaCode":"10017","RegionNo":"109","ZoneCode":"03"}', null);
        Test.setMock(HttpCalloutMock.class, mockLocationSearch);

        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());

        Test.startTest();
        insert location;
        Test.stopTest();

        location = [SELECT Region__c, Zone__c, Service_Region_Zone__c FROM Account];
        System.assertEquals(109, location.Region__c);
        System.assertEquals('03', location.Zone__c);
        System.assertEquals('Factory Service', location.Service_Region_Zone__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Mocks the location integration
     *  2. Creates a location that is valid for the update location zone/region trigger
     *  3. Inserts the location
     *  4. Asserts that the zone and region fields were not updated
     */
    @IsTest
    static void updateLocationZoneRegionCalloutErrorTest() {
        CX_SingleRequestMock mockLocationSearch = new CX_SingleRequestMock(200, 'OK', '{"status-code":"100","error-field":null,"error-text":"ORA-01403: NO DATA FOUND"}', null);
        Test.setMock(HttpCalloutMock.class, mockLocationSearch);

        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());

        Test.startTest();
        insert location;
        Test.stopTest();

        location = [SELECT Region__c, Zone__c, Service_Region_Zone__c FROM Account];
        System.assertEquals(null, location.Region__c);
        System.assertEquals(null, location.Zone__c);
        System.assertEquals(null, location.Service_Region_Zone__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Inserts a location that has no Zip Code
     *  2. Creates a case and assign the location to it
     *  3. Inserts the case
     *  4. Asserts that the zone and region fields were not updated
     */
    @IsTest
    static void updateLocationZoneRegionNoZipCodeTest() {
        Account location = new Account(Name = 'Test', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;

        Case testCase = new Case(Subject = 'Test', AccountId = location.Id, RecordTypeId = CASE_GENERAL_RT.getRecordTypeId());

        Test.startTest();
        insert testCase;
        Test.stopTest();

        location = [SELECT Region__c, Zone__c, Service_Region_Zone__c FROM Account];
        System.assertEquals(null, location.Region__c);
        System.assertEquals(null, location.Zone__c);
        System.assertEquals(null, location.Service_Region_Zone__c);
    }
}
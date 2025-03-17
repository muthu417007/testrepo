/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.06.2021
 * @description    Location (Account) tests
 */
@IsTest(IsParallel = true)
public with sharing class CX_LocationAccountTest {
    private static final RecordTypeInfo CASE_GENERAL_RT =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General');
    private static final RecordTypeInfo ACCOUNT_LOCATION_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Creates a case that is not valid for the update location trigger
     *  2. Inserts the case
     *  3. Asserts that no queueable was enqueued
     */
    @IsTest
    static void updateCaseLocationZoneRegionNotValidTest() {
        Case testCase = new Case(Subject = 'Test');

        Test.startTest();
        insert testCase;
        Test.stopTest();

        ApexClass queueableClass = [SELECT Id FROM ApexClass WHERE Name = 'CX_UpdateLocationQueueable'];
        List<AsyncApexJob> jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE ApexClassId = :queueableClass.Id];
        System.assertEquals(0, jobs.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Creates a case that is valid for the update location trigger
     *  2. Inserts the case
     *  3. Asserts that 2 queueables were enqueued (1 for the location creation and other for the case creation)
     */
    @IsTest
    static void updateCaseLocationZoneRegionValidTest() {
        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;

        Case testCase = new Case(Subject = 'Test', AccountId = location.Id, RecordTypeId = CASE_GENERAL_RT.getRecordTypeId());

        Test.startTest();
        insert testCase;
        Test.stopTest();

        ApexClass queueableClass = [SELECT Id FROM ApexClass WHERE Name = 'CX_UpdateLocationQueueable'];
        List<AsyncApexJob> jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE ApexClassId = :queueableClass.Id];
        System.assertEquals(2, jobs.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Inserts a case that is not valid for the update location trigger
     *  2. Inserts a location that is valid for the update location zone/region trigger 
     *  3. Asserts that just a single queueable was enqueued (location creation)
     *  3. Updates the case with a valid location
     *  4. Asserts that 2 queueables were enqueued (1 for the location creation and other for the case update)
     */
    @IsTest
    static void updateCaseLocationZoneRegionUpdateValidTest() {
        Case testCase = new Case(Subject = 'Test', RecordTypeId = CASE_GENERAL_RT.getRecordTypeId());
        insert testCase;

        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;

        ApexClass queueableClass = [SELECT Id FROM ApexClass WHERE Name = 'CX_UpdateLocationQueueable'];
        List<AsyncApexJob> jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE ApexClassId = :queueableClass.Id];
        System.assertEquals(1, jobs.size());

        Test.startTest();
        testCase.AccountId = location.Id;
        update testCase;
        Test.stopTest();

        jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE ApexClassId = :queueableClass.Id];
        System.assertEquals(2, jobs.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Creates a location that is not valid for the update location zone/region trigger
     *  2. Inserts the location
     *  3. Asserts that no queueable was enqueued
     */
    @IsTest
    static void updateLocationZoneRegionNotValidTest() {
        Account location = new Account(Name = 'Test', BillingPostalCode = null, RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());

        Test.startTest();
        insert location;
        Test.stopTest();

        ApexClass queueableClass = [SELECT Id FROM ApexClass WHERE Name = 'CX_UpdateLocationQueueable'];
        List<AsyncApexJob> jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE ApexClassId = :queueableClass.Id];
        System.assertEquals(0, jobs.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Inserts a location that is not valid for the update location zone/region trigger
     *  2. Asserts that no queueable was enqueued
     *  3. Updates the location with a valid Zip Code
     *  3. Asserts that a queueable was enqueued
     */
    @IsTest
    static void updateLocationZoneRegionUpdateValidTest() {
        Account location = new Account(Name = 'Test', BillingPostalCode = null, RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;

        ApexClass queueableClass = [SELECT Id FROM ApexClass WHERE Name = 'CX_UpdateLocationQueueable'];
        List<AsyncApexJob> jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE ApexClassId = :queueableClass.Id];
        System.assertEquals(0, jobs.size());

        Test.startTest();
        location.BillingPostalCode = '10017';
        update location;
        Test.stopTest();

        jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE ApexClassId = :queueableClass.Id];
        System.assertEquals(1, jobs.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Creates a location that is valid for the update location zone/region trigger
     *  2. Inserts the location
     *  3. Asserts that 1 queueable was enqueued
     */
    @IsTest
    static void updateLocationZoneRegionValidTest() {
        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());

        Test.startTest();
        insert location;
        Test.stopTest();

        ApexClass queueableClass = [SELECT Id FROM ApexClass WHERE Name = 'CX_UpdateLocationQueueable'];
        List<AsyncApexJob> jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE ApexClassId = :queueableClass.Id];
        System.assertEquals(1, jobs.size());
    }
}
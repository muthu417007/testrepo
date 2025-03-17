/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        27.05.2021
 * @description    Web to Case test
 */
@IsTest(IsParallel = true)
public with sharing class CX_WebToCaseTest {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        27.05.2021
     * @description    
     * Test case:
     *  1. Creates a case that is not valid for the contact match trigger
     *  2. Inserts the case
     *  3. Asserts that no contacts were created
     */
    @IsTest
    static void handleContactMatchNotValidTest() {
        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Origin = 'NotWebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Test.startTest();
        insert testCase;
        Test.stopTest();

        List<Contact> contacts = [SELECT FirstName, LastName, Email, Phone FROM Contact];
        System.assertEquals(0, contacts.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        27.05.2021
     * @description    
     * Test case:
     *  1. Mock the external search
     *  2. Creates a case that is valid for the contact match trigger
     *  3. Inserts the case
     *  4. Asserts that the queueable was executed
     */
    @IsTest
    static void handleContactMatchValidTest() {
        CX_SingleRequestMock mockContactSearch = new CX_SingleRequestMock(200, 'OK', '{"data":{"HouseHoldByPhone":[], "HouseHoldByEmail":[]}}', null);
        Test.setMock(HttpCalloutMock.class, mockContactSearch);

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Origin = 'WebToCase', Status = 'New', Subject = 'Test', First_Name__c = 'Test', Last_Name__c = 'PolSource');

        Test.startTest();
        insert testCase;
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT ApexClassId FROM AsyncApexJob WHERE JobType = 'Queueable'];
        Set<String> classesIds = new Set<String>();
        CX_CollectionUtils.loadSet(classesIds, 'ApexClassId', jobs);

        List<ApexClass> classes = [SELECT Name FROM ApexClass WHERE Id IN :classesIds];

        Boolean contactMatchFired = false;

        for(ApexClass firedClass : classes) {
            if(firedClass.Name == 'CX_ContactMatchQueueable') {
                contactMatchFired = true;
                break;
            }
        }

        System.assertEquals(true, contactMatchFired);
    }
}
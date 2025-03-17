/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        09.07.2021(dd.mm.yyyy)
 * @description    CX_FlowLocationComponentController testMethods
 */
@IsTest(IsParallel = true)
public with sharing class CX_FlowLocationComponentControllerTest {
    
    private static final RecordTypeInfo ACCOUNT_LOCATION_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');
    
    @TestSetup
    static void setup() {
        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;

        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com', AccountId = location.Id);
        insert testContact;

        Case testCase =  new Case(AccountId = location.Id, ContactId = testContact.Id,Subject = 'Test Subject', Type = 'Test type' );
        insert testCase;

        insert new GEA_AccountContactRelation__c(Account__c = location.Id, Contact__c = testContact.Id); 

        Asset testGAsset =  new Asset(
            AccountId = testCase.AccountID,
            Model_Number__c = 'test model',
            SerialNumber = 'test serial'
        );

        insert testGAsset;

        insert new Case_Asset__c(
            Case__c = testCase.Id,
            Model_Number__c = 'test model',
            Serial_Number__c = 'test serial',
            Asset__c  =  testGAsset.Id   
        );
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        09.07.2021(dd.mm.yyyy)
     * @description    
     * Test case:   Method calls the 
     *              CX_FlowLocationComponentController.selectContactLocations                
    */
    @IsTest
    static void selectContactLocationsTest() {
        Case tCase = [Select Id,ContactId,AccountId from Case][0];
        Test.startTest();
        List<Account> tAccounts = CX_FlowLocationComponentController.selectContactLocations(tCase.ContactId, null);
        Test.stopTest();
        System.assertEquals(1, tAccounts.size());
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        09.07.2021(dd.mm.yyyy)
     * @description    
     * Test case:   Method calls the 
     *              CX_FlowLocationComponentController.selectContactLocations  to get an exception message              
    */
    @IsTest
    static void selectContactLocationsExceptionTest() {
        String errorMessageControl = '';
        try{
            List<Account> tAccList = CX_FlowLocationComponentController.selectContactLocations('letsHaveAnException', null);
        }catch(Exception ex){
            errorMessageControl = ex.getMessage();
        }
        System.assertEquals(errorMessageControl, 'An error occurred while getting the contact locations!');
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        09.07.2021(dd.mm.yyyy)
     * @description    
     * Test case:   Method calls the 
     *              CX_FlowLocationComponentController.createAndSetCaseLocationTest               
    */
    @IsTest
    static void createAndSetCaseLocationTest(){
        CX_SingleRequestMock mockLocationSearch = new CX_SingleRequestMock(200, 'OK', '{"CityName":"NEW YORK","StateCode":"NY","PostalAreaCode":"787021319","RegionNo":"109","ZoneCode":"03"}', null);
        Map<String, String> calloutStrings = getCalloutStrings();

        Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
        mocksMap.put(calloutStrings.get('mockLocationSearch'), mockLocationSearch);
        Test.setMock(HttpCalloutMock.class,  new CX_MultiRequestMock(mocksMap));

        Case tCase = [Select Id,ContactId,AccountId from Case][0];

        Test.startTest();
        CX_FlowLocationWrapper wrapperTest = CX_FlowLocationComponentController.createAndSetCaseLocation(tCase.ContactId, 'TestStreet', '80320', tCase.Id);
        System.assertNotEquals(wrapperTest.selectedLocationId,tCase.AccountId);
        tCase = [Select Id,ContactId,AccountId from Case][0];
        System.assertEquals(wrapperTest.selectedLocationId,tCase.AccountId);
        Test.stopTest();
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        09.07.2021(dd.mm.yyyy)
     * @description    
     * Test case:   Method calls the 
     *              CX_FlowLocationComponentController.createAndSetCaseLocationTest to get an exception               
    */
    @IsTest
    static void createAndSetCaseLocationTestException(){
        String errorMessage = '';
        Test.startTest();
        try{
            CX_FlowLocationWrapper wrapperTest = CX_FlowLocationComponentController.createAndSetCaseLocation(null, 'DUmmyStreet', '', 'dummyId');
        }catch(Exception ex){
            errorMessage = ex.getMessage();
        }
        Test.stopTest();    
        System.assertEquals(errorMessage,'An error occurred while creating the location!');
        
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        09.07.2021(dd.mm.yyyy)
     * @description    
     * Test case:   Method calls the 
     *              CX_FlowLocationComponentController.setSelectedLocation               
    */
    @IsTest
    static void setSelectedLocationTest(){
        String errorMessage = '';
        Case tCase = [Select Id,ContactId,AccountId from Case][0];
        Test.startTest();
        Account location = new Account(Name = 'Test2', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;
        CX_FlowLocationComponentController.setSelectedLocation(tCase.Id, location.Id, tCase.ContactId);
        Test.stopTest();
        tCase = [Select Id,ContactId,AccountId from Case][0];    
        System.assertEquals(tCase.AccountId,location.Id);
        
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        09.07.2021(dd.mm.yyyy)
     * @description    
     * Test case:   Method calls the 
     *              CX_FlowLocationComponentController.setSelectedLocation to get an exception               
    */
    @IsTest
    static void setSelectedLocationExceptionTest(){
        String errorMessage = '';
        Test.startTest();
        try{
            CX_FlowLocationComponentController.setSelectedLocation('dummyId', 'dummylocationId', 'dummyContactId');
        }catch(Exception ex){
            errorMessage = ex.getMessage();
        }
        Test.stopTest();    
        System.assertEquals(errorMessage,'An error occurred while setting the location!');
        
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
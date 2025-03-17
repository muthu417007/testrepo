/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        21.06.2021
 * @description    CX_CreateContactAssetLocationController testMethods
 */
@IsTest(IsParallel = true)
public with sharing class CX_CreateContactAssetLocationCntTest {
    private static final RecordTypeInfo ACCOUNT_LOCATION_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');

    @TestSetup
    static void setup() {
        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;

        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com', AccountId = location.Id);
        insert testContact;

        insert new GEA_AccountContactRelation__c(Account__c = location.Id, Contact__c = testContact.Id);

        insert new Case(AccountId = location.Id, ContactId = testContact.Id );
    }
    
    /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_CreateContactAssetLocationController.validateAsset('ModelNumber') 
     *               
     */
    @IsTest
    static void validateAssetTests() {
        CX_SingleRequestMock mockAssetInfo = new CX_SingleRequestMock(200, 'OK', '{"ProductLineDesc":"MICROWAVE OVEN","ModelNumber":"TEST123456789","ProductTypeDesc":"MICROWAVE OVEN","ProductLineCode":"27","BrandCode":"GEC","ProductTypeCode":"MWO"}', null);
        Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
        Map<String, String> calloutStrings = getCalloutStrings();

        mocksMap.put(calloutStrings.get('mockAssetInfo'), mockAssetInfo);
        Test.setMock(HttpCalloutMock.class,  new CX_MultiRequestMock(mocksMap));
        String returnValue = '';
        
        Test.startTest();
        returnValue = CX_CreateContactAssetLocationController.validateAsset('gunhanTest');
        ModelNumberResponse assetInfo = new ModelNumberResponse();
        assetInfo = (ModelNumberResponse)JSON.deserialize(returnValue, ModelNumberResponse.class);
        System.assertEquals(assetInfo.ModelNumber , 'TEST123456789' );
    }
    /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_CreateContactAssetLocationController.validateAsset() negatif test 
     *               
     */
    @IsTest
    static void validateAssetTestsError() {
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(500, 'Internal Server Error', '', null));
        String errorMessage;
        try{
            Test.startTest();
            CX_CreateContactAssetLocationController.validateAsset('gunhanTest');
        }catch(Exception ex){
            errorMessage = ex.getMessage();
        }
        Test.stopTest(); 
        System.assertEquals(errorMessage.contains('An error occurred while'), true);
        
    }

    /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_CreateContactAssetLocationControllercreateAsset possitiveTest 
     *               
     */
    @IsTest
    static void createAssetTests() {
        CX_SingleRequestMock mockAssetInfo = new CX_SingleRequestMock(200, 'OK', '{"ProductLineDesc":"MICROWAVE OVEN","ModelNumber":"TEST123456789","ProductTypeDesc":"MICROWAVE OVEN","ProductLineCode":"27","BrandCode":"GEC","ProductTypeCode":"MWO"}', null);
        CX_SingleRequestMock mockNewContactInfo = new CX_SingleRequestMock(200, 'OK', '{"ConsumerNo":"193426717","AddressId":"01934267170001","PhoneId":"01934267170001"}', null);
        CX_SingleRequestMock mockNewSiebelAsset = new CX_SingleRequestMock(200, 'OK', '{"OwnershipId":"01903968240002","AssetNumber":"0002","MFGCode":"27","MFGSite":"X102"}', null);

        String asInfo = '{"ProductLineDesc":"MICROWAVE OVEN","ModelNumber":"TEST123456789","ProductTypeDesc":"MICROWAVE OVEN","ProductLineCode":"27","BrandCode":"GEC","ProductTypeCode":"MWO"}';
        Map<String, String> calloutStrings = getCalloutStrings();

        Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
        mocksMap.put(calloutStrings.get('mockAssetInfo'), mockAssetInfo);
        mocksMap.put(calloutStrings.get('mockNewContactInfo'), mockNewContactInfo);
        mocksMap.put(calloutStrings.get('mockNewSiebelAsset'), mockNewSiebelAsset);
        Test.setMock(HttpCalloutMock.class,  new CX_MultiRequestMock(mocksMap));

        Case testCase = [SELECT AccountId, ContactId FROM Case];
        Account testLocation = [SELECT Id FROM Account];

        Test.startTest();
        String result = CX_CreateContactAssetLocationController.createAsset(asInfo, testCase.Id, 'TEST123456789', '123456789', Date.today(),null);
        Test.stopTest();
        System.assertEquals('ok', result);
    }

    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_CreateContactAssetLocationController.createAsset possitiveTest negative             
     */
    @IsTest
    static void createAssetTestsError() {
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(500, 'Internal Server Error', '', null));
        String asInfo = '{"ProductLineDesc":"MICROWAVE OVEN","ModelNumber":"TEST123456789","ProductTypeDesc":"MICROWAVE OVEN","ProductLineCode":"27","BrandCode":"GEC","ProductTypeCode":"MWO"}';
        String errorMessage;
        try{
            Test.startTest();
            String result = CX_CreateContactAssetLocationController.createAsset(asInfo, null, 'TEST123456789', '123456789', Date.today(),null);
            Test.stopTest();
        }catch(Exception ex){
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        System.assertEquals(errorMessage.contains('An error occurred while creating asset'),true);
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_CreateContactAssetLocationController.createContact ! web callouts also tested in the  CX_ContactCreation Test No negative checks!
     */
    @IsTest
    static void createContactTest() {
        CX_SingleRequestMock mockLocationSearch = new CX_SingleRequestMock(200, 'OK', '{"CityName":"NEW YORK","StateCode":"NY","PostalAreaCode":"787021319","RegionNo":"109","ZoneCode":"03"}', null);
        CX_SingleRequestMock mockNewContactInfo = new CX_SingleRequestMock(200, 'OK', '{"ConsumerNo":"193426717","AddressId":"01934267170001","PhoneId":"01934267170001"}', null);
        
        String wrapString = '{"street":"test1","zip":"test2","phone":"5053513684","email":"test@asd.com","firstName":"test1","lastName":"test1","unknownAddress":false,"usePhoneField":true }';

        Map<String, String> calloutStrings = getCalloutStrings();

        Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
        mocksMap.put(calloutStrings.get('mockLocationSearch'), mockLocationSearch);
        mocksMap.put(calloutStrings.get('mockNewContactInfo'), mockNewContactInfo);
        Test.setMock(HttpCalloutMock.class,  new CX_MultiRequestMock(mocksMap));

        Case testCase = new Case(SuppliedEmail = 'test@polsource.com', Phone_Number__c = '1111237496', Status = 'New', Subject = 'Test');
        insert testCase;

        Test.startTest();
        try{
            Contact testContact = CX_CreateContactAssetLocationController.createContact(wrapString, testCase.Id);
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    Method that returns the callout string to be used in the test (to use along the CX_MultiRequestMock class)
     * @return         Map<String, String> - the callout strings map
     */
    private static Map<String, String> getCalloutStrings() {
        Map<String, String> calloutStrings = new Map<String, String>();

        if(CX_Utils.isSandbox()) {
            calloutStrings = new Map<String, String> { 'mockAssetInfo' => 'callout:Sandbox_ValidateModelNumber', 'mockNewContactInfo' => 'callout:Sandbox_CN1_Customer_Number', 'mockNewSiebelAsset' => 'callout:Sandbox_Create_Asset' };
        } else {
            calloutStrings = new Map<String, String> { 'mockAssetInfo' => 'callout:Production_ValidateModelNumber', 'mockNewContactInfo' => 'callout:Production_CN1_Customer_Number', 'mockNewSiebelAsset' => 'callout:Production_Create_Asset' };
        }
        
        return calloutStrings;
    }

}
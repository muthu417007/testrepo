/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        21.06.2021
 * @description    Asset verification tests
 */

@IsTest(IsParallel = true)
public with sharing class CX_AssetVerificationTest {
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
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.06.2021
     * @description    
     * Test case:
     *  1. Mocks the asset info, new contact and new siebel asset integrations
     *  2. Calls the createAsset method with valid data
     *  3. Validates the output, expecting only 1 case asset, and also asserts it's values
     */
    @IsTest
    static void createNewAssetTest() {
        CX_SingleRequestMock mockAssetInfo = new CX_SingleRequestMock(200, 'OK', '{"ProductLineDesc":"MICROWAVE OVEN","ModelNumber":"TEST123456789","ProductTypeDesc":"MICROWAVE OVEN","ProductLineCode":"27","BrandCode":"GEC","ProductTypeCode":"MWO"}', null);
        CX_SingleRequestMock mockNewContactInfo = new CX_SingleRequestMock(200, 'OK', '{"ConsumerNo":"193426717","AddressId":"01934267170001","PhoneId":"01934267170001"}', null);
        CX_SingleRequestMock mockNewSiebelAsset = new CX_SingleRequestMock(200, 'OK', '{"OwnershipId":"01903968240002","AssetNumber":"0002","MFGCode":"27","MFGSite":"X102"}', null);

        Map<String, String> calloutStrings = getCalloutStrings();

        Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
        mocksMap.put(calloutStrings.get('mockAssetInfo'), mockAssetInfo);
        mocksMap.put(calloutStrings.get('mockNewContactInfo'), mockNewContactInfo);
        mocksMap.put(calloutStrings.get('mockNewSiebelAsset'), mockNewSiebelAsset);
        Test.setMock(HttpCalloutMock.class,  new CX_MultiRequestMock(mocksMap));

        Case testCase = [SELECT AccountId, ContactId FROM Case];
        Account testLocation = [SELECT Id FROM Account];

        insert new Asset(AccountId = testLocation.Id);

        Test.startTest();
        List<CX_AssetVerificationWrapper> assets = CX_AssetVerification.getInstance().createAsset('TEST123456789', '123456789', Date.today(), testCase, null,null);
        Test.stopTest();

        System.assertEquals(1, assets[0].caseAssets.size());
        System.assertEquals(1, assets[1].assets.size());
        System.assertNotEquals(assets[0].caseAssets[0].Asset__c, assets[1].assets[0].Id);

        Asset testAsset = assets[0].caseAssets[0].Asset__r;

        System.assertEquals('TEST123456789', testAsset.Model_Number__c);
        System.assertEquals(Date.today(), testAsset.InstallDate);
        System.assertEquals('123456789', testAsset.SerialNumber);
        System.assertEquals('GEC', testAsset.BrandName__c);
        System.assertEquals('MWO', testAsset.Product_Type__c);
        System.assertEquals('27', testAsset.Product_Line__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.06.2021
     * @description    
     * Test case:
     *  1. Mocks the asset info with an error response
     *  2. Calls the createAsset method with valid data
     *  3. Validates if an exception was thrown and it's message
     */
    @IsTest
    static void createNewAssetCalloutErrorTest() {
        Test.setMock(HttpCalloutMock.class, new CX_SingleRequestMock(500, 'Internal Server Error', '', null));

        Case testCase = [SELECT AccountId, ContactId FROM Case];

        String errorMessage;

        Test.startTest();
        try {
            CX_AssetVerification.getInstance().createAsset('TEST123456789', '123456789', Date.today(), testCase, null,null);
        } catch(CalloutException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('Error while retrieving asset info!', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.06.2021
     * @description    
     * Test case:
     *  1. Calls the createAsset method with invalid data, missing the model number
     *  2. Validates if an exception was thrown and it's message
     */
    @IsTest
    static void createNewAssetModelNumberBlankErrorTest() {
        Case testCase = [SELECT AccountId, ContactId FROM Case];
        String errorMessage;

        Test.startTest();
        try {
            CX_AssetVerification.getInstance().createAsset('', '123456789', Date.today(), testCase, null,null);
        } catch(CX_AssetVerification.CX_AssetVerificationException ex) {
            errorMessage = ex.getMessage();
        }
        
        Test.stopTest();

        System.assertEquals('Please enter model number.', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.06.2021
     * @description    
     * Test case:
     *  1. Calls the createAsset method with invalid data, using an invalid model number
     *  2. Validates if an exception was thrown and it's message
     */
    @IsTest
    static void createNewAssetModelNumberInvalidErrorTest() {
        Case testCase = [SELECT AccountId, ContactId FROM Case];
        String errorMessage;

        Test.startTest();
        try {
            CX_AssetVerification.getInstance().createAsset('$#@%$@', '123456789', Date.today(), testCase, null,null);
        } catch(CX_AssetVerification.CX_AssetVerificationException ex) {
            errorMessage = ex.getMessage();
        }
        
        Test.stopTest();

        System.assertEquals('Model Number can only contain alphanumeric characters.', errorMessage);
    }

     /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.06.2021
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
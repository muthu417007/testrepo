/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        06.07.2021(dd.mm.yyyy)
 * @description    CX_FlowMissingItemsController testMethods
 */
@IsTest(IsParallel = true)
public with sharing class CX_FlowLocationAssetsControllerTest {
    private static final RecordTypeInfo ACCOUNT_LOCATION_RT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');

    @TestSetup
    static void setup() {
        Account location = new Account(Name = 'Test', BillingPostalCode = '10017', RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId());
        insert location;

        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com', AccountId = location.Id);
        insert testContact;

        Case testCase =  new Case(AccountId = location.Id, ContactId = testContact.Id,Subject = 'Test Subject', Type = 'Test type' );
        insert testCase;

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
            Asset__c =  testGAsset.Id   
        );
    }
     /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_FlowLocationAssetsController.selectLocationAssets                
     */
    @IsTest
    static void selectLocationAssets() {
        Case tCase = [Select Id,ContactId,AccountId from Case][0];
        
        Asset testGAsset =  new Asset(
            AccountId = tCase.AccountID,
            Model_Number__c = 'test model2',
            SerialNumber = 'test serial2'
        );

        insert testGAsset;

        CX_FlowLocationAssetsWrapper wrap = new CX_FlowLocationAssetsWrapper();

        wrap =  CX_FlowLocationAssetsController.selectLocationAssets(tCase.Id);
        //The assset that created in test setup is attached to case. We should get only one 
        //when we query the location assets
        System.assertEquals(wrap.locationAssets.size(), 1);
    }
    /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_FlowLocationAssetsController.selectLocationAssets  
     *              to cover the empty locationId case               
     */
    @IsTest
    static void selectLocationIdEmpty() {
        Case testCase =  new Case(Subject = 'Test Location Empty', Type = 'LocationEmpty' );
        insert testCase;

        Case tCase = [Select Id,ContactId,AccountId from Case where Type = 'LocationEmpty'][0];

        CX_FlowLocationAssetsWrapper wrap = new CX_FlowLocationAssetsWrapper();
        wrap =  CX_FlowLocationAssetsController.selectLocationAssets(tCase.Id);
        
        //wrapped messageIndacator  should be 'NO_LOCATION_ID'
        System.assertEquals(wrap.messageIndicator, 'NO_LOCATION_ID');
    }
    /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_FlowLocationAssetsController.selectLocationAssets with a dummy case id 
     *              to cover the exception lines               
     */
    @IsTest
    static void selectLocationAssetsException() {
        CX_FlowLocationAssetsWrapper wrap = new CX_FlowLocationAssetsWrapper();
        try{
            //sends a dummy Id to throw an exception
            wrap =  CX_FlowLocationAssetsController.selectLocationAssets('dummy');
        }catch(Exception ex){}
        //wrapped location assets should be null
        System.assertEquals(wrap.locationAssets, null);
    }
    /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_FlowLocationAssetsController.addCaseAsset                
     */
    @IsTest
    static void addCaseAsset() {
        Case tCase = [Select Id,ContactId,AccountId from Case][0];
        
        Asset testGAsset =  new Asset(
            AccountId = tCase.AccountID,
            Model_Number__c = 'test model2',
            SerialNumber = 'test serial2'
        );

        insert testGAsset;

        List<Asset> testList =  CX_FlowLocationAssetsController.addCaseAsset(testGAsset.Id,tCase.Id);
        //GEA_Asset created in the method will be attached to the case  
        //when we query the location assets we should not get any assets. List size should be zero
        System.assertEquals(testList.size(), 0);
    }
    /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_FlowLocationAssetsController.addCaseAsset with a dummy case id and assetId
     *              to cover the exception lines               
     */
    @IsTest
    static void addCaseAssetException() {
        List<Asset> testList = new List<Asset>();
        try{
            //sends a dummy Ids to throw an exception
            testList =  CX_FlowLocationAssetsController.addCaseAsset('dummy','dummy');
        }catch(Exception ex){}
        //return list should be empty when an exception thrown
        System.assertEquals(testList.size(), 0);
    }
}
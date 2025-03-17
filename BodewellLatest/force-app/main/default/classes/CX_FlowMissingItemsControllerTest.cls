/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        06.07.2021(dd.mm.yyyy)
 * @description    CX_FlowMissingItemsController testMethods
 */
@IsTest(IsParallel = true)
public with sharing class CX_FlowMissingItemsControllerTest {
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
            Asset__c  =  testGAsset.Id   
        );
    }

     /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_FlowMissingItemsController.selectCaseItems                
     */
    @IsTest
    static void selectCaseItemsAllFieldsAreFulled() {
        Case tCase = [Select Id,ContactId,AccountId from Case][0];
        
        List<String> returnList = CX_FlowMissingItemsController.selectCaseItems(tCase.Id);
        System.assertEquals(tCase.ContactId, returnList[0]);
        System.assertEquals(tCase.AccountId, returnList[1]);
        System.assertEquals('hasAssets', returnList[2]);

    }
    /**
     * @author         Gunhan GUltekin
     * @company        PolSource
     * @created        28.06.2021
     * @description    
     * Test case:   Controller calls the 
     *              CX_FlowMissingItemsController.selectCaseItems                
     */
    @IsTest
    static void selectCaseItemsAllFieldsAreEmpty() {
        
        Case testCase =  new Case(Subject = 'Test Subject', Type = 'Test type' );
        insert testCase;

        List<String> returnList = CX_FlowMissingItemsController.selectCaseItems(testCase.Id);
        System.assertEquals('emptyContact', returnList[0]);
        System.assertEquals('emptyLocation', returnList[1]);
        System.assertEquals('emptyAsset', returnList[2]);

    }
}
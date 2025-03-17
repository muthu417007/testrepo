/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        03.06.2021
 * @description    Check duplicated cases test
 */
@IsTest
public with sharing class CX_CheckDuplicatedCasesControllerTest {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        03.06.2021
     * @description    
     * Test case:
     *  1. Creates a contact
     *  2. Creates a case to be used as the main one, 3 to be the duplicates and 1 that shouldn't return as duplicated
     *  3. Creates an asset and relations for the cases
     *  4. Calls the getDuplicatedCases method with the case id and the ASM team persona
     *  5. Assert the returned contacts quantity that should be 3
     */
    @IsTest
    static void getDuplicatedCasesASMTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com');
        insert testContact;

        Case currentCase = new Case(Subject = 'TEST', ContactId = testContact.Id);
        insert currentCase;

        List<Case> testCases = new List<Case> { new Case(Subject = 'FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'FW :FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'FW:FW :FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'PolSource', ContactId = testContact.Id) };
        insert testCases;

        Asset asset = new Asset();
        insert asset;

        insert new List<Case_Asset__c> { new Case_Asset__c(Model_Number__c = 'Test', Name='Test', Case__c = currentCase.Id, Asset__c = asset.Id),
                                                            new Case_Asset__c(Model_Number__c = 'Test', Name='Test', Case__c = testCases[0].Id, Asset__c = asset.Id),
                                                            new Case_Asset__c(Model_Number__c = 'Test', Name='Test', Case__c = testCases[1].Id, Asset__c = asset.Id),
                                                            new Case_Asset__c(Model_Number__c = 'Test', Name='Test', Case__c = testCases[2].Id, Asset__c = asset.Id) };
        
        
        Test.startTest();
        List<Case> duplicatedCases = CX_CheckDuplicatedCasesController.getDuplicatedCases(currentCase.Id, 'ASM');
        Test.stopTest();
        
        System.assertEquals(3, duplicatedCases.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        03.06.2021
     * @description    
     * Test case:
     *  1. Creates a contact
     *  2. Creates a case to be used as the main one, 3 to be the duplicates and 1 that shouldn't return as duplicated
     *  3. Calls the getDuplicatedCases method with the case id and the FS CSP team persona
     *  4. Assert the returned contacts quantity that should be 3
     */
    @IsTest
    static void getDuplicatedCasesFSCSPTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com');
        insert testContact;

        Case currentCase = new Case(Subject = 'TEST', ContactId = testContact.Id);
        insert currentCase;

        List<Case> testCases = new List<Case> { new Case(Subject = 'FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'FW :FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'FW:FW :FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'PolSource', ContactId = testContact.Id) };
        insert testCases;
        
        
        Test.startTest();
        List<Case> duplicatedCases = CX_CheckDuplicatedCasesController.getDuplicatedCases(currentCase.Id, 'FS CSP');
        Test.stopTest();
        
        System.assertEquals(3, duplicatedCases.size());
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        03.06.2021
     * @description    
     * Test case:
     *  1. Creates a contact
     *  2. Creates a case to be used as the main one, 3 to be the duplicates and 1 that shouldn't return as duplicated
     *  3. Calls the getDuplicatedCases method with the case id and the GE Store team persona
     *  4. Assert the returned contacts quantity that should be 3
     */
    @IsTest
    static void getDuplicatedCasesGEStoreTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com');
        insert testContact;

        Case currentCase = new Case(Subject = 'TEST', ContactId = testContact.Id);
        insert currentCase;

        List<Case> testCases = new List<Case> { new Case(Subject = 'FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'FW :FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'FW:FW :FW:Test', ContactId = testContact.Id),
                                    new Case(Subject = 'PolSource', ContactId = testContact.Id) };
        insert testCases;
        
        
        Test.startTest();
        List<Case> duplicatedCases = CX_CheckDuplicatedCasesController.getDuplicatedCases(currentCase.Id, 'GE Store');
        Test.stopTest();
        
        System.assertEquals(3, duplicatedCases.size());
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        16.06.2021
     * @description    
     * Test case:
     *  1. Creates a contact
     *  2. Creates a case to be used as the main one, 3 to be the duplicates and 1 that shouldn't return as duplicated
     *  3. Creates an asset and relations for the cases
     *  4. Calls the getDuplicatedCases method with the case id and the PSS team persona
     *  5. Assert the returned cases quantity that should be 4 
     */
    @IsTest
    static void getDuplicatedCasesPSSTest() {
        Contact testContact = new Contact(LastName = 'Test 1', Email = 'test@polsource.com');
        insert testContact;

        Case currentCase = new Case(Subject = 'TEST', ContactId = testContact.Id);
        insert currentCase;

        List<Case> testCases = new List<Case> { 
            new Case(Subject = 'ExactMatch', ContactId = testContact.Id),
            new Case(Subject = 'OneCharDiff', ContactId = testContact.Id),
            new Case(Subject = 'TwoCharsDiff', ContactId = testContact.Id),
            new Case(Subject = 'ThreeCharsDiff', ContactId = testContact.Id),
            new Case(Subject = 'FourCharsDiff', ContactId = testContact.Id),
            new Case(Subject = 'FiveCharsDiff', ContactId = testContact.Id),
            new Case(Subject = 'Different', ContactId = testContact.Id),
            new Case(Subject = 'SerialDiff', ContactId = testContact.Id)
        };
        insert testCases;

        Asset asset = new Asset();
        insert asset;

        insert new List<Case_Asset__c> { 
            new Case_Asset__c(Model_Number__c = '12345678901', Serial_Number__c = '12345678901', Name='Origin', Case__c = currentCase.Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '12345678901', Serial_Number__c = '12345678901', Name='OK--ExactMatch', Case__c = testCases[0].Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '02345678901', Serial_Number__c = '12345678901', Name='OK--OneCharDiff', Case__c = testCases[1].Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '00345678901', Serial_Number__c = '12345678901', Name='OK--TwoCharDiff', Case__c = testCases[2].Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '00045678901', Serial_Number__c = '12345678901', Name='OK--ThreeCharDiff', Case__c = testCases[3].Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '00005678901', Serial_Number__c = '12345678901', Name='NOK--FourCharDiff', Case__c = testCases[4].Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '00000678901', Serial_Number__c = '12345678901', Name='NOK--FiveCharsDiff', Case__c = testCases[5].Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '98765432191', Serial_Number__c = '12345678901', Name='NOK--Different', Case__c = testCases[6].Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '98765432191', Serial_Number__c = '44445678901', Name='NOK--SerialDiffDifferent', Case__c = testCases[6].Id, Asset__c = asset.Id),
            new Case_Asset__c(Model_Number__c = '12345678901', Serial_Number__c = '12345678222', Name='OK--ModelSameSerial3dif', Case__c = testCases[6].Id, Asset__c = asset.Id), 
            new Case_Asset__c(Model_Number__c = '12345678901', Serial_Number__c = '12345672222', Name='NOK--ModelSameSerial4dif', Case__c = testCases[6].Id, Asset__c = asset.Id) 
        };
        
        Test.startTest();
        List<Case> duplicatedCases = CX_CheckDuplicatedCasesController.getDuplicatedCases(currentCase.Id, 'PSS');
        Test.stopTest();
        
        System.assertEquals(5, duplicatedCases.size());
    }

}
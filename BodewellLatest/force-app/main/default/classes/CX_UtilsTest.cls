/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        19.05.2021
 * @description    Utils class tests
 */
@IsTest(IsParallel = true)
public with sharing class CX_UtilsTest {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        27.05.2021
     * @description    Creates the Custom Setting needed for the Logger framework
     */
    @TestSetup
    static void setup() {
        insert new CX_SystemSetting__c(Debug__c = true, Error__c = true, Info__c = true, Log_Purge_Days__c = 14);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    
     * Test case:
     *  1. Creates a custom exception
     *  2. Calls the handler with this exception
     *  3. Asserts the expected user friendly message
     */
    @IsTest
    static void testHandleExceptionMessageWithTwoParameters() {
        Test.startTest();
        Exception ex = new CX_UtilsTestException('Error');
        String errorMessage = CX_Utils.handleExceptionMessage(ex, 'Test Exception');
        Test.stopTest();

        System.assertEquals('Test Exception', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    
     * Test case:
     *  1. Creates a custom exception
     *  2. Calls the handler with this exception and a parameter saying that log is needed
     *  3. Asserts the expected user friendly message and if the log was created
     */
    @IsTest
    static void testHandleExceptionMessageWithLogs() {
        Test.startTest();
        Exception ex = new CX_UtilsTestException('Error');
        String errorMessage = CX_Utils.handleExceptionMessage(ex, 'Test Exception', true);
        Test.stopTest();

        System.assertEquals('Test Exception', errorMessage);

        List<CX_ApplicationLog__c> logs = [SELECT Id FROM CX_ApplicationLog__c WHERE Debug_Level__c = 'Error'];
        System.assertEquals(1, logs.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    
     * Test case:
     *  1. Creates a custom exception simulating a field validation exception
     *  2. Calls the handler with this exception
     *  3. Asserts the expected user friendly message
     */
    @IsTest
    static void testHandleExceptionMessageWithFieldError() {
        Test.startTest();
        Exception ex = new CX_UtilsTestException('FIELD_CUSTOM_VALIDATION_EXCEPTION, Field Error Test: [');
        String errorMessage = CX_Utils.handleExceptionMessage(ex, 'Test Exception');
        Test.stopTest();

        System.assertEquals('Field Error Test', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    
     * Test case:
     *  1. Creates a custom exception
     *  2. Calls a method that will transform the exception in a handled exception to fire
     *  3. Asserts the expected user friendly message and if the log was created
     */
    @IsTest
    static void testThrowHandledException() {
        String errorMessage;

        Test.startTest();
        try {
            Exception ex = new CX_UtilsTestException('Error');
            CX_Utils.throwHandledException(ex, 'Test Exception');
        } catch(AuraHandledException handledException) {
            errorMessage = handledException.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Test Exception', errorMessage);

        List<CX_ApplicationLog__c> logs = [SELECT Id FROM CX_ApplicationLog__c WHERE Debug_Level__c = 'Error'];
        System.assertEquals(1, logs.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        27.05.2021
     * @description    
     * Test case:
     *  1. Creates a String Set with a formatted number
     *  2. Calls a method that will remove the formatting
     *  3. Asserts the expected number without formatting
     */
    @IsTest
    static void testRemoveNumberFormatting() {
        Set<String> testSet = new Set<String>{ '1-5/6-*/*' };

        Test.startTest();
        testSet = CX_Utils.removeNumberFormatting(testSet);
        Test.stopTest();

        System.assert(testSet.contains('156'));
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        27.05.2021
     * @description    
     * Test case:
     *  1. Creates a String with all lower case letters
     *  2. Calls a method that will capitalize the first letter of words
     *  3. Asserts the expected string
     */
    @IsTest
    static void testCapitalizeInitialLetter() {
        Test.startTest();
        String result = CX_Utils.capitalizeInitialLetter('test polSource gea');
        Test.stopTest();

        System.assertEquals(result, 'Test PolSource Gea');
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    Custom exception used in some tests
     */
    private class CX_UtilsTestException extends Exception {}
}
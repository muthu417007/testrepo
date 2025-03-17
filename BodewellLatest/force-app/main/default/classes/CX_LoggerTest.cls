/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.05.2021
 * @description    Logger test
 */
@IsTest
public class CX_LoggerTest {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    
     * Test case:
     *  1. Insert setting for Logger
     *  2. Instantiate CX_Logger
     *  3. Log the message with specific parameters
     *  4. Get Application Log records
     *  5. It should return 1 Application Log record with appropriate field values
     */
    @IsTest
    private static void testLogging() {
        insertSettingForLogger(true, true, true, 1);
        CX_Logger logger = new CX_Logger();
        String level = 'Debug';
        String sourceClass = 'CX_LoggerTest';
        String sourceFunction = 'testLogging';
        String message = 'sampleMessage';

        Test.startTest();
        logger.logMessage(level, sourceClass, sourceFunction, message, null, null, null);
        Test.stopTest();

        List<CX_ApplicationLog__c> existingLogs = [
            SELECT Source__c, Debug_Level__c, Source_Function__c, Message__c
            FROM CX_ApplicationLog__c
        ];

        System.assertEquals(1, existingLogs.size());
        System.assertEquals(level, existingLogs[0].Debug_Level__c);
        System.assertEquals(sourceClass, existingLogs[0].Source__c);
        System.assertEquals(sourceFunction, existingLogs[0].Source_Function__c);
        System.assertEquals(message, existingLogs[0].Message__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    
     * Test case:
     *  1. Insert setting for Logger
     *  2. Logging in default  mode
     *  3. It should logged successfully
     */
    @IsTest
    private static void testLoggingWithReferences() {
        insertSettingForLogger(true, true, true, 1);
        CX_Logger logger = new CX_Logger();
        Boolean exceptionThrown = false;
        try {
            testLogging(logger);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        System.assert( ! exceptionThrown, 'Should log with default mode without exception');
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * Test case:
     *  1. Insert setting for Logger
     *  2. Logging in Platform event mode
     *  3. It should logged successfully
     */
    @IsTest
    private static void testLoggingWithPlatformEvent() {
        insertSettingForLogger(true, true, true, 1);
        CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);
        Boolean exceptionThrown = false;
        try {
            testLogging(logger);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        System.assert( ! exceptionThrown, 'Should log with platform event without exception');
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Test the logging
     * @param          logger - logger instance
     */
    private static void testLogging(CX_Logger logger) {
        String level = 'Debug';
        String sourceClass = 'CX_LoggerTest';
        String sourceFunction = 'testLogging';
        String referenceId = 'referenceId';
        String referenceInfo = 'referenceInfo';
        String message = 'sampleMessage';

        Test.startTest();
        logger.logMessage(level, sourceClass,sourceFunction, referenceId, referenceInfo, message, null, null, null);
        Test.stopTest();

        List<CX_ApplicationLog__c> existingLogs = [
            SELECT Source__c, Debug_Level__c, Source_Function__c, Message__c, Reference_Id__c, Reference_Info__c
            FROM CX_ApplicationLog__c
        ];

        System.assertEquals(1, existingLogs.size());
        System.assertEquals(level, existingLogs[0].Debug_Level__c);
        System.assertEquals(sourceClass, existingLogs[0].Source__c);
        System.assertEquals(sourceFunction, existingLogs[0].Source_Function__c);
        System.assertEquals(message, existingLogs[0].Message__c);
        System.assertEquals(referenceId, existingLogs[0].Reference_Id__c);
        System.assertEquals(referenceInfo, existingLogs[0].Reference_Info__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Insert the custom setting for logger
     * @param          debugFlag - whether debug level is enabled or not
     * @param          errorFlag - whether error level is enabled or not
     * @param          infoFlag - whether info level is enabled or not
     * @param          logPurgeDays - days until log is purged
     */
    private static void insertSettingForLogger(Boolean debugFlag, Boolean errorFlag, Boolean infoFlag, Integer logPurgeDays) {
        CX_SystemSetting__c setting = new CX_SystemSetting__c(Debug__c = debugFlag, Error__c = errorFlag, Info__c = infoFlag, Log_Purge_Days__c = logPurgeDays);
        insert setting;
    }
}
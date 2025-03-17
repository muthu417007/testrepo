/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.05.2021
 * @description    Application log event trigger handler
 * @testClass      CX_LoggerTest
 */
public without sharing class CX_ApplicationLogEventTriggerHandler {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Application log event trigger handler constructor
     */
    private CX_ApplicationLogEventTriggerHandler() {}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Insert application logs
     * @param          newList - list of new application log events
     */
    public static void afterInsert(List<CX_ApplicationLogEvents__e> newList) {
        List<CX_ApplicationLog__c> applicationLogs = new List<CX_ApplicationLog__c>();

        for (CX_ApplicationLogEvents__e applicationLogEvent : newList) {
            CX_ApplicationLog__c applicationLog = new CX_ApplicationLogBuilder()
                    .withDebugLevel(applicationLogEvent.Debug_Level__c)
                    .withIntegrationPayload(applicationLogEvent.Integration_Payload__c)
                    .withLogCode(applicationLogEvent.Log_Code__c)
                    .withMessage(applicationLogEvent.Message__c)
                    .withReferenceId(applicationLogEvent.Reference_Id__c)
                    .withReferenceInfo(applicationLogEvent.Reference_Info__c)
                    .withSource(applicationLogEvent.Source__c)
                    .withSourceFunction(applicationLogEvent.Source_Function__c)
                    .withStackTrace(applicationLogEvent.Stack_Trace__c)
                    .withTimer(applicationLogEvent.Timer__c)
                    .getRecord();
            applicationLogs.add(applicationLog);
        }

        insert applicationLogs;
    }
}
/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.05.2021
 * @description    Application log builder
 * @testClass      CX_LoggerTest
 */
public without sharing class CX_ApplicationLogBuilder {

    private CX_ApplicationLog__c applicationLog;

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Application log builder constructor
     */
    public CX_ApplicationLogBuilder() {
        applicationLog = new CX_ApplicationLog__c();
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log debug level
     * @param          debugLevel - debug level
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withDebugLevel(String debugLevel) {
        applicationLog.Debug_Level__c = debugLevel;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set integration payload
     * @param          integrationPayload - integration Payload string
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withIntegrationPayload(String integrationPayload) {
        applicationLog.Integration_Payload__c = integrationPayload;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log code
     * @param          logCode - log code
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withLogCode(String logCode) {
        applicationLog.Log_Code__c = logCode;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log message
     * @param          message - log message
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withMessage(String message) {
        applicationLog.Message__c = message;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log reference id
     * @param          referenceId - reference id
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withReferenceId (String referenceId) {
        applicationLog.Reference_Id__c = referenceId;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log reference info
     * @param          referenceInfo - reference info
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withReferenceInfo(String referenceInfo) {
        applicationLog.Reference_Info__c = referenceInfo;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log source class
     * @param          source - source class
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withSource(String source) {
        applicationLog.Source__c = source;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log source function
     * @param          sourceFunction - source function
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withSourceFunction(String sourceFunction) {
        applicationLog.Source_Function__c = sourceFunction;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log stack trace
     * @param          stackTrace - stack trace
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withStackTrace(String stackTrace) {
        applicationLog.Stack_Trace__c = stackTrace;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Set application log timer
     * @param          timer - Timer (time taken)
     * @return         CX_ApplicationLogBuilder - return "this"
     */
    public CX_ApplicationLogBuilder withTimer(Decimal timer) {
        applicationLog.Timer__c = timer;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Save application log and returns builder instance
     * @return         CX_ApplicationLogBuilder - insert the CX_ApplicationLog__c record and return "this"
     */
    public CX_ApplicationLogBuilder save() {
        insert applicationLog;
        return this;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Get application log record
     * @return         CX_ApplicationLog__c - return application log object
     */
    public CX_ApplicationLog__c getRecord() {
        return applicationLog;
    }
}
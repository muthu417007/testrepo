/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.05.2021
 * @description    Logger class for handling logging messages
 * @testClass      CX_LoggerTest
 */
public without sharing class CX_Logger {

    public enum LogMode {
        MODE_DML, MODE_PLATFORM_EVENT
    }

    private LogMode loggerMode;

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Logger constructor with no parameters
     */
    public CX_Logger() {
        this(LogMode.MODE_DML);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Logger constructor with one parameter
     * @param          mode - log mode
     */
    public CX_Logger(LogMode mode) {
        this.loggerMode = mode;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Logs message based on parameters
     * @param          logLevel - log level
	 * @param          sourceClass - source class
	 * @param          sourceFunction - source function
	 * @param          logMessage - message to be logged
	 * @param          payLoad - pay load
	 * @param          ex - original exception
	 * @param          timeTaken - time taken
     */
    public void logMessage(String logLevel, String sourceClass, String sourceFunction, String logMessage, String payLoad, Exception ex, Long timeTaken) {

        CX_ApplicationLogWrapper msg = new CX_ApplicationLogWrapper();

        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = null;
        msg.referenceInfo = '';
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;

        logMessage(msg);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Logs message based on parameters
     * @param          logLevel - log level
	 * @param          sourceClass - source class
	 * @param          sourceFunction - source function
     * @param          referenceId    reference Id
     * @param          referenceInfo  reference info
	 * @param          logMessage - message to be logged
	 * @param          payLoad - pay load
	 * @param          ex - original exception
	 * @param          timeTaken - time taken
     */
    public void logMessage(String logLevel, String sourceClass, String sourceFunction, String referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, Long timeTaken) {

        CX_ApplicationLogWrapper msg = new CX_ApplicationLogWrapper();

        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = referenceId;
        msg.referenceInfo = referenceInfo;
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;

        logMessage(msg);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Logs message
     * @param          appLog - application log wrapper
     */
    public void logMessage(CX_ApplicationLogWrapper appLog) {
        List<CX_ApplicationLogWrapper> appLogs = new List<CX_ApplicationLogWrapper>();
        appLogs.add (appLog);
        logMessage (appLogs);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Logs message
     * @param          appLogs - application log wrapper list
     */
    public void logMessage(List<CX_ApplicationLogWrapper> appLogs) {

        List<CX_ApplicationLog__c> insertAppLogs = new List<CX_ApplicationLog__c>();
        List<CX_ApplicationLogEvents__e> applicationLogEventsList = new List<CX_ApplicationLogEvents__e>();

        for (CX_ApplicationLogWrapper appLog : appLogs) {

            if (isDebugLevelEnabled(appLog.debugLevel)) {
                if (loggerMode == LogMode.MODE_DML) {
                    insertAppLogs.add(createApplicationLog(appLog));
                }
                if (loggerMode == LogMode.MODE_PLATFORM_EVENT) {
                    applicationLogEventsList.add(createApplicationLogEvent(appLog));
                }
            }
        }

        if (insertAppLogs.size() != 0) {
            insert insertAppLogs;
        }

        if (!applicationLogEventsList.isEmpty()) {
            EventBus.publish(applicationLogEventsList);
        }

    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Creates a application log record using a application log wrapper
     * @param          appLog - application log wrapper
     * @return         CX_ApplicationLog__c - a application log record using the wrapper data
     */
    private CX_ApplicationLog__c createApplicationLog(CX_ApplicationLogWrapper appLog) {
        CX_ApplicationLog__c log = new CX_ApplicationLog__c();

        log.Source__c = appLog.source;
        log.Source_Function__c = appLog.sourceFunction;
        log.Reference_Id__c = appLog.referenceId;
        log.Reference_Info__c = appLog.referenceInfo;
        log.Message__c = appLog.logMessage;
        log.Integration_Payload__c = appLog.payload;

        if (appLog.ex != null) {
            log.Stack_Trace__c = appLog.ex.getStackTraceString();
            log.Message__c = applog.ex.getMessage();
        }

        log.Debug_Level__c = appLog.debugLevel;
        log.Log_Code__c = appLog.logCode;
        log.Timer__c = appLog.timer;

        return log;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Creates a application log event record using a application log wrapper
     * @param          appLog - application log wrapper
     * @return         CX_ApplicationLogEvents__e - a application log event record using the wrapper data
     */
    private CX_ApplicationLogEvents__e createApplicationLogEvent(CX_ApplicationLogWrapper appLog) {
        CX_ApplicationLogEvents__e applicationLogEvents = new CX_ApplicationLogEvents__e();
        applicationLogEvents.Debug_Level__c = appLog.debugLevel;
        applicationLogEvents.Integration_Payload__c = appLog.payload;
        applicationLogEvents.Log_Code__c = appLog.logCode;
        applicationLogEvents.Message__c = appLog.logMessage;
        applicationLogEvents.Reference_Id__c = appLog.referenceId;
        applicationLogEvents.Reference_Info__c = appLog.referenceInfo;
        applicationLogEvents.Source__c = appLog.source;
        applicationLogEvents.Source_Function__c = appLog.sourceFunction;
        applicationLogEvents.Timer__c = appLog.timer;

        if (appLog.ex != null) {
            applicationLogEvents.Stack_Trace__c = appLog.ex.getStackTraceString();
            applicationLogEvents.Message__c = applog.ex.getMessage();
        }

        return applicationLogEvents;

    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.05.2021
     * @description    Checks if the debug level is enabled
     * @param          debugLevel - debug level
     * @return         Boolean - Whether the debug level is enabled or not
     */
    private Boolean isDebugLevelEnabled(String debugLevel) {
        Set<String> settings = Schema.SObjectType.CX_SystemSetting__c.fields.getMap().keySet();
        return settings.contains(debugLevel.toLowerCase() + '__c')
                && CX_SystemSetting__c.getInstance().get(debugLevel + '__c') != null
                && Boolean.valueOf(CX_SystemSetting__c.getInstance().get(debugLevel + '__c'));
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Logs an error in a callout
     * @param          HttpRequest - request
     * @param          HttpResponse - response
     * @param          String - The source class
     * @param          String - The source function
     * @param          String - The action being made when the error ocurred
     */
    public void logCalloutError(HttpRequest request, HttpResponse response, String sourceClass, String sourceFunction, String action) {
        CX_ApplicationLogWrapper logWrapper = new CX_ApplicationLogWrapper();
        logWrapper.debugLevel = 'Error';
        logWrapper.source = sourceClass;
        logWrapper.sourceFunction = sourceFunction;
        logWrapper.logMessage = 'Error while ' + action + '. Status: ' + response.getStatusCode() + ' ' + response.getStatus() 
                                + '\n\nRequest Payload: \n' + request.getBody();
        logWrapper.payload = response.getBody();

        this.logMessage(logWrapper);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.06.2021
     * @description    Logs an exception using Platform Events
     * @param          Exception - The fired exception
     * @param          String - The source class
     * @param          String - The function that handled the exception
     */
    public void logError(Exception ex, String sourceClass, String sourceFunction) {
        CX_ApplicationLogWrapper logWrapper = new CX_ApplicationLogWrapper();
        logWrapper.debugLevel = 'Error';
        logWrapper.source = sourceClass;
        logWrapper.sourceFunction = sourceFunction;
        logWrapper.ex = ex;

        new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT).logMessage(logWrapper);
    }
}
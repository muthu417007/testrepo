/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        17.05.2021
 * @description    Class for handling Session Time logic
 * @testClass      CX_SessionTimerTest
 */
public without sharing class CX_SessionTimer {
    
    private static final CX_SessionTimer INSTANCE = new CX_SessionTimer();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Returns the singleton instance
     * @return         CX_SessionTimer - a CX_SessionTimer singleton instance
     */
	public static CX_SessionTimer getInstance() {
		return INSTANCE;
	}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Handles the logic for CX_SessionTime__c record saving from a wrapper variable
     * @param          CX_SessionTimeWrapper - Session time wrapper
     */
    public void saveSession(CX_SessionTimeWrapper sessionWrapper) {
        List<CX_SessionTime__c> existingSession = CX_SessionTimeDAO.getInstance().getSession(sessionWrapper.caseId, UserInfo.getUserId(), sessionWrapper.voiceCallId, sessionWrapper.uniqueId);
            
        if(existingSession.isEmpty()) {
            createNewSession(sessionWrapper);
        }
        else {
            updateSession(sessionWrapper, existingSession[0].Id);
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Handles the logic for CX_SessionTime__c record creation from a wrapper variable
     * @param          CX_SessionTimeWrapper - Session time wrapper
     */
    private void createNewSession(CX_SessionTimeWrapper sessionWrapper) {
        CX_SessionTime__c newSession = new CX_SessionTime__c();
        newSession.Case__c = sessionWrapper.caseId;
        newSession.Agent__c = UserInfo.getUserId();
        newSession.VoiceCall__c = sessionWrapper.voiceCallId;
        newSession.Date__c = sessionWrapper.sessionDate;
        
        newSession.UniqueKey__c = sessionWrapper.uniqueId;
        newSession.Manual_Entry__c = sessionWrapper.isManual;
        newSession.Status__c = sessionWrapper.status;
        newSession.Source__c = sessionWrapper.source;
        newSession.Type__c = sessionWrapper.isManual ? 'Manual' : 'Automatic';
        
        Integer sessionSeconds = getSessionDurationInSeconds(sessionWrapper);
        newSession.Duration__c = sessionSeconds;
        
        if(sessionSeconds > 0) {
            insert newSession;
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Handles the logic for CX_SessionTime__c record update from a wrapper variable
     * @param          CX_SessionTimeWrapper - Session time wrapper
     * @param          Id - The Id of the existing session
     */
    private void updateSession(CX_SessionTimeWrapper sessionWrapper, Id sessionTimeId) {
        CX_SessionTime__c session = new CX_SessionTime__c(Id = sessionTimeId);

        Integer sessionSeconds = getSessionDurationInSeconds(sessionWrapper);
        session.Duration__c = sessionSeconds;

        if(sessionSeconds > 0) {
            update session;
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Returns the session duration in seconds, using the sessionSeconds if available, or the sessionTime string using the "HH:MM:SS" format
     * @param          CX_SessionTimeWrapper - Session time wrapper
     * @return         Integer - The session duration in seconds
     */
    @testVisible
    private Integer getSessionDurationInSeconds(CX_SessionTimeWrapper sessionWrapper) {
        if(sessionWrapper.sessionSeconds != null && sessionWrapper.sessionSeconds > 0) {
            return sessionWrapper.sessionSeconds;
        }
        
        String[] sessionTime = sessionWrapper.sessionTime.split(':');
        Integer hours = Integer.valueOf(sessionTime[0]);
        Integer minutes = Integer.valueOf(sessionTime[1]);
        Integer seconds = Integer.valueOf(sessionTime[2]);

        return seconds + (minutes * 60) + (hours * 3600);
    }
}
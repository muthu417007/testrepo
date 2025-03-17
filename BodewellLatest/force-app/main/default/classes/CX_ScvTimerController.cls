/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        17.05.2021
 * @description    Class for handling SCV Session Time logic
 * @testClass      CX_ScvTimerControllerTest
 */
public without sharing class CX_ScvTimerController {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Returns the sessions for a voice call
     * @param          Id - Voice call Id
     * @return         List<CX_SessionTime__c> - A list of sessions
     */
    @AuraEnabled
    public static List<CX_SessionTime__c> getExistingSessions(Id voiceCallId) {
        return CX_SessionTimeDAO.getInstance().getVoiceCallSessions(voiceCallId);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        18.05.2021
     * @description    Returns a ongoing voice call
     * @param          Id - Voice call Id
     * @return         List<VoiceCall> - A list with 0 or 1 voice call record
     */
    @AuraEnabled
    public static List<VoiceCall> getOngoingVoiceCall(Id voiceCallId) {
        return CX_VoiceCallDAO.getInstance().getOngoingVoiceCall(voiceCallId);
    }
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        18.05.2021
     * @description    Returns the saved session
     * @param          String - A JSON from the CX_SessionTimeWrapper class
     * @return         List<CX_SessionTime__c> - A list of sessions for a voice call
     */
    @AuraEnabled
    public static List<CX_SessionTime__c> saveSession(String sessionStr) {   
        CX_SessionTimeWrapper sessionWrapper = (CX_SessionTimeWrapper) JSON.deserialize(sessionStr, CX_SessionTimeWrapper.class);

        try {    
            CX_SessionTimer.getInstance().saveSession(sessionWrapper);

        } catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred when saving a new session!');
        }
        
        return getExistingSessions(sessionWrapper.voiceCallId);
    }
}
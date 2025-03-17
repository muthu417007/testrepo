/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        21.05.2021
 * @description    Class for handling Omni Channel Session Time logic
 * @testClass      CX_OmniChannelTimerControllerTest
 */
public with sharing class CX_OmniChannelTimerController {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.05.2021
     * @description    Returns today's sessions for a omni channel user
     * @return         List<CX_SessionTime__c> - A list of sessions
     */
    @AuraEnabled
    public static List<CX_SessionTime__c> getExistingSessions() {
        return CX_SessionTimeDAO.getInstance().getOmniChannelSessions(UserInfo.getUserId());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.05.2021
     * @description    Saves a session and returns a list of the user's Omni channel sessions
     * @param          String - A JSON from the CX_SessionTimeWrapper class
     * @return         List<CX_SessionTime__c> - A list of sessions for a omni channel agent
     */
    @AuraEnabled
    public static List<CX_SessionTime__c> saveSession(String sessionStr) {   
        CX_SessionTimeWrapper sessionWrapper = (CX_SessionTimeWrapper) JSON.deserialize(sessionStr, CX_SessionTimeWrapper.class);

        try {    
            CX_SessionTimer.getInstance().saveSession(sessionWrapper);

        } catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred when saving a new session!');
        }
        
        return getExistingSessions();
    }
}
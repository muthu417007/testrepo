/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        17.05.2021
 * @description    Class used to keep Session Time queries
 */
public inherited sharing class CX_SessionTimeDAO {
    private static final CX_SessionTimeDAO INSTANCE = new CX_SessionTimeDAO();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Returns the singleton instance
     * @return         CX_SessionTimeDAO - a CX_SessionTimeDAO singleton instance
     */
	public static CX_SessionTimeDAO getInstance() {
		return INSTANCE;
	}

    private CX_SessionTimeDAO() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Returns the sessions for a voice call
     * @param          Id - Voice call id
     * @return         List<CX_SessionTime__c> - A list of sessions
     */
    public List<CX_SessionTime__c> getVoiceCallSessions(Id voiceCallId) {
        return [
            SELECT
                Agent__r.Name,
                Date__c,
                Duration__c,
                Status__c,
                CreatedDate
            FROM 
                CX_SessionTime__c 
            WHERE 
                VoiceCall__c = :voiceCallId 
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.05.2021
     * @description    Returns today's sessions for a omni channel user
     * @param          Id - User Id
     * @return         List<CX_SessionTime__c> - A list of sessions
     */
    public List<CX_SessionTime__c> getOmniChannelSessions(Id userId) {
        return [
            SELECT
                Agent__c,
                Agent__r.Name,
                Date__c,
                Duration__c,
                Status__c,
                CreatedDate
            FROM 
                CX_SessionTime__c 
            WHERE 
                Agent__c = :userId
                AND Source__c = 'Omni Channel'
                AND Date__c = TODAY
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.05.2021
     * @description    Returns a single session
     * @param          Id - Case Id
     * @param          Id - Agent Id
     * @param          Id - Voice call id
     * @param          String - Session's unique key
     * @return         List<CX_SessionTime__c> - A list with 0 or 1 session
     */
    public List<CX_SessionTime__c> getSession(Id caseId, Id agentId, Id voiceCallId, String uniqueKey) {
        String query = '';
        query += 'SELECT  ';
        query += '    Id  ';
        query += 'FROM  ';
        query += '    CX_SessionTime__c ';
        query += 'WHERE  ';
        query += '    Agent__c = :agentId ';
        query += '    AND UniqueKey__c = :uniqueKey ';

        if(String.isNotBlank(caseId)) {
            query += '    AND Case__c = :caseId  ';
        }
        
        if(String.isNotBlank(voiceCallId)) {
            query += '    AND VoiceCall__c = :voiceCallId  ';
        }
        
        return Database.query(query);
    }
}
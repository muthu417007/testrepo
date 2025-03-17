/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        24.05.2021
 * @description    Omni Channel session time test
 */
@IsTest(IsParallel = true)
public with sharing class CX_OmniChannelTimerControllerTest {    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        24.05.2021
     * @description    
     * Test case:
     *  1. Prepares the wrapper with mock data
     *  2. Calls the saveSession method with mock data
     *  3. Assert the returned session record values
     */
    @IsTest
    static void testSessionCreation() {
        CX_SessionTimeWrapper sessionWrapper = getSessionMockData();
        
        Test.startTest();
        List<CX_SessionTime__c> sessionList = CX_OmniChannelTimerController.saveSession(JSON.serialize(sessionWrapper));
        Test.stopTest();
        
        System.assertEquals(1, sessionList.size());

        CX_SessionTime__c session = sessionList[0];
        System.assertEquals(UserInfo.getName(), session.Agent__r.Name);
        System.assertEquals(sessionWrapper.sessionDate, session.Date__c);
        System.assertEquals(sessionWrapper.status, session.Status__c);
        System.assertEquals(3723, session.Duration__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        24.05.2021
     * @description    
     * Test case:
     *  1. Prepares the wrapper with mock data
     *  2. Calls the saveSession method with mock data to cause a exception
     *  3. Assert the exception message
     */
    @IsTest
    static void testSessionCreationWithError() {
        CX_SessionTimeWrapper sessionWrapper = getSessionMockData();
        sessionWrapper.sessionSeconds = null;
        sessionWrapper.sessionTime = null;

        String errorMessage;
        
        Test.startTest();
        try {
            CX_OmniChannelTimerController.saveSession(JSON.serialize(sessionWrapper));
        } catch(AuraHandledException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('An error occurred when saving a new session!', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        24.05.2021
     * @description    Helper method for creating the wrapper with mock information
     * @return         CX_SessionTimeWrapper - Session time wrapper
     */
    private static CX_SessionTimeWrapper getSessionMockData() {
        CX_SessionTimeWrapper sessionWrapper = new CX_SessionTimeWrapper();
        sessionWrapper.sessionDate = Date.today();
        sessionWrapper.sessionTime = '01:02:03';
        sessionWrapper.sessionSeconds = null;
        sessionWrapper.status = 'Test';
        sessionWrapper.source = 'Omni Channel';
        sessionWrapper.uniqueId = '123456789';
        sessionWrapper.isManual = true;

        return sessionWrapper;
    }
}
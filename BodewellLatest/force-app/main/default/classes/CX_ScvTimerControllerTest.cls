/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        19.05.2021
 * @description    SCV Session time test
 */
@IsTest(IsParallel = true)
public with sharing class CX_ScvTimerControllerTest {
    @testSetup
    static void setup() {
        insert new Case();
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    
     * Test case:
     *  1. Select a case created in the setup
     *  2. Prepares the wrapper with mock data
     *  3. Calls the saveSession method with mock data
     *  4. Assert the returned session record values
     */
    @IsTest
    static void testSessionCreation() {
        Case testCase = [SELECT Id FROM Case];
        CX_SessionTimeWrapper sessionWrapper = getSessionMockData(testCase);
        
        Test.startTest();
        List<CX_SessionTime__c> sessionList = CX_ScvTimerController.saveSession(JSON.serialize(sessionWrapper));
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
     * @created        11.06.2021
     * @description    
     * Test case:
     *  1. Query for Voice Call
     *  2. No Voice Call should be returned
     */
    @IsTest
    static void testGetOngoingVoiceCall() {
        
        Test.startTest();
        List<VoiceCall> voiceCalls = CX_ScvTimerController.getOngoingVoiceCall('0LQ0m00000001eWGAQ');
        Test.stopTest();
        
        System.assertEquals(0, voiceCalls.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    
     * Test case:
     *  1. Select a case created in the setup
     *  2. Prepares the wrapper with mock data
     *  3. Calls the saveSession method with mock data to cause a exception
     *  4. Assert the exception message
     */
    @IsTest
    static void testSessionCreationWithError() {
        Case testCase = [SELECT Id FROM Case];
        CX_SessionTimeWrapper sessionWrapper = getSessionMockData(testCase);
        sessionWrapper.sessionSeconds = null;
        sessionWrapper.sessionTime = null;

        String errorMessage;
        
        Test.startTest();
        try {
            CX_ScvTimerController.saveSession(JSON.serialize(sessionWrapper));
        } catch(AuraHandledException ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals('An error occurred when saving a new session!', errorMessage);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    Helper method for creating the wrapper with mock information
     * @param          Case - Test Case record
     * @return         CX_SessionTimeWrapper - Session time wrapper
     */
    private static CX_SessionTimeWrapper getSessionMockData(Case testCase) {
        CX_SessionTimeWrapper sessionWrapper = new CX_SessionTimeWrapper();
        sessionWrapper.caseId = testCase.Id;
        sessionWrapper.sessionDate = Date.today();
        sessionWrapper.sessionTime = '01:02:03';
        sessionWrapper.sessionSeconds = null;
        sessionWrapper.status = 'Test';
        sessionWrapper.source = 'Voice Call';
        sessionWrapper.uniqueId = '123456789';
        sessionWrapper.isManual = true;

        return sessionWrapper;
    }
}
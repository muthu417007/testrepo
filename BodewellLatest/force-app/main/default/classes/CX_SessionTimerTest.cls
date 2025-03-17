/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        18.05.2021
 * @description    Session time test
 */
@IsTest(IsParallel = true)
public with sharing class CX_SessionTimerTest {
    @testSetup
    static void setup() {
        insert new Case();
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        18.05.2021
     * @description    
     * Test case:
     *  1. Select a case created in the setup
     *  2. Prepares the wrapper with mock data
     *  3. Calls the saveSession method with mock data
     *  4. Query for the newly created session
     *  5. Assert all saved values
     */
    @IsTest
    static void testSessionCreationWithoutSeconds() {
        Case testCase = [SELECT Id FROM Case];
        CX_SessionTimeWrapper sessionWrapper = getSessionMockData(testCase);
        
        Test.startTest();
        CX_SessionTimer.getInstance().saveSession(sessionWrapper);
        Test.stopTest();

        List<CX_SessionTime__c> sessionList = [SELECT Agent__c, Date__c, UniqueKey__c, Manual_Entry__c, Status__c, Source__c, Type__c, Duration__c FROM CX_SessionTime__c WHERE Case__c = :testCase.Id];
        
        System.assertEquals(1, sessionList.size());

        CX_SessionTime__c session = sessionList[0];
        System.assertEquals(UserInfo.getUserId(), session.Agent__c);
        System.assertEquals(sessionWrapper.sessionDate, session.Date__c);
        System.assertEquals(sessionWrapper.uniqueId, session.UniqueKey__c);
        System.assertEquals(sessionWrapper.isManual, session.Manual_Entry__c);
        System.assertEquals(sessionWrapper.status, session.Status__c);
        System.assertEquals(sessionWrapper.source, session.Source__c);
        System.assertEquals('Manual', session.Type__c);
        System.assertEquals(3723, session.Duration__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        18.05.2021
     * @description    
     * Test case:
     *  1. Select a case created in the setup
     *  2. Prepares the wrapper with mock data
     *  3. Calls the saveSession method with mock data
     *  4. Query for the newly created session
     *  5. Assert if the session Duration matches the wrapper sessionSeconds
     */
    @IsTest
    static void testSessionCreationWithSeconds() {
        Case testCase = [SELECT Id FROM Case];
        CX_SessionTimeWrapper sessionWrapper = getSessionMockData(testCase);
        sessionWrapper.sessionSeconds = 3723;
        
        Test.startTest();
        CX_SessionTimer.getInstance().saveSession(sessionWrapper);
        Test.stopTest();

        List<CX_SessionTime__c> sessionList = [SELECT Duration__c FROM CX_SessionTime__c WHERE Case__c = :testCase.Id];

        CX_SessionTime__c session = sessionList[0];
        System.assertEquals(3723, session.Duration__c);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        18.05.2021
     * @description    
     * Test case:
     *  1. Select a case created in the setup
     *  2. Prepares the wrapper with mock data
     *  3. Prepares a existing session 
     *  4. Calls the saveSession method with mock data
     *  5. Query for the updated session
     *  6. Assert if the session Duration was updated according to the wrapper duration
     */
    @IsTest
    static void testSessionUpdate() {
        Case testCase = [SELECT Id FROM Case];
        CX_SessionTimeWrapper sessionWrapper = getSessionMockData(testCase);
        sessionWrapper.sessionSeconds = 4321;

        CX_SessionTime__c existingSession = new CX_SessionTime__c();
        existingSession.Case__c = sessionWrapper.caseId;
        existingSession.Agent__c = UserInfo.getUserId();
        existingSession.Date__c = sessionWrapper.sessionDate;
        existingSession.UniqueKey__c = sessionWrapper.uniqueId;
        existingSession.Manual_Entry__c = false;
        existingSession.Status__c = sessionWrapper.status;
        existingSession.Source__c = sessionWrapper.source;
        existingSession.Type__c = 'Automatic';
        existingSession.Duration__c = 1234;
        insert existingSession;
        
        Test.startTest();
        CX_SessionTimer.getInstance().saveSession(sessionWrapper);
        Test.stopTest();

        existingSession = [SELECT Duration__c FROM CX_SessionTime__c WHERE Id = :existingSession.Id];
        System.assertEquals(4321, existingSession.Duration__c);
    }

     /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        18.05.2021
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
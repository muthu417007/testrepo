@IsTest
public with sharing class PS_UserSessionWebServiceAPITest {

    private static final String CLASS_NAME = PS_UserSessionWebServiceAPITest.class
            .getName()
            .substring(0, 15);
    private static final String RET_URL_DOMAIN = 'https://return.url.com';
    private static final String TEST_APP_NAME = 'TestApp';
    private static final String CLIENT_ID = 'bry7v12hobgfka9ih70jpkqo218p8hq';
    private static final String CLIENT_SECRET = '78d5d7534caa02a64b7c929001f0c03631fabac71364452ba0c9707c192db3d8';
    private static final String AUTH_TOKEN = 'pc9ico6zzawnat9r4nq2iflaqipllko';
    private static final String STORE_HASH = 'awav9ocqu';

    @TestSetup
    public static void createData() {
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
        PS_TestHelper.createGuestUser(CLASS_NAME);
    }


    @IsTest
    public static void shouldDeleteUserSession_WhenValidSessionIdPassed() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        String sessionId = portalUser.Customer_IdP_Session_Id__c;

        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        ConnectedApplication connectedApplication;
        System.runAs(users.get(0)) {
            connectedApplication =
                    UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            UserProvAccount userProvAccount = new UserProvAccount();
            userProvAccount.ConnectedAppId = connectedApplication.Id;
            userProvAccount.LinkState = 'linked';
            userProvAccount.Status = 'Active';
            userProvAccount.SalesforceUserId = portalUser.Id;
            userProvAccount.ExternalUserId = '12345';
            insert userProvAccount;
        }

        BigCommerce_Connection__c bigCommerceConnection = new BigCommerce_Connection__c();
        bigCommerceConnection.Domain__c = RET_URL_DOMAIN;
        bigCommerceConnection.Connected_App_Name__c = TEST_APP_NAME;
        bigCommerceConnection.Connected_App_Id__c = connectedApplication.Id;
        bigCommerceConnection.Client_Id__c = CLIENT_ID;
        bigCommerceConnection.Client_Secret__c = CLIENT_SECRET;
        bigCommerceConnection.Auth_Token__c = AUTH_TOKEN;
        bigCommerceConnection.Store_Hash__c = STORE_HASH;
        bigCommerceConnection.Preview_Key__c = 'testPreviewKey';
        insert bigCommerceConnection;

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            PS_AuthSessionService.testAuthSessionsLoginHistoryApplications = new List<String>{
                    TEST_APP_NAME
            };
            Test.setMock(
                    HttpCalloutMock.class,
                    new PS_UserSessionTestRESTMockGenerator(true)
            );

            RestRequest request = new RestRequest();
            request.httpMethod = 'DELETE';
            request.requestURI = '/customer-idm/user/v1/session/' + sessionId;
            RestContext.request = request;
            RestContext.response = new RestResponse();

            PS_UserSessionWebServiceAPI.deleteSession();

            RestResponse restResponse = RestContext.response;
            Test.stopTest();

            System.assertEquals(
                    204,
                    restResponse.statusCode,
                    'Invalid status code returned'
            );
        }

        System.assertNotEquals(
                sessionId,
                [
                        SELECT Customer_IdP_Session_Id__c
                        FROM User
                        WHERE Id = :portalUser.Id
                        LIMIT 1
                ].Customer_IdP_Session_Id__c,
                'New User session Id should have been generated'
        );
    }

    @IsTest
    public static void shouldThrowException_WhenInValidResponse() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        String sessionId = portalUser.Customer_IdP_Session_Id__c;
        Boolean exceptionThrown = false;

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            try {
                Test.startTest();
                Test.setMock(
                        HttpCalloutMock.class,
                        new PS_UserSessionTestRESTMockGenerator(false)
                );

                RestRequest request = new RestRequest();
                request.httpMethod = 'DELETE';
                request.requestURI = '/customer-idm/user/v1/session/' + sessionId;
                RestContext.request = request;

                PS_UserSessionWebServiceAPI.deleteSession();

                Test.stopTest();
            } catch (Exception e) {
                exceptionThrown = e instanceof CalloutException;
            }

            System.assertEquals(
                    exceptionThrown,
                    true,
                    'Exception should have been thrown'
            );
        }
    }

    @IsTest
    public static void shouldThrowException_WhenNoUserFound() {
        //given
        Boolean exceptionThrown = false;

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            try {
                Test.startTest();

                RestRequest request = new RestRequest();
                request.httpMethod = 'DELETE';
                request.requestURI = '/customer-idm/user/v1/session/' + 'invalidSessionId';
                RestContext.request = request;

                PS_UserSessionWebServiceAPI.deleteSession();

                Test.stopTest();

            } catch (Exception e) {
                exceptionThrown = e instanceof PS_UserSessionWebServiceAPI.NoDataFoundException;
            }

            System.assertEquals(
                    exceptionThrown,
                    true,
                    'Exception should have been thrown'
            );
        }
    }

    @isTest
    private static void PS_AuthSessionService_should_return_user_session_Application() {
        //Arrange
        PS_AuthSessionService service = new PS_AuthSessionService(UserInfo.getUserId());

        // Actual test
        Test.startTest();
        List<String> loginHistory = service.getAuthSessionsLoginHistoryApplicationsForUser();
        Test.stopTest();
    
        // Asserts
        System.assert(loginHistory.isEmpty() == false, 'Login History is expected from getAuthSessionsLoginHistoryApplicationsForUser');
    }
    
    @isTest
    private static void PS_AuthSessionService_should_delete_user_session_Application() {
        //Arrange
        PS_AuthSessionService service = new PS_AuthSessionService(UserInfo.getUserId());
        
        // Actual test
        Test.startTest();
        service.deleteAuthSessionsForUser();
        Test.stopTest();

        List<AuthSession> authSessions = [SELECT Id, UsersId FROM AuthSession WHERE UsersId =: UserInfo.getUserId()];
        
        // Asserts
        System.assert(authSessions.isEmpty() == true, 'Login History empty is expected for current user');
    }

    @isTest
    private static void JWT_code_coverage() {
        // Test data setup
        String keyContents = '-----BEGIN RSA PRIVATE KEY-----';
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        JWT jwt = new JWT(JWT.RS256);
        jwt.pkcs8 = keyContents;
        jwt.iss = 'developer.force.com';
        jwt.sub = '';
        jwt.aud = 'https://api.einstein.ai/v2/oauth2/token';
        jwt.exp = '3600';
        jwt.iat = String.valueOf((dateTime.now().getTime()/1000)+1);
        jwt.cert = '';
        jwt.pkcs8 = '';

        // Actual test
        String result = jwt.issue();
        result = jwt.issue();
        
    
        // Asserts
        System.assert(!String.isBlank(result), 'RS256 JWT is  expected');
    }

    @isTest
    private static void JWT_should_return_dot_if_NONE_alg_is_provided() {
        // Test data setup
        String keyContents = '-----BEGIN RSA PRIVATE KEY-----';
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        JWT jwt = new JWT(JWT.NONE);
        jwt.pkcs8 = keyContents;
        jwt.iss = 'developer.force.com';
        jwt.sub = '';
        jwt.aud = 'https://api.einstein.ai/v2/oauth2/token';
        jwt.exp = '3600';
        jwt.iat = String.valueOf((dateTime.now().getTime()/1000)+1);
        jwt.cert = '';
        jwt.pkcs8 = '';

        // Actual test
        Test.startTest();
        String result = jwt.issue();
        Test.stopTest();

        // Asserts
        System.assert(!String.isBlank(result) && result.endsWith('.'), 'RS256 JWT is expected with "." at the end');
    }
}
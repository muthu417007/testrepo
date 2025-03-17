/**
 * description Test class for PS_GEAIdPCommLoginCtrl
 */
@IsTest
public with sharing class PS_GEAIdPCommLoginCtrlTest {

    private static final String CLASS_NAME = PS_GEAIdPCommLoginCtrlTest.class
            .getName()
            .substring(0, 15);
    private static final String TEST_APP_NAME = 'TestApp';
    private static final String TEST_LANGUAGE_KEY = 'en_US';
    private static final String RET_URL_DOMAIN = 'https://return.url.com';
    private static final String TEST_PASSWORD = 'TestPassword123';
    private static final String TEST_AUTH_FORM = 'TestAuthForm';
    private static final String TEST_REVISION_NUMBER = '987654';

    @TestSetup
    public static void generateData() {
        PS_TestHelper.createGuestUser(CLASS_NAME);
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
        PS_TestHelper.createAirWaterUser(CLASS_NAME);

        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(users.get(0)) {


            AuthorizationForm authorizationForm = new AuthorizationForm(
                    Name = TEST_AUTH_FORM,
                    RevisionNumber = TEST_REVISION_NUMBER
            );
            insert authorizationForm;

            AuthorizationFormText authorizationFormText = new AuthorizationFormText(
                    Name = 'testAuthFormText',
                    AuthorizationFormId = authorizationForm.Id,
                    Locale = TEST_LANGUAGE_KEY
            );
            insert authorizationFormText;
        }
    }

    /**
     * description test shouldLogInUser_WhenValidPasswordPassed
     * Due to site.login pageReference will be null
     * it is not possible to assert correctly
     */
    @IsTest
    public static void shouldLogInUser_WhenValidPasswordPassed() {
        //given
        ConnectedApplication connectedApplication;
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(users.get(0)) {
            connectedApplication = UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

        }
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.setPassword(portalUser.Id, TEST_PASSWORD);

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Auth_Flow__c = 'Implicit_Grant',
                Connected_App_Id__c = connectedApplication.Id,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
            Map<String, String> loginResults = PS_GEAIdPCommLoginCtrl.handleLogin(
                    new Map<String, String>{
                            'email' => portalUser.Email,
                            'password' => TEST_PASSWORD,
                            'language' => 'en_US',
                            'redirectURL' => 'https://dev.geappliances.com'
                    }
            );
            Test.stopTest();

            System.assertNotEquals(
                    null,
                    loginResults,
                    'Invalid login results value'
            );

            System.assertNotEquals(
                    null,
                    loginResults.get('globalCustomerId'),
                    'Invalid global Customer Id returned'
            );
        }
    }
    
     /**
     * description test shouldLogInUser_WhenValidPasswordPassed
     * Due to site.login pageReference will be null
     * it is not possible to assert correctly
     */
    @IsTest
    public static void shouldLogInUser_WhenValidPasswordPassed_ANW() {
        //given
        ConnectedApplication connectedApplication;
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(users.get(0)) {
            connectedApplication = UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

        }
        User portalUser = PS_TestHelper.getCreatedPortalUser_AirWaterUser(CLASS_NAME).get(0);
        System.setPassword(portalUser.Id, TEST_PASSWORD);

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Auth_Flow__c = 'Implicit_Grant',
                Connected_App_Id__c = connectedApplication.Id,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
            Map<String, String> loginResults = PS_GEAIdPCommLoginCtrl.handleLogin(
                    new Map<String, String>{
                            'email' => portalUser.Email,
                            'password' => TEST_PASSWORD,
                            'language' => 'en_US',
                            'redirectURL' => 'https://dev.geappliances.com',
                                'siteName'=> 'AirAndWater'
                                
                    }
            );
            Test.stopTest();

            System.assertNotEquals(
                    null,
                    loginResults,
                    'Invalid login results value'
            );

            System.assertNotEquals(
                    null,
                    loginResults.get('globalCustomerId'),
                    'Invalid global Customer Id returned'
            );
        }
    }

    /**
     * description test shouldLogInUser_WhenExtServiceVerifiedPassword
     * should log in user after external service verified password and it's a first login
     */
    @IsTest
    public static void shouldLogInUser_WhenExtServiceVerifiedPassword() {
        //given
        ConnectedApplication connectedApplication;
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(users.get(0)) {
            connectedApplication = UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);
        }

        Customer_IdP_Password_Service_Config__c passwordServiceConfig = new Customer_IdP_Password_Service_Config__c();
        passwordServiceConfig.API_Key__c = 'testAPIKey';
        passwordServiceConfig.JWT_Issuer__c = 'https://identity.test.com';
        passwordServiceConfig.JWT_Expiry__c = 180;
        passwordServiceConfig.JWT_Audience__c = 'https://auth.test.com';
        //random test signing key
        passwordServiceConfig.JWT_Signing_Key__c = 'MIIBVgIBADANBgkqhkiG9w0BAQEFAASCAUAwggE8AgEAAkEAq7BFUpkGp3+LQmlQ\n' +
                'Yx2eqzDV+xeG8kx/sQFV18S5JhzGeIJNA72wSeukEPojtqUyX2J0CciPBh7eqclQ\n' +
                '2zpAswIDAQABAkAgisq4+zRdrzkwH1ITV1vpytnkO/NiHcnePQiOW0VUybPyHoGM\n' +
                '/jf75C5xET7ZQpBe5kx5VHsPZj0CBb3b+wSRAiEA2mPWCBytosIU/ODRfq6EiV04\n' +
                'lt6waE7I2uSPqIC20LcCIQDJQYIHQII+3YaPqyhGgqMexuuuGx+lDKD6/Fu/JwPb\n' +
                '5QIhAKthiYcYKlL9h8bjDsQhZDUACPasjzdsDEdq8inDyLOFAiEAmCr/tZwA3qeA\n' +
                'ZoBzI10DGPIuoKXBd3nk/eBxPkaxlEECIQCNymjsoI7GldtujVnr1qT+3yedLfHK\n' +
                'srDVjIT3LsvTqw==';
        passwordServiceConfig.Named_Credential__c = 'testNamedCredential';
        insert passwordServiceConfig;

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Auth_Flow__c = 'Implicit_Grant',
                Connected_App_Id__c = connectedApplication.Id,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        Customer_IdP_Configuration__mdt customerIdPConfiguration = new Customer_IdP_Configuration__mdt(
                Registration_Profile__c = PS_TestHelper.DEFAULT_CUSTOMER_LOGIN_PROFILE
        );

        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
            PS_GEAIdPCustomerConfigHelper.customerIdPConfiguration = customerIdPConfiguration;
            PS_GEAIdPCommLoginCtrl.throwExceptionOnLogin = true;
            Test.setMock(
                    HttpCalloutMock.class,
                    new ExternalPasswordServiceMock(false)
            );
            Map<String, String> loginResults = PS_GEAIdPCommLoginCtrl.handleLogin(
                    new Map<String, String>{
                            'email' => portalUser.Email,
                            'password' => TEST_PASSWORD,
                            'language' => 'en_US',
                            'redirectURL' => 'https://dev.geappliances.com'
                    }
            );
            Test.stopTest();
            System.assertNotEquals(
                    null,
                    loginResults,
                    'Invalid login results value'
            );

            System.assertNotEquals(
                    null,
                    loginResults.get('globalCustomerId'),
                    'Invalid global Customer Id returned'
            );
        }
    }

    /**
     * description test shouldThrowException_WhenExtServiceRejectedPassword
     * should throw exception after external service rejected password
     */
    @IsTest
    public static void shouldThrowException_WhenExtServiceRejectedPassword() {
        //given
        ConnectedApplication connectedApplication;
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(users.get(0)) {
            connectedApplication = UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);
        }

        Customer_IdP_Password_Service_Config__c passwordServiceConfig = new Customer_IdP_Password_Service_Config__c();
        passwordServiceConfig.API_Key__c = 'testAPIKey';
        passwordServiceConfig.JWT_Issuer__c = 'https://identity.test.com';
        passwordServiceConfig.JWT_Expiry__c = 180;
        passwordServiceConfig.JWT_Audience__c = 'https://auth.test.com';
        passwordServiceConfig.JWT_Signing_Key__c = 'testSigningKey';
        passwordServiceConfig.Named_Credential__c = 'testNamedCredential';
        insert passwordServiceConfig;

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Auth_Flow__c = 'Implicit_Grant',
                Connected_App_Id__c = connectedApplication.Id,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.setPassword(portalUser.Id, 'invalidPass1');

        Boolean exceptionThrown = false;

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            try {
                Test.startTest();
                PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
                PS_GEAIdPCommLoginCtrl.throwExceptionOnLogin = true;
                Test.setMock(
                        HttpCalloutMock.class,
                        new ExternalPasswordServiceMock(true)
                );
                PS_GEAIdPCommLoginCtrl.handleLogin(
                        new Map<String, String>{
                                'email' => portalUser.Email,
                                'password' => TEST_PASSWORD,
                                'language' => 'en_US',
                                'redirectURL' => 'https://dev.geappliances.com'
                        }
                );
                Test.stopTest();
            } catch (Exception e) {
                exceptionThrown = e instanceof AuraHandledException;
            }

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should have been thrown'
            );
        }
    }

    /**
     * description test shouldThrowAuraHandledException_WhenUnexpectedErrorOccurred
     * should throw AuraHandledException when unexpected error occurred
     */
    @IsTest
    public static void shouldThrowAuraHandledException_WhenUnexpectedErrorOccurred() {
        //given
        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.setPassword(portalUser.Id, TEST_PASSWORD);

        Boolean exceptionThrown = false;

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            try {
                Test.startTest();
                PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
                PS_GEAIdPCommLoginCtrl.throwExceptionOnLogin = true;
                Test.setMock(
                        HttpCalloutMock.class,
                        new ExternalPasswordServiceMock(true)
                );
                PS_GEAIdPCommLoginCtrl.handleLogin(
                        new Map<String, String>{
                                'email' => portalUser.Email,
                                'password' => TEST_PASSWORD,
                                'language' => 'en_US',
                                'redirectURL' => 'https://dev.geappliances.com'
                        }
                );
                Test.stopTest();
            } catch (Exception e) {
                exceptionThrown = e instanceof AuraHandledException;
            }

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should have been thrown'
            );
        }
    }

    /**
     * description test shouldReturnRegistrationURL_WhenEnvConfigValid
     */
    @IsTest
    public static void shouldReturnRegistrationURL_WhenEnvConfigValid() {
        //given

        final String TEST_REGISTRATION_URL = 'https://register.com/s/register';
        Customer_IdP_Environment_Config__mdt envConfig = new Customer_IdP_Environment_Config__mdt(
                Registration_URL_Override__c = TEST_REGISTRATION_URL
        );

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            PS_GEAIdPEnvironmentConfigHelper.environmentConfigTest = envConfig;
            String registrationURL = PS_GEAIdPCommLoginCtrl.getRegisterURL();
            Test.stopTest();

            System.assertEquals(
                    TEST_REGISTRATION_URL,
                    registrationURL,
                    'Invalid registration url value'
            );
        }
    }

    /**
     * description test shouldReturnNull_WhenNoEnvConfig
     */
    @IsTest
    public static void shouldReturnNull_WhenNoEnvConfig() {
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            String registrationURL = PS_GEAIdPCommLoginCtrl.getRegisterURL();
            Test.stopTest();

            System.assertEquals(
                    null,
                    registrationURL,
                    'Invalid registration url value'
            );
        }
    }
    
     /**
     * description test shouldLogInUser_WhenPATransformed
     * Outage = false; PATransformed = true
     * 
     */
    @IsTest
    public static void shouldLogInUser_WhenPATransformed() {
        //given
        ConnectedApplication connectedApplication;
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
       /* System.runAs(users.get(0)) {
            connectedApplication = UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

        }*/
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.setPassword(portalUser.Id, TEST_PASSWORD);

       /* Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Auth_Flow__c = 'Implicit_Grant',
                Connected_App_Id__c = connectedApplication.Id,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );*/

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            //PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
            Map<String, String> loginResults = PS_GEAIdPCommLoginCtrl.handleLogin(
                    new Map<String, String>{
                            'email' => portalUser.Email,
                            'password' => TEST_PASSWORD,
                            'language' => 'en_US',
                            'redirectURL' => 'https://dev.geappliances.com'
                    }
            );
            system.debug('@@@ in test class email: ' +portalUser.Email);
            system.debug('@@@ in test class password: ' +TEST_PASSWORD);
            Test.stopTest();

            System.assertNotEquals(
                    null,
                    loginResults,
                    'Invalid login results value'
            );

            System.assertNotEquals(
                    null,
                    loginResults.get('globalCustomerId'),
                    'Invalid global Customer Id returned'
            );
        }
    }
    

    private class ExternalPasswordServiceMock implements HttpCalloutMock {

        private Boolean throwException;

        public ExternalPasswordServiceMock(Boolean throwException) {
            this.throwException = throwException;
        }

        public HttpResponse respond(HttpRequest param1) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(this.throwException ? 400 : 200);
            response.setStatus(this.throwException ? 'fail' : 'success');
            response.setBody(
                    JSON.serialize(
                            new Map<String, Object>{
                                    'success' => !this.throwException
                            }
                    )
            );

            return response;
        }
    }
}
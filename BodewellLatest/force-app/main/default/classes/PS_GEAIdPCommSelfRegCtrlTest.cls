/**
 * description Test class for PS_GEAIdPCommSelfRegCtrl
 */
@IsTest
public with sharing class PS_GEAIdPCommSelfRegCtrlTest {

    @TestSetup
    static void generateData() {
        User testUser = new UserBuilder()
                .setDefault()
                .setFirstName(UserBuilder.TEST_USER_FIRST_NAME)
                .setProfile(UserBuilder.PROFILE_NAME_SYSTEM_ADMINISTRATOR)
                .setRole(UserBuilder.ROLE_DEVELOPERNAME_CEO)
                .save();

        System.runAs(UserBuilder.getUser()) {
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            insert testAccount;

            Customer_IdP_Configuration__mdt siteConfig = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
            AuthorizationForm authForm = new AuthorizationForm(
                    Name = siteConfig.Terms_Auth_Form_Name__c,
                    RevisionNumber = siteConfig.Terms_Auth_Form_Revision__c
            );
            insert authForm;

            AuthorizationFormText authFormText = new AuthorizationFormText(
                    Name = siteConfig.Terms_Auth_Form_Name__c + 'Text',
                    AuthorizationFormId = authForm.Id,
                    Locale = 'en_US'
            );
            insert authFormText;

            insert new CaptchaConfiguration__c(
                    DeveloperName__c = CaptchaConfigurationSelector.DEFAULT_CAPTCHA_CONFIGURATION_METHOD_NAME,
                    SecretKey__c = 'TestSecretKey',
                    SiteKey__c = 'TestSiteKey'
            );
        }
    }

    /**
     * description test Register User
     */
    @IsTest
    static void testRegisterUser() {
        System.runAs(UserBuilder.getUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AuthMock());
            String testEmail = 'testEmail@email.com';
            PS_GEAIdPCommSelfRegCtrl.registerUser(
                    new Map<String, String>{
                            'email' => testEmail,
                            'firstName' => 'Test FirstName',
                            'lastName' => 'Test LastName',
                            'password' => 'Reset123',
                            'timeZone' => UserInfo.getTimeZone().getID(),
                            'language' => 'en_US',
                            'redirectURL' => 'https%3A%2F%2Fdev.geappliances.com',
                            'state' => '123'
                    }
            );
            Test.stopTest();
            User createdUser = [SELECT Id, Email FROM User WHERE Email = :testEmail];

            System.assertEquals(
                    testEmail.toLowerCase(),
                    createdUser.Email.toLowerCase(),
                    'User should have created'
            );
        }
    }

    /**
     * description test Register User
     */
    @IsTest
    static void testRegisterUserFail() {
        System.runAs(UserBuilder.getUser()) {
            Boolean errorOccurred = false;
            try {
                PS_GEAIdPCommSelfRegCtrl.registerUser(
                        new Map<String, String>{
                                'email' => null,
                                'firstName' => 'Test FirstName',
                                'lastName' => 'Test LastName',
                                'password' => 'Reset123',
                                'timeZone' => UserInfo.getTimeZone().getID(),
                                'language' => 'en_US',
                                'redirectURL' => 'https%3A%2F%2Fdev.geappliances.com',
                                'state' => '123'
                        }
                );
            } catch (Exception e) {
                System.debug('Error should occurred');
                errorOccurred = true;
            }

            System.assertEquals(true, errorOccurred, 'User should not have been created');
        }
    }

    @isTest
    private static void PS_GEAIdPSecurityService_verifyRecaptcha_should_fail_if_result_is_false() {
        // Test data setup
        Test.setMock(HttpCalloutMock.class, new AuthMockUnsuccessfull());
        Boolean recaptchaVerificationResultFailed = false;

        // Actual test
        Test.startTest();
        try {
            PS_GEAIdPSecurityService.verifyRecaptcha('test'); 
        } catch (Exception ex) {
            recaptchaVerificationResultFailed = true;
        }
        Test.stopTest();
    
        // Asserts
        System.assertEquals(true, recaptchaVerificationResultFailed, 'Recaptcha verification should fail and one error is thrown.');
    }
    
    @isTest
    private static void PS_GEAIdPSecurityService_saveUser_should_fail_if_null_parameter_is_provided() {
        // Test data setup
        PS_GEAIdPSecurityService.GEAIdPSecutiryModel data = null;
        Boolean saveUserFailed = false;
        
        // Actual test
        Test.startTest();
        try {
            PS_GEAIdPSecurityService.saveUser(data);
        } catch (Exception ex) {
            saveUserFailed = true;
        }
        Test.stopTest();
        
        // Asserts
        System.assertEquals(true, saveUserFailed, 'saveUser should fail and one error is thrown.');
    }

    @IsTest
    static void saveUser_should_use_existing_contact_and_save_new_user() {
        System.runAs(UserBuilder.getUser()) {
            String testEmail = 'testEmail@email.com';
            Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
            insert new Contact(FirstName = 'test-contact-first-name', LastName = 'test-contact-last-name', Email = testEmail, AccountId = testAccount.Id);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AuthMock());
            PS_GEAIdPCommSelfRegCtrl.registerUser(
                    new Map<String, String>{
                            'email' => testEmail,
                            'firstName' => 'Test FirstName',
                            'lastName' => 'Test LastName',
                            'password' => 'Reset123',
                            'timeZone' => UserInfo.getTimeZone().getID(),
                            'language' => 'en_US',
                            'redirectURL' => 'https%3A%2F%2Fdev.geappliances.com',
                            'state' => '123'
                    }
            );
            Test.stopTest();
            User createdUser = [SELECT Id, Email FROM User WHERE Email = :testEmail];

            System.assertEquals(
                    testEmail.toLowerCase(),
                    createdUser.Email.toLowerCase(),
                    'User should have created'
            );
        }
    }

    @IsTest
    static void saveUser_should_throw_an_exception_if_an_error_happens_saving_the_new_user() {
        System.runAs(UserBuilder.getUser()) {
            String testEmail = 'testEmail@email.com';
            
            insert new Contact(FirstName = 'test-contact-first-name', LastName = 'test-contact-last-name', Email = testEmail);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AuthMock());
            Boolean saveUserFailed = false;

            try {
                    PS_GEAIdPCommSelfRegCtrl.registerUser(
                        new Map<String, String>{
                                'email' => testEmail,
                                'firstName' => 'Test FirstName',
                                'lastName' => 'Test LastName',
                                'password' => 'Reset123',
                                'timeZone' => UserInfo.getTimeZone().getID(),
                                'language' => 'en_US',
                                'redirectURL' => 'https%3A%2F%2Fdev.geappliances.com',
                                'state' => '123'
                        }
                );
            } catch (Exception ex) {
                saveUserFailed = true;
            }
            Test.stopTest();
            

            System.assertEquals(
                    true,
                    saveUserFailed,
                    'saveUser should fail and throw an exception'
            );
        }
    }

    private class AuthMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody('{"success":true}');
            return res;
        }
    }

    private class AuthMockUnsuccessfull implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody('{"success":false}');
            return res;
        }
    }
}
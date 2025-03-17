/**
 * Test class for RecaptchaCallout
 */
@isTest
public with sharing class RecaptchaCalloutTest {
    /**
     * @description Mock class for Successful Auth
     */
    public class AuthMock implements HttpCalloutMock {
        /**
         * @description HTTPResponse handler
         */
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody('{"success":true}');
            return res;
        }
    }

    /**
     * @description Mock class for Unsuccessful Auth
     */
    public class AuthMockUnsuccessful implements HttpCalloutMock {
        /**
         * @description HTTPResponse handler
         */
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(400);
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody('{"success":false}');
            return res;
        }
    }

    /**
     * @description Insert CaptchaConfiguration__c record
     */
    @testSetup
    static void generateData() {
        User testUser = new UserBuilder()
            .setDefault()
            .setFirstName(UserBuilder.TEST_USER_FIRST_NAME)
            .setProfile(UserBuilder.PROFILE_NAME_SYSTEM_ADMINISTRATOR)
            .setRole(UserBuilder.ROLE_DEVELOPERNAME_CEO)
            .save();

        System.runAs(UserBuilder.getUser()) {
            CaptchaConfiguration__c testRecord = new CaptchaConfiguration__c();
            testRecord.SecretKey__c = 'Test';
            testRecord.SiteKey__c = 'Test Site';
            testRecord.DeveloperName__c = CaptchaConfigurationSelector.DEFAULT_CAPTCHA_CONFIGURATION_METHOD_NAME;
            insert testRecord;
        }
    }

    /**
     * @description Test Successful request
     */
    @IsTest
    static void testBehaviorSuccessfulProcess() {
        System.runAs(UserBuilder.getUser()) {
            Test.setMock(HttpCalloutMock.class, new AuthMock());
            Test.startTest();
            Boolean isSuccess = new RecaptchaCallout().verify('test');
            System.assertEquals(true, isSuccess, 'Success');
            Test.stopTest();
        }
    }

    /**
     * @description Test Unsuccessful request
     */
    @IsTest
    static void testBehaviorUnSuccessfulProcess() {
        System.runAs(UserBuilder.getUser()) {
            Test.setMock(HttpCalloutMock.class, new AuthMockUnsuccessful());
            Test.startTest();
            Boolean isSuccess = new RecaptchaCallout().verify('test');
            System.assertEquals(false, isSuccess, 'Not Success');
            Test.stopTest();
        }
    }
}
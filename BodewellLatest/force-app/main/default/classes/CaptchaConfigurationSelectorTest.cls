/**
 * description Test class for CaptchaConfigurationSelector
 */
@isTest
public with sharing class CaptchaConfigurationSelectorTest {
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
     * description test getDefault method
     */
    @IsTest
    static void testCaptchaConfigurationSelector() {
        System.runAs(UserBuilder.getUser()) {
            CaptchaConfiguration__c testRecord = CaptchaConfigurationSelector.getInstance(
                    CaptchaConfigurationSelector.DEFAULT_CAPTCHA_CONFIGURATION_METHOD_NAME
                )
                .getRecord();
            System.assertNotEquals(
                null,
                testRecord,
                'Default record should returned - testCaptchaConfigurationSelector'
            );
        }
    }
}
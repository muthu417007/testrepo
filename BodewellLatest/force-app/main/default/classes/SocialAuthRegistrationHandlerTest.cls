@IsTest
public with sharing class SocialAuthRegistrationHandlerTest {

    @TestSetup
    static void generateData() {
        User testUser = new UserBuilder()
            .setDefault()
            .setFirstName(UserBuilder.TEST_USER_FIRST_NAME)
            .setProfile(UserBuilder.PROFILE_NAME_SYSTEM_ADMINISTRATOR)
            .setRole(UserBuilder.ROLE_DEVELOPERNAME_CEO)
            .save();

        System.runAs(UserBuilder.getUser()) {
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
        }
    }

    @IsTest
    static void testSocialLogin() {
        String tempUserName = UserBuilder.generateUserName();
        System.runAs(UserBuilder.getUser()) {
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            insert testAccount;
            insert new Contact(
                    FirstName = 'TestFName',
                    AccountId = testAccount.Id,
                    LastName = 'TestLName',
                    Email = tempUserName
            );
        }

        System.runAs(UserBuilder.getUser()) {
            SocialAuthRegistrationHandler handler = new SocialAuthRegistrationHandler();
            Auth.UserData sampleData = new Auth.UserData(
                null,
                'testFirstName',
                'testLasName',
                'testFirstName testLasName',
                tempUserName,
                null,
                'testuserlong',
                'en_US',
                'facebook',
                null,
                new Map<String, String>{ 'language' => 'en_US', 'sfdc_networkid' => '123' }
            );
            User u = handler.createUser(null, sampleData);
            System.assertEquals(tempUserName.toLowerCase(), u.email);
            System.assertEquals('testLasName', u.lastName);
            System.assertEquals('testFirstName', u.firstName);
            System.assertEquals('ttestL', u.alias);
        }
    }

    @IsTest
    static void testSocialLoginNoNetworkId() {
        System.runAs(UserBuilder.getUser()) {
            String tempUserName = UserBuilder.generateUserName();
            SocialAuthRegistrationHandler handler = new SocialAuthRegistrationHandler();
            Auth.UserData sampleData = new Auth.UserData(
                null,
                'testFirstName',
                'testLasName',
                'testFirstName testLasName',
                tempUserName,
                null,
                'testuserlong',
                'en_US',
                'facebook',
                null,
                new Map<String, String>{ 'language' => 'en_US' }
            );
            User u = handler.createUser(null, sampleData);
            System.assertEquals(u, null, 'User should not be created');

            handler.updateUser(null, null, null);
        }

    }
}
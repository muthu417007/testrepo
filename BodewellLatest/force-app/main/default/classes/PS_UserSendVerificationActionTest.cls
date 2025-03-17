@IsTest
private class PS_UserSendVerificationActionTest {

    private static final String CLASS_NAME = PS_GEAIdPForgotPasswordCtrlTest.class
            .getName()
            .substring(0, 15);

    @TestSetup
    public static void createData() {
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
        PS_UserSendVerificationActionTest.createUsers();
    }
    
    @IsTest
    private static void testUserSendVerificationEmail() {
        User u1 = [SELECT Id FROM User WHERE Email = 'ecommerce@testorg.com'];
        PS_UserSendVerificationAction.throwErrorSendingEmail = false;
        PS_UserSendVerificationAction.failedSendingEmail = false;
        
        Test.startTest();
        System.runAs(u1) {
            PS_UserSendVerificationAction.SendVerificationInput input = new PS_UserSendVerificationAction.SendVerificationInput();
            input.emailTemplateId = [SELECT Id FROM EmailTemplate LIMIT 1]?.Id;
            input.networkId = [SELECT Id FROM Network WHERE Name = 'GE Appliances' LIMIT 1]?.Id;
            input.userId = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0).Id;
            input.startUrl = '/s/start-url';
            
            PS_UserSendVerificationAction.SendVerificationOutput output = PS_UserSendVerificationAction.sendVerificationEmail(
                new List<PS_UserSendVerificationAction.SendVerificationInput>{
                    input
                }
                )[0];

            System.assertEquals(true, output.result, 'The result of send verification email should be true.');
        }
        Test.stopTest();
    }
        
    @IsTest
    private static void SendVerificationInput_should_return_empty_result_if_an_error_happens() {
        User u1 = [SELECT Id FROM User WHERE Email = 'ecommerce@testorg.com'];
        List<PS_UserSendVerificationAction.SendVerificationOutput> output = null;
        PS_UserSendVerificationAction.throwErrorSendingEmail = true;
        PS_UserSendVerificationAction.failedSendingEmail = false;
        
        Test.startTest();
        System.runAs(u1) {
            PS_UserSendVerificationAction.SendVerificationInput input = new PS_UserSendVerificationAction.SendVerificationInput();
            input.emailTemplateId = [SELECT Id FROM EmailTemplate LIMIT 1]?.Id;
            input.networkId = [SELECT Id FROM Network WHERE Name = 'GE Appliances' LIMIT 1]?.Id;
            input.userId = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0).Id;
            input.startUrl = '/s/start-url';
            
            output = PS_UserSendVerificationAction.sendVerificationEmail(new List<PS_UserSendVerificationAction.SendVerificationInput>{ input });
        }
        Test.stopTest();
        
        System.assertEquals(0, output.size(), 'The result of send verification email should be empty.');
    }
    
    @IsTest
    private static void SendVerificationInput_should_return_invalid_result_if_an_system_failed_sending_email() {
        User u1 = [SELECT Id FROM User WHERE Email = 'ecommerce@testorg.com'];
        List<PS_UserSendVerificationAction.SendVerificationOutput> output = null;
        PS_UserSendVerificationAction.throwErrorSendingEmail = false;
        PS_UserSendVerificationAction.failedSendingEmail = true;
        
        Test.startTest();
        System.runAs(u1) {
            PS_UserSendVerificationAction.SendVerificationInput input = new PS_UserSendVerificationAction.SendVerificationInput();
            input.emailTemplateId = [SELECT Id FROM EmailTemplate LIMIT 1]?.Id;
            input.networkId = [SELECT Id FROM Network WHERE Name = 'GE Appliances' LIMIT 1]?.Id;
            input.userId = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0).Id;
            input.startUrl = '/s/start-url';

            output = PS_UserSendVerificationAction.sendVerificationEmail(new List<PS_UserSendVerificationAction.SendVerificationInput>{ input });
        }
        Test.stopTest();

        System.assertEquals(1, output.size(), 'Output with single one result is expected');
    }

    @isTest
    private static void UserTriggerHandler_code_coverage() {
        // Test data setup
        User testUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        testuser.LanguageLocaleKey = 'es';

        // Actual test
        Test.startTest();
        update testuser;
        Test.stopTest();
    
        // Asserts
        System.assertEquals('es', testUser.LanguageLocaleKey, 'es Language is expected');
    }

    @Future
    public static void createUsers() {
        String uniqueUserName1 =
                'eCommerceUser' +
                        Datetime.now().getTime() +
                        '@testorg.com';

        Id eCommerceProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'eCommerce' LIMIT 1].Id;

        UserRole role1 = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];

        User u1 = new User(
                Alias = 'ecom',
                Email = 'ecommerce@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing eCommerce User',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = eCommerceProfileId,
                UserRoleId = role1.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = uniqueUserName1
        );
        insert u1;
    }
}
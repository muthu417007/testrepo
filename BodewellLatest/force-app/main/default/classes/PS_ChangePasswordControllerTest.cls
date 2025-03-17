@IsTest
public class PS_ChangePasswordControllerTest {
    private static final String CLASS_NAME = PS_ChangePasswordControllerTest.class
            .getName()
            .substring(0, 15);

    @TestSetup
    static void setup() {
        AuthorizationForm af = new AuthorizationForm(
                Name = 'Web Registration Authorization Form',
                EffectiveFromDate = Date.today(),
                EffectiveToDate = Date.today().addYears(2),
                RevisionNumber = '1'
        );
        insert af;

        AuthorizationFormText aft = new AuthorizationFormText(
                AuthorizationFormId = af.Id,
                Locale = UserInfo.getLocale(),
                Name = 'Web Registration Authorization Form Text'
        );
        insert aft;

        PS_TestHelper.createGuestUser(CLASS_NAME);
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
    }

    @IsTest
    private static void PS_ChangePasswordController_should_load_site_configuration_for_new_instance() {
        // Arrange
        PS_ChangePasswordController ctrl = new PS_ChangePasswordController();

        // Act
        Test.startTest();

        Test.stopTest();

        // Asserts
        System.assert(ctrl.globalCssVars != '', 'Global Vars is are expected for site config');
        System.assert(ctrl.resourceContent != '', 'Resource Content URL is expected for site config');
        System.assert(ctrl.headerAndFooterURL != '', 'Header and Footer URL is expected for site config');
    }

    @IsTest
    private static void savePassword_should_not_update_the_user_password_if_newPassword_is_null() {
        // Arrange
        PS_ChangePasswordController ctrl = new PS_ChangePasswordController();
        ctrl.newPassword = null;
        ctrl.passwordConfirmation = null;

        // Act
        Test.startTest();
        PageReference result = ctrl.savePassword();
        Test.stopTest();

        // Asserts
        System.assertEquals(null, result, 'Null page reference is expected');
    }

    @IsTest
    private static void savePassword_should_not_update_the_user_password_if_passwordConfirmation_is_null() {
        // Arrange
        PS_ChangePasswordController ctrl = new PS_ChangePasswordController();
        ctrl.newPassword = 'Abc123456';
        ctrl.passwordConfirmation = null;

        // Act
        Test.startTest();
        PageReference result = ctrl.savePassword();
        Test.stopTest();

        // Asserts
        System.assertEquals(null, result, 'Null page reference is expected');
    }

    @IsTest
    private static void savePassword_should_not_update_the_user_password_if_password_strength_is_not_met() {
        // Arrange
        PS_ChangePasswordController ctrl = new PS_ChangePasswordController();
        ctrl.newPassword = '123';
        ctrl.passwordConfirmation = '123';
        PageReference result = null;

        // Act
        Test.startTest();
        PS_ChangePasswordController.testPasswordStrengthHasError = true;
        System.runAs(PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0)) {
            result = ctrl.savePassword();
        }
        Test.stopTest();

        // Asserts
        System.assertEquals(null, result, 'Null page reference is expected');
    }

    @IsTest
    private static void savePassword_should_update_the_user_password_if_password_strength_is_met() {
        // Arrange
        PS_ChangePasswordController ctrl = new PS_ChangePasswordController();
        ctrl.newPassword = 'ThisIsMyStrongPassword@123';
        ctrl.passwordConfirmation = 'ThisIsMyStrongPassword@123';
        PageReference result = null;

        // Act
        Test.startTest();
        System.runAs(PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0)) {
            result = ctrl.savePassword();
        }
        Test.stopTest();

        // Asserts
        System.assert(result != null, 'Page reference is expected');
    }
    @IsTest
    private static void savePassword_should_update_the_user_password_and_redirect_to_destination_override() {
        // Arrange
        PS_ChangePasswordController ctrl = new PS_ChangePasswordController();
        ctrl.newPassword = 'ThisIsMyStrongPassword@123';
        ctrl.passwordConfirmation = 'ThisIsMyStrongPassword@123';
        PageReference result = null;
        PS_GEAIdPEnvironmentConfigHelper.environmentConfigTest = new Customer_IdP_Environment_Config__mdt();
        PS_GEAIdPEnvironmentConfigHelper.environmentConfigTest.Change_Password_Destination_Override__c = 'https://google.com';

        // Act
        Test.startTest();
        System.runAs(PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0)) {
            result = ctrl.savePassword();
        }
        Test.stopTest();

        // Asserts
        System.assert(result != null, 'Page reference is expected');
    }

    @IsTest
    private static void savePassword_should_not_update_the_user_password_if_an_exception_happen() {
        // Arrange
        Pagereference changePasswordPage = Page.PS_ChangePassword;
        Test.setCurrentPage(changePasswordPage);

        PS_ChangePasswordController ctrl = new PS_ChangePasswordController();
        ctrl.newPassword = 'ThisIsMyStrongPassword@123';
        ctrl.passwordConfirmation = 'ThisIsMyStrongPassword@123';
        ctrl.throwException = true;

        PageReference result = null;

        // Act
        Test.startTest();
        System.runAs(PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0)) {
            result = ctrl.savePassword();
        }
        Test.stopTest();

        // Asserts
        System.assertEquals(null, result, 'Null Page reference is expected');
    }

    @IsTest
    private static void savePassword_should_not_update_the_user_password_if_Page_has_errors() {
        // Arrange
        Pagereference changePasswordPage = Page.PS_ChangePassword;
        Test.setCurrentPage(changePasswordPage);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'My Error'));

        PS_ChangePasswordController ctrl = new PS_ChangePasswordController();
        ctrl.newPassword = 'ThisIsMyStrongPassword@123';
        ctrl.passwordConfirmation = 'ThisIsMyStrongPassword@123';
        
        PageReference result = null;

        // Act
        Test.startTest();
        System.runAs(PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0)) {
            result = ctrl.savePassword();
        }
        Test.stopTest();

        // Asserts
        System.assertEquals(null, result, 'Null Page reference is expected');
    }

    @isTest
    private static void PS_GEAIdPEnvironmentConfigHelper_should_return_cache_if_available() {
        // Arrange
        String devName = 'my_test_env_config';
        PS_GEAIdPEnvironmentConfigHelper.environmentConfigCache = new Customer_IdP_Environment_Config__mdt(DeveloperName = devName);
        
        // Actual test
        Test.startTest();
        Customer_IdP_Environment_Config__mdt cachedConfig = PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration();
        Test.stopTest();
    
        // Asserts
        System.assertEquals(PS_GEAIdPEnvironmentConfigHelper.environmentConfigCache, cachedConfig, 'Cache is expected for environment config');
    }

    @isTest
    private static void PS_GEAIdPEnvironmentConfigHelper_should_return_null_if_no_environment_config_is_found() {
        //Arrange
        PS_GEAIdPEnvironmentConfigHelper.envConfigNotFound = true;

        // Actual test
        Test.startTest();
        Customer_IdP_Environment_Config__mdt envConfig = PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration();
        Test.stopTest();
    
        // Asserts
        System.assertEquals(null, envConfig, 'null environment config is expected');
    }
}
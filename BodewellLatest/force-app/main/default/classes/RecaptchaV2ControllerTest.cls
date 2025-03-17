@isTest
public class RecaptchaV2ControllerTest {
    @isTest
    private static void getSiteKey_should_return_empty_if_no_keys_are_configured() {
        // Test data setup
        String sitekey = '';

        // Actual test
        Test.startTest();
        sitekey = RecaptchaV2Controller.getSiteKey();
        Test.stopTest();
    
        // Asserts
        System.assertEquals('', sitekey, 'No site key should be returned if not key is configured');
    }

    @isTest
    private static void getSiteKey_should_return_sitekey() {
        // Test data setup
        String MY_SITE_KEY = 'my_site_key';
        insert new CaptchaConfiguration__c(DeveloperName__c = CaptchaConfigurationSelector.DEFAULT_CAPTCHA_CONFIGURATION_METHOD_NAME, SiteKey__c = MY_SITE_KEY);

        String sitekey = '';

        // Actual test
        Test.startTest();
        sitekey = RecaptchaV2Controller.getSiteKey();
        Test.stopTest();
    
        // Asserts
        System.assertEquals(MY_SITE_KEY, sitekey, 'sitekey should be returned if key exists');
    }
}
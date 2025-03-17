public without sharing class RecaptchaV2Controller {
    @AuraEnabled
    public static String getSiteKey(){
        String result = '';

        try {
            CaptchaConfiguration__c configRecord = CaptchaConfigurationSelector.getInstance(
            CaptchaConfigurationSelector.DEFAULT_CAPTCHA_CONFIGURATION_METHOD_NAME
            ).getRecord();

            result = configRecord.SiteKey__c;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, '[RecaptchaV2Controller].getSiteKey error: ' + ex.getMessage());
        }

        return result;
    }
}
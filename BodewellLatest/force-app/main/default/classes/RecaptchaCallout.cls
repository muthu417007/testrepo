/**
 * description Recaptcha callout for verification
 */
public with sharing class RecaptchaCallout {
    /**
     * description verify recaptcha verification
     */
    public Boolean verify(String recaptchaResponse) {
        CaptchaConfiguration__c configRecord = CaptchaConfigurationSelector.getInstance(
                CaptchaConfigurationSelector.DEFAULT_CAPTCHA_CONFIGURATION_METHOD_NAME
            )
            .getRecord();
        String recaptchaSecretKey = configRecord.SecretKey__c;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + recaptchaSecretKey + '&response=' + recaptchaResponse);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if (result.containsKey('success') && result.get('success') == true) {
                return true;
            }
        }

        return false;
    }
}
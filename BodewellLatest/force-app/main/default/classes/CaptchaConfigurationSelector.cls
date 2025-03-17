/**
 * @description Singleton CaptchaConfiguration selector
 * query and return CaptchaConfiguration records
 */
public without sharing class CaptchaConfigurationSelector {
    private static CaptchaConfigurationSelector instance;
    private List<CaptchaConfiguration__c> listCaptchaConfigurationRecords;

    public static final String DEFAULT_CAPTCHA_CONFIGURATION_METHOD_NAME = 'Customer GEA IDP';

    /**
     * @description Constructor
     */
    private CaptchaConfigurationSelector(String configurationName) {
        listCaptchaConfigurationRecords = [
            SELECT Id, Name, SiteKey__c, SecretKey__c
            FROM CaptchaConfiguration__c
            WHERE DeveloperName__c = :configurationName
            LIMIT 1
            //WITH SECURITY_ENFORCED
        ];
    }

    /**
     * @description initiate CaptchaConfigurationSelector
     */
    public static CaptchaConfigurationSelector getInstance(String configurationName) {
        if (instance == null) {
            instance = new CaptchaConfigurationSelector(configurationName);
        }
        return instance;
    }

    /**
     * @description get default configuration record
     */
    public CaptchaConfiguration__c getRecord() {
        return listCaptchaConfigurationRecords?.get(0);
    }
}
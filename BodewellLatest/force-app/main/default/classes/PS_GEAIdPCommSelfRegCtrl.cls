/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-12-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   07-07-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
 **/
public without sharing class PS_GEAIdPCommSelfRegCtrl {
    @AuraEnabled
    public static String registerUser(Map<String, String> registrationParameters) {
        System.debug('registrationParameters: '+JSON.serialize(registrationParameters));

        PS_GEAIdPSecurityService.GEAIdPSecurityServiceResult result = new PS_GEAIdPSecurityService.GEAIdPSecurityServiceResult();
       // PS_GEAIdPSecurityService.verifyRecaptcha(registrationParameters.get('recaptchaResponse'));

        if (
                String.isBlank(registrationParameters.get('email')) ||
                        String.isBlank(registrationParameters.get('firstName')) ||
                        String.isBlank(registrationParameters.get('lastName')) ||
                        String.isBlank(registrationParameters.get('password')) ||
                        String.isBlank(registrationParameters.get('timeZone'))
                ) {
            System.debug(LoggingLevel.WARN, 'PS_GEAIDMCommSelfRegCtrl.registerUser invalid parameter');
            //result.fail('invalid parameter', null);
            throw new AuraHandledException('invalid parameter');
            //return JSON.serialize(result);
        }

        PS_GEAIdPSecurityService.GEAIdPSecutiryModel registrationData = new PS_GEAIdPSecurityService.GEAIdPSecutiryModel();
        registrationData.email = registrationParameters.get('email');
        registrationData.firstName = registrationParameters.get('firstName');
        registrationData.lastName = registrationParameters.get('lastName');
        registrationData.mobilePhone = registrationParameters.get('mobilePhone');
        registrationData.password = registrationParameters.get('password');
        registrationData.timeZone = registrationParameters.get('timeZone');
        registrationData.language = registrationParameters.get('language');
        registrationData.redirectUrl = registrationParameters.get('redirectURL');
        registrationData.state = registrationParameters.get('state');
        List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
        registrationData.registrationSource = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;
        
        system.debug('registrationData'+registrationData);
        result = PS_GEAIdPSecurityService.saveUser(registrationData);

        return JSON.serialize(result);
    }
}
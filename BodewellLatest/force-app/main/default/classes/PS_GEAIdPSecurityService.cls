/*
  @description       : This Service is used to manage the generation of Community Users
  @author            : Luis Ramirez (l.ramirez@polsource.com)
  @group             :
  @last modified on  : 07-12-2021
  @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
  Modifications Log
  Ver   Date         Author                                   Modification
  1.0   06-16-2021   Luis Ramirez (l.ramirez@polsource.com)   Initial Version
*/
public without sharing class PS_GEAIdPSecurityService {
    private static final Long CURRENT_TIME = Datetime.now().getTime();

    public static GEAIdPSecurityServiceResult saveUser(GEAIdPSecutiryModel data) {
        GEAIdPSecurityServiceResult result = new GEAIdPSecurityServiceResult();

        if (data == null) {
            throw new AuraHandledException('invalid GEAIdPSecurityModel param was provided');
        }

        try {
            Customer_IdP_Configuration__mdt siteConfig = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
            System.debug(LoggingLevel.INFO, 'PS_GEAIdPSecurityService.saveUser siteConfig:' + siteConfig);

            Contact contact = generateContact(data);
            System.debug(LoggingLevel.INFO, 'PS_GEAIdPSecurityService.saveUser ' + contact);

            User newUser = PS_WebServiceUserInfoHelper.insertUser(
                    contact,
                    data.password,
                    true,
                    data.language,
                    null,
                    data.mobilePhone
            );
            System.debug(LoggingLevel.INFO, 'PS_GEAIdPSecurityService.saveUser ' + newUser);
            System.debug('Test ###'+ Page.CustomerSSO.getUrl());
            PageReference loginPageReference = null;
            if(data.redirectUrl != null){
                loginPageReference = Site.login(
                    newUser.Username,
                    data.password,
                    data.redirectUrl);
            }
            else{
                loginPageReference = Site.login(
                    newUser.Username,
                    data.password,
                    Page.CustomerSSO.getUrl()
                );
            }

            generateAuthorizationFormConsent(newUser, siteConfig);

            if (Test.isRunningTest()) {
                loginPageReference = new PageReference('/apex/CustomerSSO');
            }
            result.success('User generated successfully', newUser, loginPageReference.getURL());

            return result;
        } catch (Exception ex) {
            System.debug('getStackTraceString(): ' + ex.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'PS_GEAIdPSecurityService.saveUser error: ' + ex.getMessage());

            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static Contact generateContact(GEAIdPSecutiryModel data) {
        PS_WebServiceUserInfoPasswordWrapper additionalInfo = new PS_WebServiceUserInfoPasswordWrapper();
        additionalInfo.mobile = data.mobilePhone;
        return PS_WebServiceUserInfoHelper.insertDummyAccountAndContact(
                data.firstName,
                data.lastName,
                data.email,
                data.registrationSource,
                data.socialProvider,
                additionalInfo
        );
    }

    public static void generateAuthorizationFormConsent(User newUser, Customer_IdP_Configuration__mdt siteConfig) {
        AuthorizationFormConsent afc = new AuthorizationFormConsent();
        afc.Name = newUser.Id + ' ' + System.today().format();
        system.debug('Inside the Authorization 1::: '+afc.Name);
        afc.ConsentGiverId = newUser.Id;
        afc.ConsentCapturedDateTime = Datetime.now();
        afc.ConsentCapturedSource = siteConfig.Terms_Consent_Capture_Source__c;
        afc.ConsentCapturedSourceType = siteConfig.Terms_Consent_Source_Type__c;
        afc.Status = siteConfig.Terms_Consent_Accepted_Status__c;

        System.debug('newUser: ' + JSON.serialize(newUser));

        //If the contact record is created but the user record could not, it is not possbile to access LanguageLocaleKey
        // try to access LanguageLocaleKey if an error occurs query the user record in order to retrieve LanguageLocaleKey
        try {
            String userLanguagreKey = newUser.LanguageLocaleKey;
        } catch (Exception e) {
            newUser = [SELECT Id,LanguageLocaleKey FROM User WHERE Id = :newUser.Id LIMIT 1];
        }
        system.debug('Inside the Authorization 2 Terms_Auth_Form_Name__c::: '+siteConfig.Terms_Auth_Form_Name__c);
        system.debug('Inside the Authorization 3 Terms_Auth_Form_Revision__c::: '+siteConfig.Terms_Auth_Form_Revision__c);
        List<Schema.AuthorizationFormText> aft = [
                SELECT Id,ContentDocumentId,AuthorizationForm.Name,AuthorizationForm.RevisionNumber
                FROM AuthorizationFormText
                WHERE Locale = :newUser.LanguageLocaleKey
                AND AuthorizationForm.Name = :siteConfig.Terms_Auth_Form_Name__c
                AND AuthorizationForm.RevisionNumber = :siteConfig.Terms_Auth_Form_Revision__c
                ORDER BY AuthorizationForm.EffectiveFromDate DESC
        ];

        if (!aft.isEmpty()) {
            afc.AuthorizationFormTextId = aft.get(0).Id;
            afc.DocumentVersionId = aft.get(0).ContentDocumentId;
        }

        insert afc;

        afc.Name = afc.Id + ' - ' + aft.get(0).AuthorizationForm.Name + ' - ' + aft.get(0).AuthorizationForm.RevisionNumber;
        update afc;

    }

    public static void verifyRecaptcha(String recaptchaResponse) {
        RecaptchaCallout recaptchaVerification = new RecaptchaCallout();
        if (!recaptchaVerification.verify(recaptchaResponse)) {
            AuraHandledException ahe = new AuraHandledException('reCAPTCHA is not verified');
            ahe.setMessage('reCAPTCHA is not verified');
            throw ahe;
        }
    }

    public class GEAIdPSecurityServiceResult {
        public String message { get; set; }
        public Boolean succeed { get; set; }
        public Object data { get; set; }
        public String loginPageReferenceURL { get; set; }

        public void success(String message, SObject data, String loginPageReferenceURL) {
            this.succeed = true;
            this.message = message;
            this.data = data;
            this.loginPageReferenceURL = loginPageReferenceURL;
        }
    }

    public class GEAIdPSecutiryModel {
        public String email { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String mobilePhone { get; set; }
        public String password { get; set; }
        public String timeZone { get; set; }
        public String language { get; set; }
        public String redirectUrl { get; set; }
        public String state { get; set; }
        public String registrationSource { get; set; }
        public String socialProvider { get; set; }

        public GEAIdPSecutiryModel() {
        }

        public GEAIdPSecutiryModel(String email, String firstName, String lastName) {
            this.email = email;
            this.firstName = firstName;
            this.lastName = lastName;
        }
    }
}
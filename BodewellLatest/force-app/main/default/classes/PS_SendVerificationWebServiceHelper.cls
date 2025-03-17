public without sharing class PS_SendVerificationWebServiceHelper {

    @TestVisible
    private static Boolean sendAsyncEmailConfirmation = false;
    @TestVisible
    private static Network testNetwork;

    private static final String DEFAULT_NETWORK_NAME = 'GEA';
    private static final String SUCCESS_URL_PARAM = 'successURL';
    private static final String REDIRECT_URL_PARAM = 'redirectURL';
    private static final String SUCCESS_STATE_URL_PARAM = 'successState';
    private static final String STATE_PARAM = 'state';

    private static Customer_IdP_Configuration__mdt siteConfig =
            PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();

    private Id networkId;
    private String experienceName;

    public PS_SendVerificationWebServiceHelper(String experienceName) {
        this.experienceName = experienceName;
        this.networkId = getNetwork(String.isBlank(experienceName)
                ? DEFAULT_NETWORK_NAME
                : experienceName).Id;
    }

    public void sendEmailVerificationToActiveChangedEmailUsers(
            Map<Id, User> newUsers,
            Map<Id, User> oldUsers
    ) {
        List<User> filterUsers = this.filterActiveChangedEmailUsers(
                newUsers, oldUsers
        );
        if (filterUsers.isEmpty()) {
            return;
        }

        Customer_IdP_Configuration__mdt config = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
        String urlCallback = config.Email_Verification_Success_URL__c;

        Map<String, Id> emailTemplateDevNameToId = new Map<String, Id>();
        for (EmailTemplate emailTemplate : [
                SELECT DeveloperName
                FROM EmailTemplate
                WHERE DeveloperName IN (
                        :config.Email_Template_Change_Email__c,
                        :config.Email_Template_Change_Email_it__c,
                        :config.Email_Template_Change_Email_es__c
                )
        ]) {
            emailTemplateDevNameToId.put(emailTemplate.DeveloperName, emailTemplate.Id);
        }

        for (User user : filterUsers) {
            String userLanguage = user.LanguageLocaleKey;

            String emailTemplateDeveloperName = '';
            //italian template
            if (userLanguage == 'it' || (userLanguage.length() > 2 && userLanguage.substring(0, 3) == 'it_')) {
                emailTemplateDeveloperName = config.Email_Template_Change_Email_it__c;
                //spanish template
            } else if (userLanguage == 'es' || (userLanguage.length() > 2 && userLanguage.substring(0, 3) == 'es_')) {
                emailTemplateDeveloperName = config.Email_Template_Change_Email_es__c;
            }
            //default template if not es or it or if no template specified
            if (String.isBlank(emailTemplateDeveloperName)) {
                emailTemplateDeveloperName = config.Email_Template_Change_Email__c;
            }

            if (emailTemplateDevNameToId.containsKey(emailTemplateDeveloperName)) {
                sendAsyncEmailConfirmation(
                        user.Id,
                        emailTemplateDevNameToId.get(emailTemplateDeveloperName),
                        this.networkId,
                        urlCallback
                );
            }
        }
    }

    public static void sendEmailVerification(
            String userId,
            Blob requestBody,
            String experienceName,
            String callbackUrl
    ) {
        Network network = getNetwork(experienceName);
        String userLanguage = getUserLanguage(userId);

        //default template
        String emailTemplateDeveloperName = siteConfig.Email_Template_Verification__c;
        system.debug('emailTemplateDeveloperName'+emailTemplateDeveloperName);
        //italian template
        if (userLanguage == 'it' || (userLanguage.length() > 2 && userLanguage.substring(0, 3) == 'it_')) {
            emailTemplateDeveloperName = siteConfig.Email_Template_Verification_it__c;
            //spanish template
        } else if (userLanguage == 'es' || (userLanguage.length() > 2 && userLanguage.substring(0, 3) == 'es_')) {
            emailTemplateDeveloperName = siteConfig.Email_Template_Verification_es__c;
        }

        List<EmailTemplate> emailTemplates = [
                SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName = :emailTemplateDeveloperName
        ];

        String urlCallback = String.isBlank(callbackUrl) ? getStartUrl(requestBody, userLanguage) : callbackUrl;
        sendAsyncEmailConfirmation(
                userId,
                emailTemplates[0].Id,
                network.Id,
                urlCallback
        );
    }

    private static void sendAsyncEmailConfirmation(
            String userId,
            String emailTemplateId,
            String networkId,
            String startUrl
    ) {
        if (!Test.isRunningTest() || sendAsyncEmailConfirmation) {
            System.UserManagement.sendAsyncEmailConfirmation(
                    userId,
                    emailTemplateId,
                    networkId,
                    startUrl
            );
        }
    }

    private List<User> filterActiveChangedEmailUsers(
            Map<Id, User> newUsers,
            Map<Id, User> oldUsers
    ) {
        //filter Active and User with changed email
        Map<Id, User> activeChangedEmailUsers = new Map<Id, User>();
        for (User newUser : newUsers.values()) {
            User oldUser = oldUsers.get(newUser.Id);
            if (newUser.IsActive && (newUser.Email != oldUser.Email)) {
                activeChangedEmailUsers.put(newUser.Id, newUser);
            }
        }
        if (activeChangedEmailUsers.isEmpty()) {
            return new List<User>();
        }

        //filter users based on Registration_Profile__c in config records
        Set<Id> registrationProfilesIds = new Set<Id>();
        for (Profile profile : [
                SELECT Id
                FROM Profile
                WHERE Name IN :PS_GEAIdPCustomerConfigHelper.getAllSiteConfigsRegistrationProfiles()
        ]) {
            registrationProfilesIds.add(profile.Id);
        }

        List<User> filteredUsers = new List<User>();
        for (User user : activeChangedEmailUsers.values()) {
            if (registrationProfilesIds.contains(user.ProfileId)) {
                filteredUsers.add(user);
            }
        }
        return filteredUsers;
    }

    private static String getUserLanguage(Id userId) {
        return [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :userId].LanguageLocaleKey;
    }

    public static String getStartUrl(Blob requestBody, String userLanguage) {
        if (requestBody.size() != 0) {
            Map<String, Object> reqBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody.toString());
            if (reqBodyMap.containsKey(SUCCESS_URL_PARAM)) {
                PageReference startUrl = new PageReference(System.Site.getBaseUrl() + Page.CustomerSSO.getUrl());

                startUrl.getParameters().put(REDIRECT_URL_PARAM, (String) reqBodyMap.get(SUCCESS_URL_PARAM));
                if (reqBodyMap.containsKey(SUCCESS_STATE_URL_PARAM)) {
                    startUrl.getParameters().put(STATE_PARAM, (String) reqBodyMap.get(SUCCESS_STATE_URL_PARAM));
                }

                return startUrl.getUrl();
            }
        }

        PageReference defaultStartLocation = new PageReference(PS_GEAIdPCustomerConfigHelper.getSiteConfiguration().Email_Verification_Success_URL__c);
        defaultStartLocation.getParameters().put('language', userLanguage);
        return defaultStartLocation.getURL();
    }

    public static Network getNetwork(String experienceName) {
        if (Test.isRunningTest() && testNetwork != null) {
            return testNetwork;
        }
        List<Network> networks = [
                SELECT Id,VerificationEmailTemplateId
                FROM Network
                WHERE UrlPathPrefix = :experienceName
        ];

        return networks.get(0);
    }
}
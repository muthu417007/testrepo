/**
 * description Auth.RegistrationHandler for Social Accounts
 * If the email is mathced with an active user login with that user
 * If  no matched emails found create Contact & User records
 * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_auth_plugin.htm
 */
public with sharing class SocialAuthRegistrationHandler implements Auth.RegistrationHandler {
    /**
     * Auth.RegistrationHandler createUser method
     */
    public User createUser(Id portalId, Auth.UserData data) {
        List<User> listUsers = getActiveUser(data);
        if (listUsers.size() < 1) {
            User u = createUserWithAuthData(data);
            listUsers.add(u);
        }
        return listUsers[0];
    }

    /**
     * Auth.RegistrationHandler updateUser method
     */
    public void updateUser(Id userId, Id portalId, Auth.UserData data) {
        //todo: we can do something when they login if needed
    }

    private List<User> getActiveUser(Auth.UserData data) {
        return [
                SELECT Id
                FROM User
                WHERE Email = :data.email
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
    }

    private User createUserWithAuthData(Auth.UserData data) {
        if (data.attributeMap.containsKey('sfdc_networkid')) {
            PS_GEAIdPSecurityService.GEAIdPSecutiryModel registrationData = new PS_GEAIdPSecurityService.GEAIdPSecutiryModel(
                    data.email,
                    data.firstName,
                    data.lastName
            );
            registrationData.socialProvider = data.provider;
            List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
            registrationData.registrationSource = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;

            Customer_IdP_Configuration__mdt siteConfig = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();

            Contact contact = PS_GEAIdPSecurityService.generateContact(registrationData);
            User newUser = PS_WebServiceUserInfoHelper.insertUser(
                    contact,
                    null,
                    true,
                    data.locale
            );
            PS_GEAIdPSecurityService.generateAuthorizationFormConsent(newUser, siteConfig);

            return newUser;
        } else {
            //This is not a community, TODO what should we do if it is not coming from community
            System.debug('Handle non community users');
        }
        return null;
    }
}
public without sharing class PS_WebServiceUserInfoHelper {

    private static final String GLOBAL_ID_PARAM = 'globalId';
    private static final String EMAIL_PARAM = 'email';
    private static final String USERNAME_SUFFIX = '@appliances.force.com';
	private static final Id consumerRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId(); //added for - JIRA CCOE-655
    
    @TestVisible
    private static String testAppName;

    private static Customer_IdP_Configuration__mdt siteConfig =
            PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();

    public PS_WebServiceUserInfoExtWrapper getUserInfoWrapper(
            User currentUser,
            Boolean includeGeolocationData,
            Boolean includeAddressData
    ) {
        return getUserInfoWrapper(
                currentUser,
                includeGeolocationData,
                includeAddressData,
                true
        );
    }

    public PS_WebServiceUserInfoExtWrapper getUserInfoWrapper(
            User currentUser,
            Boolean includeGeolocationData,
            Boolean includeAddressData,
            Boolean checkIsEmailVerified
    ) {
        PS_WebServiceUserInfoExtWrapper resultWrapper = new PS_WebServiceUserInfoExtWrapper();

        resultWrapper.globalId = currentUser.Contact?.Global_Customer_Id__c;
        resultWrapper.salesforceUserId = currentUser.Id;
        resultWrapper.sessionId = currentUser.Customer_IdP_Session_Id__c;
        resultWrapper.firstname = currentUser.FirstName;
        resultWrapper.lastname = currentUser.LastName;
        resultWrapper.email = currentUser.Email;
        resultWrapper.mobile = currentUser.MobilePhone;
        resultWrapper.language = currentUser.LanguageLocaleKey;
        resultWrapper.isEmailVerified = checkIsEmailVerified ? checkIfUserEmailIsVerified(currentUser) : false;
        resultWrapper.isFrozen = checkIfUserIsFrozen(currentUser.Id);
        resultWrapper.region = currentUser.ServerRegion__c;
        resultWrapper.thirdPartyUserId = getThirdPartyUserId(currentUser.Id);
        resultWrapper.acceptedTerms = getAcceptedTerms(currentUser.Id);
		resultWrapper.dealerID =currentUser.Account.dealer_id__C;
        if(siteConfig.QualifiedApiName=='AirAndWater')
            resultWrapper.UserAccess=currentUser.Contact.User_Access__c;
        
        if (includeGeolocationData &&
                (currentUser.Latitude != null || currentUser.Longitude != null)
                ) {
            PS_WebServiceUserInfoWrapper.Geolocation geolocation = new PS_WebServiceUserInfoWrapper.Geolocation();
            geolocation.latitude = currentUser.Latitude;
            geolocation.longitude = currentUser.Longitude;
            resultWrapper.geolocation = geolocation;
        }

        if (includeAddressData && isNotEmptyAccountData(currentUser)) {
            PS_WebServiceUserInfoWrapper.Address address = new PS_WebServiceUserInfoWrapper.Address();
            address.street = currentUser.Account.BillingStreet;
            address.city = currentUser.Account.BillingCity;
            address.state = currentUser.Account.BillingState;
            address.zipCode = currentUser.Account.BillingPostalCode;
            address.country = currentUser.Account.BillingCountry;
            resultWrapper.address = address;
        }

        return resultWrapper;
    }

    public PS_WebServiceUserInfoExtAdminWrapper includeUsername(
            User currentUser,
            PS_WebServiceUserInfoExtWrapper wrapper
    ) {
        PS_WebServiceUserInfoExtAdminWrapper resultWrapper =
                (PS_WebServiceUserInfoExtAdminWrapper) JSON.deserialize(
                        JSON.serialize(wrapper),
                        PS_WebServiceUserInfoExtAdminWrapper.class
                );
        resultWrapper.salesforceUsername = currentUser.Username;
        return resultWrapper;
    }

    public static String getContactGlobalId(Id contactId) {
        return [
                SELECT Global_Customer_Id__c
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
        ].Global_Customer_Id__c;
    }

    private static Boolean checkIfUserEmailIsVerified(User user) {
        if (user.Is_User_Verified_Manual__c) {
            return true;
        }
        List<TwoFactorMethodsInfo> twoFactorMethodsInfo = [
                SELECT
                        HasUserVerifiedEmailAddress
                FROM TwoFactorMethodsInfo
                WHERE UserId = :user.Id
                LIMIT 1
        ];
        if (twoFactorMethodsInfo.isEmpty()) {
            return false;
        }
        return twoFactorMethodsInfo.get(0).HasUserVerifiedEmailAddress;
    }

    private static Boolean checkIfUserIsFrozen(String userId) {
        for (UserLogin userLogin : [SELECT IsFrozen FROM UserLogin WHERE UserId = :userId]) {
            if (userLogin.IsFrozen) {
                return true;
            }
        }
        return false;
    }

    private static String getThirdPartyUserId(String userId) {
        String applicationName;

        if (Test.isRunningTest() && testAppName != null) {
            applicationName = testAppName;
        } else {
            String loginHistoryId = Auth.SessionManagement.getCurrentSession()?.get('LoginHistoryId');
            List<LoginHistory> loginHistories = [
                    SELECT Id,Application
                    FROM LoginHistory
                    WHERE Id = :loginHistoryId
            ];
            if (loginHistories.isEmpty()) {
                return null;
            }
            applicationName = loginHistories.get(0).Application;
        }

        Connected_Application_Reference__mdt connectedApplicationReference =
                PS_ConnectedAppReferenceHelper.getConnectedAppReferenceConfigByName(applicationName);

        if (connectedApplicationReference == null
                || String.isBlank(connectedApplicationReference.Connected_App_Id__c)) {
            return null;
        }

        List<UserProvAccount> userProvAccounts = [
                SELECT ExternalUserId
                FROM UserProvAccount
                WHERE SalesforceUserId = :userId
                AND ConnectedAppId = :connectedApplicationReference.Connected_App_Id__c
                LIMIT 1
        ];
        if (userProvAccounts.isEmpty()) {
            return null;
        }

        return userProvAccounts.get(0).ExternalUserId;
    }

    private static List<PS_WebServiceUserInfoWrapper.AcceptedTerms> getAcceptedTerms(String userId) {
        List<PS_WebServiceUserInfoWrapper.AcceptedTerms> acceptedTerms = new List<PS_WebServiceUserInfoWrapper.AcceptedTerms>();
        for (AuthorizationFormConsent consent : [
                SELECT Id,AuthorizationFormText.AuthorizationForm.Name,
                        AuthorizationFormText.AuthorizationForm.RevisionNumber,
                        AuthorizationFormText.Locale,ConsentCapturedDateTime
                FROM AuthorizationFormConsent
                WHERE ConsentGiverId = :userId
        ]) {
            PS_WebServiceUserInfoWrapper.AcceptedTerms term = new PS_WebServiceUserInfoWrapper.AcceptedTerms();
            term.name = consent.AuthorizationFormText.AuthorizationForm.Name;
            term.revision = consent.AuthorizationFormText.AuthorizationForm.RevisionNumber;
            term.language = consent.AuthorizationFormText.Locale;
            term.consentDateTime = consent.ConsentCapturedDateTime;
            acceptedTerms.add(term);
        }
        return acceptedTerms;
    }

    public static void insertMissingAuthorizationFormConsents(
            User currentUser,
            PS_WebServiceUserInfoWrapper bodyWrapper
    ) {
        if (bodyWrapper.acceptedTerms != null) {
            Set<String> authNames = new Set<String>();
            Set<String> authRevisions = new Set<String>();
            Set<String> authLanguages = new Set<String>();
            for (PS_WebServiceUserInfoWrapper.AcceptedTerms acceptedTerm : bodyWrapper.acceptedTerms) {
                authNames.add(acceptedTerm.name);
                authRevisions.add(acceptedTerm.revision);
                authLanguages.add(acceptedTerm.language);
            }

            Map<String, AuthorizationFormText> authKeyToAuthFormText = new Map<String, AuthorizationFormText>();
            for (AuthorizationFormText authFormText : [
                    SELECT AuthorizationForm.Name,AuthorizationForm.RevisionNumber,Locale
                    FROM AuthorizationFormText
                    WHERE AuthorizationForm.Name IN :authNames
                    OR AuthorizationForm.RevisionNumber IN :authRevisions
                    OR Locale IN :authLanguages
                    ORDER BY AuthorizationForm.EffectiveFromDate ASC
            ]) {
                authKeyToAuthFormText.put(
                        authFormText.AuthorizationForm.Name +
                                authFormText.AuthorizationForm.RevisionNumber +
                                authFormText.Locale
                        , authFormText
                );
            }

            Set<String> authKeys = new Set<String>();
            for (AuthorizationFormConsent consent : [
                    SELECT AuthorizationFormText.AuthorizationForm.Name,
                            AuthorizationFormText.AuthorizationForm.RevisionNumber,
                            AuthorizationFormText.Locale
                    FROM AuthorizationFormConsent
                    WHERE (AuthorizationFormText.AuthorizationForm.Name IN :authNames
                    OR AuthorizationFormText.AuthorizationForm.RevisionNumber IN :authRevisions
                    OR AuthorizationFormText.Locale IN :authLanguages)
                    AND ConsentGiverId = :currentUser.Id
            ]) {
                authKeys.add(
                        consent.AuthorizationFormText.AuthorizationForm.Name +
                                consent.AuthorizationFormText.AuthorizationForm.RevisionNumber +
                                consent.AuthorizationFormText.Locale
                );
            }

            List<AuthorizationFormConsent> authorizationFormConsentsToInsert = new List<AuthorizationFormConsent>();
            for (PS_WebServiceUserInfoWrapper.AcceptedTerms acceptedTerm : bodyWrapper.acceptedTerms) {
                String termKey = acceptedTerm.name + acceptedTerm.revision + acceptedTerm.language;

                if (!authKeys.contains(termKey)) {

                    AuthorizationFormText authorizationFormText = authKeyToAuthFormText.get(termKey);
                    if (authorizationFormText == null) {
                        throw new NoDataFoundException('No related authorization form text found.');
                    }

                    AuthorizationFormConsent authorizationFormConsent = new AuthorizationFormConsent();
                    authorizationFormConsent.ConsentGiverId = currentUser.Id;
                    authorizationFormConsent.Name = currentUser.Id + ' - ' +
                            authorizationFormText.AuthorizationForm.Name.left(200) + ' - ' +
                            authorizationFormText.AuthorizationForm.RevisionNumber;
                    authorizationFormConsent.AuthorizationFormTextId = authorizationFormText.Id;
                    authorizationFormConsent.ConsentCapturedDateTime = acceptedTerm.consentDateTime;
                    authorizationFormConsent.ConsentCapturedSource = siteConfig.Terms_Consent_Capture_Source__c;
                    authorizationFormConsent.ConsentCapturedSourceType = siteConfig.Terms_Consent_Source_Type__c;
                    authorizationFormConsent.Status = siteConfig.Terms_Consent_Accepted_Status__c;

                    authorizationFormConsentsToInsert.add(authorizationFormConsent);
                }
            }
            insert authorizationFormConsentsToInsert;
        }
    }

    public static Contact insertDummyAccountAndContact(
            String firstName,
            String lastName,
            String email
    ) {
        return insertDummyAccountAndContact(firstName, lastName, email, null, null);
    }

    public static Contact insertDummyAccountAndContact(
            String firstName,
            String lastName,
            String email,
            String registrationSource
    ) {
        return insertDummyAccountAndContact(
                firstName,
                lastName,
                email,
                registrationSource,
                null,
                null
        );
    }

    public static Contact insertDummyAccountAndContact(
            String firstName,
            String lastName,
            String email,
            String registrationSource,
            String socialProvider
    ) {
        return insertDummyAccountAndContact(
                firstName,
                lastName,
                email,
                registrationSource,
                socialProvider,
                null
        );
    }

    public static Contact insertDummyAccountAndContact(
            String firstName,
            String lastName,
            String email,
            String registrationSource,
            String socialProvider,
            PS_WebServiceUserInfoPasswordWrapper additionalInfo
    ) {
        Contact contact;
      
       /* Check if a Person Account or a Consumer Contact already exists in the system */
       List<Contact> contacts = [
                SELECT Id, FirstName, LastName, Email, Global_Customer_Id__c,CreatedDate
                FROM Contact
                WHERE Email = :email and (RecordTypeId = :consumerRTId or isPersonAccount = true) //Added recordtype condition for CC0E - 655 
        ];
        
        if (!contacts.isEmpty()) {
            List<contact> updateContactList = new List<Contact> (); //added for - JIRA CCOE-605
            contact = contacts[0];
            //Override with new values
            if (String.isNotBlank(firstName)) {
                contact.FirstName = firstName;
            }
            if (String.isNotBlank(lastName)) {
                contact.LastName = lastName;
            }
            if (String.isNotBlank(additionalInfo.mobile)) {
                contact.MobilePhone = additionalInfo.mobile;
            }
           if (registrationSource == 'bodewellCommerce'){
                contact.Registration_Source__c = registrationSource;
            }
            System.debug('registrationSource Test ###' + registrationSource);
            update contact;
            //Start - newly logic added to update new global contact id - JIRA CCOE-605
            updateContactList.add(contact);
            if (String.isBlank(contact.Global_Customer_Id__c))
            {
                PS_ContactTriggerHandlerHelper psContactTriggerHandlerHelper = new PS_ContactTriggerHandlerHelper(true);
                psContactTriggerHandlerHelper.setContactsGlobalIds((List<Contact>) updateContactList);    
            }
            update updateContactList;
            //End JIRA CCOE-605
        } else {
             
            // Create a new Person Account
            /* Commented for Person Account Creation */
           /* Account dummyAccount = (Account) JSON.deserialize(
                    siteConfig.Registration_Account_Defaults__c, Account.class
            );
            dummyAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                    .get(siteConfig.Registration_Account_RecordType__c).getRecordTypeId();

            if (String.isNotBlank(additionalInfo?.address?.street)) {
                dummyAccount.BillingStreet = additionalInfo.address?.street;
            }
            if (String.isNotBlank(additionalInfo?.address?.city)) {
                dummyAccount.BillingCity = additionalInfo.address?.city;
            }
            if (String.isNotBlank(additionalInfo?.address?.state)) {
                dummyAccount.BillingState = additionalInfo.address?.state;
            }
            if (String.isNotBlank(additionalInfo?.address?.zipCode)) {
                dummyAccount.BillingPostalCode = additionalInfo.address?.zipCode;
            }
            if (String.isNotBlank(additionalInfo?.address?.country)) {
                dummyAccount.BillingCountry = additionalInfo.address?.country;
            }

            insert dummyAccount;

            contact = (Contact) JSON.deserialize(
                    siteConfig.Registration_Contact_Defaults__c, Contact.class
            );
            if (String.isNotBlank(firstName)) {
                contact.FirstName = firstName;
            }
            if (String.isNotBlank(lastName)) {
                contact.LastName = lastName;
            }
            if (String.isNotBlank(email)) {
                contact.Email = email;
            }
            if (String.isNotBlank(registrationSource)) {
                contact.Registration_Source__c = registrationSource;
            }

            if (String.isNotBlank(socialProvider)) {
                socialProvider = socialProvider.toLowerCase();

                Set<String> contactSocialProviders =
                        String.isBlank(contact.Social_Provider__c)
                                ? new Set<String>()
                                : new Set<String>(contact.Social_Provider__c?.split(';'));
                contactSocialProviders.add(socialProvider);
                contact.Social_Provider__c = String.join(new List<String>(contactSocialProviders), ';');
            }

            contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                    .get(siteConfig.Registration_Contact_RecordType__c).getRecordTypeId();
            contact.AccountId = dummyAccount.Id;

            if (additionalInfo != null && String.isNotBlank(additionalInfo.mobile)) {
                contact.MobilePhone = additionalInfo.mobile;
            }

          insert contact;*/
           String globalId;
           if (String.isBlank(globalId)) {
                PS_ContactTriggerHandlerHelper psContactTriggerHandlerHelper = new PS_ContactTriggerHandlerHelper(true);
                globalId = psContactTriggerHandlerHelper.setGlobalIdForPersonContact(globalId);
          }
          system.debug('globalId ::: '+ globalId); 
          //Changed class name -  BWC_PersonAccountService
          BWC_PersonAccountService perAccount = new BWC_PersonAccountService();
          Account personAccountRecord = perAccount.createPersonAccount(firstname, lastname, email, globalId, registrationSource,socialProvider, additionalInfo );
          
          contact = [SELECT Id,FirstName, LastName, Email, Global_Customer_Id__c FROM CONTACT WHERE AccountId = :personAccountRecord.Id LImit 1];         
          system.debug('Contact Id ::: '+ contact.Id);
                                
       }

        return contact;
    }

    public static User insertUser(
            Contact contact,
            String password,
            Boolean sendEmailNotification,
            String language
    ) {
        return insertUser(
                contact,
                password,
                sendEmailNotification,
                language,
                null,
                null
        );
    }

    public static User insertUser(
            Contact contact,
            String password,
            Boolean sendEmailNotification,
            String language,
            PS_WebServiceUserInfoPasswordWrapper additionalInfo,
            String mobilePhone
    ) {
        List<User> users = [
                SELECT Id, Username, FirstName, LastName, Email, ContactId
                FROM User
                WHERE Email = :contact.Email
                AND ContactId = :contact.Id
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
        ];
        if (!users.isEmpty()) {
            throw new DuplicateUserEmailException();
        }

        Profile communityProfile = [
                SELECT Id
                FROM Profile
                WHERE Name = :siteConfig.Registration_Profile__c
                LIMIT 1
        ];

        String defaultLastName = ((Contact) JSON.deserialize(
                siteConfig.Registration_Contact_Defaults__c, Contact.class
        )).LastName;

        User newUser = new User();
        newUser.FirstName = contact.FirstName;
        newUser.LastName = String.isBlank(contact.LastName) ? defaultLastName : contact.LastName;
        if (String.isNotBlank(mobilePhone)) {
            newUser.MobilePhone = mobilePhone;
        }
        newUser.Username = generateUsername(contact);
        newUser.Email = contact.Email;
        newUser.ContactId = contact.Id;
        newUser.ProfileId = communityProfile.Id;
        newUser.Alias = generateAlias(contact);
        newUser.LocaleSidKey = getLocaleKey(language);
        newUser.LanguageLocaleKey = getLanguageKey(language);
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.TimeZoneSidKey = UserInfo.getTimeZone().getID(); //TODO: Review with Arturs String.isBlank(data.timeZone) ? UserInfo.getTimezone().getID() : data.timeZone;
        newUser.CommunityNickname = generateCommunityNickname(newUser.Alias);

        if (additionalInfo != null) {
            newUser.Latitude = additionalInfo.geolocation?.latitude;
            newUser.Longitude = additionalInfo.geolocation?.longitude;
            newUser.ServerRegion__c = additionalInfo.region;
            newUser.MobilePhone = additionalInfo.mobile;
        }
        		
		//////////////////////////////START OF CHANGES FOR JIRA# CCOE-661 AND CCOE-537///////////////////////////////
        Contact[] con = [Select AccountId,Id from Contact where Id =: newUser.ContactId LIMIT 1];
        if (con.size() > 0)
        {
            
            if(con[0].AccountId == null)
            {
                Account objDummyAccount;
                objDummyAccount = CreateDummyAccount.FuncCreateDummyAccount();
                con[0].AccountId =  objDummyAccount.Id;
                update con;
            }
            
            
            /*GEA_AccountContactRelation__c newACR = new GEA_AccountContactRelation__c();
            newACR.Contact__c = con[0].Id;
            newACR.Account__c = con[0].AccountId;
            insert newACR;*/
            
        }
        //////////////////////////////END OF CHANGES FOR JIRA# CCOE-661 AND CCOE-537///////////////////////////////
		
        insert newUser;
        if (String.isNotBlank(password)) {
            if (!Test.isRunningTest()) {
                Site.validatePassword(newUser, password, password);
            }
            System.setPassword(newUser.Id, password);
        }

        if (additionalInfo?.isFrozen != null && additionalInfo.isFrozen) {
            List<UserLogin> userLogins = [
                    SELECT IsFrozen
                    FROM UserLogin
                    WHERE UserId = :newUser.Id
                    ORDER BY LastModifiedDate DESC
            ];
            if (userLogins.isEmpty()) {
                throw new NoDataFoundException('Can not freeze this user.');
            }
            userLogins.get(0).IsFrozen = true;
            update userLogins;
        }

        if (sendEmailNotification) {
            sendEmailNotification(newUser.Id, String.isBlank(language) ? 'en' : language);
        }

        return newUser;
    }

    public static User getUserById(Id userId) {
        return [
                SELECT Username,LanguageLocaleKey,Customer_IdP_Session_Id__c,Contact.Global_Customer_Id__c,
                        FirstName,LastName,MobilePhone,ServerRegion__c,Latitude,Email,
                        Longitude,Account.BillingStreet,Account.BillingCity,Account.BillingState,
                        Account.BillingPostalCode,Account.BillingCountry,Is_User_Verified_Manual__c,Account.dealer_id__C,Contact.User_Access__c,CX_Profile_Name__c
                FROM User
                WHERE Id = :userId
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
        ];
    }

    public static List<User> getUsersByEmail(String email) {
        return [
                SELECT Username,LanguageLocaleKey
                FROM User
                WHERE Email = :email
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
        ];
    }

    public static List<User> getUsersByUserName(String username) {
        return [
                SELECT Username,LanguageLocaleKey
                FROM User
                WHERE Username = :username
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
        ];
    }

    public static List<User> getUsersByContactGlobalId(String globalId) {
        return [
                SELECT Id
                FROM User
                WHERE Contact.Global_Customer_Id__c = :globalId
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
        ];
    }

    public static List<User> getUsersByCustomerSessionId(String sessionId) {
        return [
                SELECT Id,Contact.Global_Customer_Id__c
                FROM User
                WHERE Customer_IdP_Session_Id__c = :sessionId
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
        ];
    }

    public static List<User> getUsersByGlobalIdOrEmail(Map<String, String> params) {
        List<User> users = new List<User>();
        if (params.containsKey(GLOBAL_ID_PARAM)) {
            users = [
                    SELECT FirstName,LastName,Username,MobilePhone,Name,IsActive,
                            LanguageLocaleKey,ServerRegion__c,IsPortalEnabled,Email,
                            Contact.Global_Customer_Id__c,Customer_IdP_Session_Id__c,
                            Latitude,Longitude,Account.BillingStreet,Account.BillingCity,
                            Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,
                            Is_User_Verified_Manual__c,Account.dealer_id__C,CX_Profile_Name__c
                    FROM User
                    WHERE Contact.Global_Customer_Id__c = :params.get(GLOBAL_ID_PARAM)
                    AND IsActive = TRUE
                    AND IsPortalEnabled = TRUE
                    LIMIT 1
            ];
        } else if (params.containsKey(EMAIL_PARAM)) {
            users = [
                    SELECT FirstName,LastName,Username,MobilePhone,Name,IsActive,
                            LanguageLocaleKey,ServerRegion__c,IsPortalEnabled,Email,
                            Contact.Global_Customer_Id__c,Customer_IdP_Session_Id__c,
                            Latitude,Longitude,Account.BillingStreet,Account.BillingCity,
                            Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,
                            Is_User_Verified_Manual__c,Account.dealer_id__C,CX_Profile_Name__c
                    FROM User
                    WHERE Contact.Email = :params.get(EMAIL_PARAM)
                    AND IsActive = TRUE
                    AND IsPortalEnabled = TRUE
            ];
        }
        return users;
    }

    public static void updateCurrentUser(PS_WebServiceUserInfoWrapper userInfo) {
        User currentUser = new User(
                Id = System.UserInfo.getUserId()
        );

        if (String.isNotBlank(userInfo.firstname)) {
            currentUser.FirstName = userInfo.firstname;
        }
        if (String.isNotBlank(userInfo.lastname)) {
            currentUser.LastName = userInfo.lastname;
        }
        if (String.isNotBlank(userInfo.email)) {
            currentUser.Email = userInfo.email;
        }
        if (String.isNotBlank(userInfo.mobile)) {
            currentUser.MobilePhone = userInfo.mobile;
        }
        if (String.isNotBlank(userInfo.language)) {
            currentUser.LanguageLocaleKey = userInfo.language;
        }

        update currentUser;
    }

    public static void updateUserAccount(User currentUser, PS_WebServiceUserInfoWrapper bodyWrapper) {
          
        Account userAccount = new Account(
                Id = currentUser.AccountId
        );
        if (String.isNotBlank(bodyWrapper.address.street)) {
            userAccount.BillingStreet = bodyWrapper.address.street;
        }
        if (String.isNotBlank(bodyWrapper.address.city)) {
            userAccount.BillingCity = bodyWrapper.address.city;
        }
        if (String.isNotBlank(bodyWrapper.address.state)) {
            userAccount.BillingState = bodyWrapper.address.state;
        }
        if (String.isNotBlank(bodyWrapper.address.zipCode)) {
            userAccount.BillingPostalCode = bodyWrapper.address.zipCode;
        }
        if (String.isNotBlank(bodyWrapper.address.country)) {
            userAccount.BillingCountry = bodyWrapper.address.country;
        }

        update userAccount;
    }

    public static void freezeUser(Id userId, Boolean isFrozen) {
        List<UserLogin> userLogins = [
                SELECT IsFrozen
                FROM UserLogin
                WHERE UserId = :userId
                ORDER BY LastModifiedDate DESC
        ];
        if (userLogins.isEmpty()) {
            throw new NoDataFoundException('Can not freeze this user.');
        }
        userLogins.get(0).IsFrozen = isFrozen;
        update userLogins;
    }

    private static String getLocaleKey(String language) {
        if (String.isNotBlank(language)) {
            if (language.startsWith('it')) {
                return 'it_IT';
            }
            if (language.startsWith('es')) {
                return 'es_ES';
            }
        }
        return 'en_US';
    }

    private static String getLanguageKey(String language) {
        if (String.isNotBlank(language)) {
            if (language.startsWith('it')) {
                return 'it';
            }
            if (language.startsWith('es')) {
                return 'es';
            }
        }
        return 'en_US';
    }

    private static String generateUsername(Contact customerContact) {
        String globalCustomerId =
                (!customerContact.isSet(Contact.Global_Customer_Id__c) || String.isBlank(customerContact.Global_Customer_Id__c)) ?
                        [
                                SELECT Global_Customer_Id__c
                                FROM Contact
                                WHERE Id = :customerContact.Id
                                LIMIT 1
                        ].Global_Customer_Id__c :
                        customerContact.Global_Customer_Id__c;

        return globalCustomerId + USERNAME_SUFFIX;
    }

    private static String generateAlias(Contact contact) {
        Integer aliasLength = 0;
        if (contact.LastName.length() < 5) {
            aliasLength = contact.LastName.length();
        } else {
            aliasLength = 5;
        }

        String alias = String.isBlank(contact.FirstName) ? '' : contact.FirstName.substring(0, 1);
        alias += contact.LastName.substring(0, aliasLength);
        return alias;
    }

    private static String generateCommunityNickname(String alias) {
        return 'ExtUser' + alias + Datetime.now().getTime();
    }

    private static void sendEmailNotification(Id userId, String language) {
        final String language639_1 = language?.left(2);
        String emailTemplateDeveloperName;
        try {
            emailTemplateDeveloperName = String.valueOf(siteConfig.get('Email_Template_Welcome_' + language639_1 + '__c'));
        } catch (Exception ex) {
            emailTemplateDeveloperName = siteConfig.Email_Template_Welcome__c;
        }

        List<EmailTemplate> emailTemplates = [
                SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName = :emailTemplateDeveloperName
        ];

        PageReference startUrl = new PageReference(PS_GEAIdPCustomerConfigHelper.getSiteConfiguration().Email_Verification_Success_URL__c);
        startURL.getParameters().put('language', language);

        if (!UserManagement.sendAsyncEmailConfirmation(
                userId,
                String.valueOf(emailTemplates[0].Id),
                Network.getNetworkId(),
                startUrl.getURL()
        )) {
            throw new SendAsyncEmailConfirmationException('Unable to send verification email.');
        }
    }

    private static Boolean isNotEmptyAccountData(User currentUser) {
        return String.isNotBlank(currentUser?.Account?.BillingStreet)
                || String.isNotBlank(currentUser?.Account?.BillingCity)
                || String.isNotBlank(currentUser?.Account?.BillingState)
                || String.isNotBlank(currentUser?.Account?.BillingPostalCode)
                || String.isNotBlank(currentUser?.Account?.BillingCountry);
    }
   
    @TestVisible
    private class NoDataFoundException extends Exception {
    }
    
    public class DuplicateUserEmailException extends Exception {
    }

    private class SendAsyncEmailConfirmationException extends Exception {
    }
}
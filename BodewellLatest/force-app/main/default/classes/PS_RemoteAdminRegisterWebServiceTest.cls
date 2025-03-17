@IsTest
public with sharing class PS_RemoteAdminRegisterWebServiceTest {

    private static final String CLASS_NAME = PS_RemoteAdminRegisterWebServiceTest.class
            .getName()
            .substring(0, 15);
    private static final String TEST_APP_NAME = 'TestApp';
    private static final String TEST_FIRST_NAME = 'TestFirstName';
    private static final String TEST_LAST_NAME = 'TestLastName';
    private static final String TEST_MOBILE = '1234567890';
    private static final String TEST_EMAIL = System.now().millisecond() +
            Math.rint(Math.random() * 1000) + 'newemail@test4431.com';
    private static final String TEST_LANGUAGE_KEY = 'en_US';
    private static final String TEST_STREET = 'TestStreet';
    private static final String TEST_CITY = 'TestCity';
    private static final String TEST_STATE = 'TestState';
    private static final String TEST_POSTAL_CODE = '123-332';
    private static final String TEST_COUNTRY = 'TestCountry';
    private static final String TEST_REGION = 'TestRegion';
    private static final String TEST_AUTH_FORM = 'TestAuthForm';
    private static final String TEST_REVISION_NUMBER = '987654';

    @TestSetup
    public static void createData() {
        PS_TestHelper.createRemoteAdminUser(CLASS_NAME);
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
    }

    @IsTest
    public static void shouldRegisterNewUser_WhenValidParameters() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given

        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(users.get(0)) {
            UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            AuthorizationForm authorizationForm = new AuthorizationForm(
                    Name = TEST_AUTH_FORM,
                    RevisionNumber = TEST_REVISION_NUMBER
            );
            insert authorizationForm;

            AuthorizationForm authorizationForm2 = new AuthorizationForm(
                    Name = TEST_AUTH_FORM,
                    RevisionNumber = TEST_REVISION_NUMBER + 1
            );
            insert authorizationForm2;

            AuthorizationFormText authorizationFormText = new AuthorizationFormText(
                    Name = 'testAuthFormText',
                    AuthorizationFormId = authorizationForm.Id,
                    Locale = TEST_LANGUAGE_KEY
            );
            insert authorizationFormText;
            AuthorizationFormText authorizationFormText2 = new AuthorizationFormText(
                    Name = 'testAuthFormText',
                    AuthorizationFormId = authorizationForm2.Id,
                    Locale = TEST_LANGUAGE_KEY
            );
            insert authorizationFormText2;
        }

        PS_WebServiceUserInfoPasswordWrapper userInfoPasswordWrapper = new PS_WebServiceUserInfoPasswordWrapper();
        userInfoPasswordWrapper.firstname = TEST_FIRST_NAME;
        userInfoPasswordWrapper.lastname = TEST_LAST_NAME;
        userInfoPasswordWrapper.email = TEST_EMAIL;
        userInfoPasswordWrapper.mobile = TEST_MOBILE;
        userInfoPasswordWrapper.language = TEST_LANGUAGE_KEY;
        userInfoPasswordWrapper.region = TEST_REGION;
        userInfoPasswordWrapper.password = 'TestPass1234%$!';
        userInfoPasswordWrapper.isFrozen = false;
        PS_WebServiceUserInfoWrapper.Address address = new PS_WebServiceUserInfoWrapper.Address();
        address.street = TEST_STREET;
        address.state = TEST_STATE;
        address.city = TEST_CITY;
        address.zipCode = TEST_POSTAL_CODE;
        address.country = TEST_COUNTRY;
        userInfoPasswordWrapper.address = address;
        PS_WebServiceUserInfoWrapper.Geolocation geolocation = new PS_WebServiceUserInfoWrapper.Geolocation();
        geolocation.latitude = 10;
        geolocation.longitude = 10;
        userInfoPasswordWrapper.geolocation = geolocation;

        PS_WebServiceUserInfoWrapper.AcceptedTerms acceptedTerm = new PS_WebServiceUserInfoWrapper.AcceptedTerms();
        acceptedTerm.name = TEST_AUTH_FORM;
        acceptedTerm.revision = TEST_REVISION_NUMBER;
        acceptedTerm.language = TEST_LANGUAGE_KEY;
        PS_WebServiceUserInfoWrapper.AcceptedTerms acceptedTerm2 = new PS_WebServiceUserInfoWrapper.AcceptedTerms();
        acceptedTerm2.name = TEST_AUTH_FORM;
        acceptedTerm2.revision = TEST_REVISION_NUMBER + 1;
        acceptedTerm2.language = TEST_LANGUAGE_KEY;

        userInfoPasswordWrapper.acceptedTerms =
                new List<PS_WebServiceUserInfoWrapper.AcceptedTerms>{
                        acceptedTerm,
                        acceptedTerm2
                };

        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(JSON.serialize(userInfoPasswordWrapper));

        //then
        System.runAs(PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME)) {
            Test.startTest();
            PS_WebServiceUserInfoHelper.testAppName = TEST_APP_NAME;
            RestContext.request = request;
            PS_WebServiceUserInfoExtWrapper resultWrapper = PS_RemoteAdminRegisterWebService.register();
            Test.stopTest();

            System.assertEquals(
                    TEST_FIRST_NAME,
                    resultWrapper.firstname,
                    'Invalid firstname value'
            );

            System.assertEquals(
                    TEST_LAST_NAME,
                    resultWrapper.lastname,
                    'Invalid lastname value'
            );

            System.assertEquals(
                    TEST_EMAIL,
                    resultWrapper.email,
                    'Invalid email value'
            );

            System.assertEquals(
                    TEST_MOBILE,
                    resultWrapper.mobile,
                    'Invalid mobile value'
            );

            System.assertEquals(
                    TEST_LANGUAGE_KEY,
                    resultWrapper.language,
                    'Invalid language value'
            );

            System.assertEquals(
                    TEST_REGION,
                    resultWrapper.region,
                    'Invalid region value'
            );

            System.assertEquals(
                    false,
                    resultWrapper.isFrozen,
                    'Invalid isFrozen value'
            );

            System.assertNotEquals(
                    null,
                    resultWrapper.globalId,
                    'Invalid globalId value'
            );

            System.assertEquals(
                    TEST_STREET,
                    resultWrapper.address.street,
                    'Invalid street value'
            );

            System.assertEquals(
                    TEST_STATE,
                    resultWrapper.address.state,
                    'Invalid state value'
            );

            System.assertEquals(
                    TEST_CITY,
                    resultWrapper.address.city,
                    'Invalid city value'
            );

            System.assertEquals(
                    TEST_POSTAL_CODE,
                    resultWrapper.address.zipCode,
                    'Invalid zipCode value'
            );

            System.assertEquals(
                    TEST_COUNTRY,
                    resultWrapper.address.country,
                    'Invalid country value'
            );

            System.assertEquals(
                    10,
                    resultWrapper.geolocation.latitude,
                    'Invalid latitude value'
            );

            System.assertEquals(
                    10,
                    resultWrapper.geolocation.longitude,
                    'Invalid longitude value'
            );

            Account userAccount = [
                    SELECT Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry
                    FROM Account
                    LIMIT 1
            ];

            Contact contact = [
                    SELECT FirstName,LastName,AccountId,Email,MobilePhone,Global_Customer_Id__c
                    FROM Contact
                    WHERE Id IN (SELECT ContactId FROM User WHERE Id = :resultWrapper.salesforceUserId)
            ];

            System.assertEquals(
                    userAccount.Id,
                    contact.AccountId,
                    'Invalid contact accountId value'
            );

            System.assertEquals(
                    TEST_FIRST_NAME,
                    contact.FirstName,
                    'Invalid FirstName value'
            );

            System.assertEquals(
                    TEST_LAST_NAME,
                    contact.LastName,
                    'Invalid LastName value'
            );

            System.assertEquals(
                    TEST_EMAIL,
                    contact.Email,
                    'Invalid Email value'
            );

            System.assertEquals(
                    TEST_MOBILE,
                    contact.MobilePhone,
                    'Invalid mobile value'
            );

            System.assertNotEquals(
                    null,
                    contact.Global_Customer_Id__c,
                    'Invalid global customer Id value'
            );

            System.assertEquals(
                    TEST_STREET,
                    userAccount.BillingStreet,
                    'Invalid street value'
            );

            System.assertEquals(
                    TEST_CITY,
                    userAccount.BillingCity,
                    'Invalid city value'
            );

            System.assertEquals(
                    TEST_STATE,
                    userAccount.BillingState,
                    'Invalid state value'
            );

            System.assertEquals(
                    TEST_POSTAL_CODE,
                    userAccount.BillingPostalCode,
                    'Invalid postal code value'
            );

            System.assertEquals(
                    TEST_COUNTRY,
                    userAccount.BillingCountry,
                    'Invalid country value'
            );

            System.assertEquals(
                    2,
                    resultWrapper.acceptedTerms.size(),
                    'Invalid size of accepted terms'
            );

            List<AuthorizationFormConsent> insertedAuthFormConsents = [
                    SELECT Id
                    FROM AuthorizationFormConsent
                    WHERE ConsentGiverId = :resultWrapper.salesforceUserId
            ];

            System.assertEquals(
                    2,
                    insertedAuthFormConsents.size(),
                    'Invalid number of accepted terms inserted'
            );
        }
    }

    @IsTest
    public static void shouldRegisterNewUserWithExistingContact_WhenValidParameters() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given

        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(users.get(0)) {
            UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);
        }

        User testUser = new UserBuilder()
                .setDefault()
                .setFirstName(UserBuilder.TEST_USER_FIRST_NAME)
                .setProfile(UserBuilder.PROFILE_NAME_SYSTEM_ADMINISTRATOR)
                .setRole(UserBuilder.ROLE_DEVELOPERNAME_CEO)
                .save();

        String testEmail = 'testemail@invalid.com';
        System.runAs(testUser) {
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            insert testAccount;
            insert new Contact(
                    FirstName = 'TestFName',
                    AccountId = testAccount.Id,
                    LastName = 'TestLName',
                    Email = testEmail
            );
        }
        PS_WebServiceUserInfoPasswordWrapper userInfoPasswordWrapper = new PS_WebServiceUserInfoPasswordWrapper();
        userInfoPasswordWrapper.firstname = TEST_FIRST_NAME;
        userInfoPasswordWrapper.lastname = TEST_LAST_NAME;
        userInfoPasswordWrapper.email = testEmail;
        userInfoPasswordWrapper.mobile = TEST_MOBILE;
        userInfoPasswordWrapper.language = TEST_LANGUAGE_KEY;
        userInfoPasswordWrapper.region = TEST_REGION;
        userInfoPasswordWrapper.password = 'TestPass1234%$!';
        userInfoPasswordWrapper.isFrozen = false;

        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(JSON.serialize(userInfoPasswordWrapper));

        //then
        PS_WebServiceUserInfoExtWrapper resultWrapper;
        System.runAs(PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME)) {
            Test.startTest();
            PS_WebServiceUserInfoHelper.testAppName = TEST_APP_NAME;
            RestContext.request = request;
            resultWrapper = PS_RemoteAdminRegisterWebService.register();
            Test.stopTest();

            System.assertEquals(
                    TEST_FIRST_NAME,
                    resultWrapper.firstname,
                    'Invalid firstname value'
            );

            System.assertEquals(
                    TEST_LAST_NAME,
                    resultWrapper.lastname,
                    'Invalid lastname value'
            );

            System.assertEquals(
                    testEmail,
                    resultWrapper.email,
                    'Invalid email value'
            );

            System.assertEquals(
                    TEST_MOBILE,
                    resultWrapper.mobile,
                    'Invalid mobile value'
            );

            System.assertEquals(
                    TEST_LANGUAGE_KEY,
                    resultWrapper.language,
                    'Invalid language value'
            );

            System.assertEquals(
                    TEST_REGION,
                    resultWrapper.region,
                    'Invalid region value'
            );

            System.assertEquals(
                    false,
                    resultWrapper.isFrozen,
                    'Invalid isFrozen value'
            );

            System.assertNotEquals(
                    null,
                    resultWrapper.globalId,
                    'Invalid globalId value'
            );
        }

        Contact contact = [
                SELECT FirstName,LastName,AccountId,Email,MobilePhone,Global_Customer_Id__c
                FROM Contact
                WHERE Id IN (SELECT ContactId FROM User WHERE Id = :resultWrapper.salesforceUserId)
        ];

        System.assertNotEquals(
                null,
                contact.AccountId,
                'Invalid AccountId value'
        );

        System.assertEquals(
                TEST_FIRST_NAME,
                contact.FirstName,
                'Invalid FirstName value'
        );

        System.assertEquals(
                TEST_LAST_NAME,
                contact.LastName,
                'Invalid LastName value'
        );

        System.assertEquals(
                testEmail,
                contact.Email,
                'Invalid Email value'
        );

        System.assertEquals(
                TEST_MOBILE,
                contact.MobilePhone,
                'Invalid mobile value'
        );

        System.assertNotEquals(
                null,
                contact.Global_Customer_Id__c,
                'Invalid global customer Id value'
        );
    }

    @IsTest
    public static void shouldRegisterNewUserWithExistingContactAndNoLastName_WhenValidParameters() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given

        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(users.get(0)) {
            UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);
        }

        User testUser = new UserBuilder()
                .setDefault()
                .setFirstName(UserBuilder.TEST_USER_FIRST_NAME)
                .setProfile(UserBuilder.PROFILE_NAME_SYSTEM_ADMINISTRATOR)
                .setRole(UserBuilder.ROLE_DEVELOPERNAME_CEO)
                .save();

        String testEmail = 'testemail@invalid.com';
        System.runAs(testUser) {
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            insert testAccount;
            insert new Contact(
                    FirstName = TEST_FIRST_NAME,
                    AccountId = testAccount.Id,
                    LastName = TEST_LAST_NAME,
                    Email = testEmail
            );
        }
        PS_WebServiceUserInfoPasswordWrapper userInfoPasswordWrapper = new PS_WebServiceUserInfoPasswordWrapper();
        userInfoPasswordWrapper.firstname = null;
        userInfoPasswordWrapper.lastname = null;
        userInfoPasswordWrapper.email = testEmail;
        userInfoPasswordWrapper.mobile = TEST_MOBILE;
        userInfoPasswordWrapper.language = TEST_LANGUAGE_KEY;
        userInfoPasswordWrapper.region = TEST_REGION;
        userInfoPasswordWrapper.password = 'TestPass1234%$!';
        userInfoPasswordWrapper.isFrozen = false;

        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(JSON.serialize(userInfoPasswordWrapper));

        //then
        PS_WebServiceUserInfoExtWrapper resultWrapper;
        System.runAs(PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME)) {
            Test.startTest();
            PS_WebServiceUserInfoHelper.testAppName = TEST_APP_NAME;
            RestContext.request = request;
            resultWrapper = PS_RemoteAdminRegisterWebService.register();
            Test.stopTest();

            System.assertEquals(
                    TEST_FIRST_NAME,
                    resultWrapper.firstname,
                    'Invalid firstname value'
            );

            System.assertEquals(
                    TEST_LAST_NAME,
                    resultWrapper.lastname,
                    'Invalid lastname value'
            );

            System.assertEquals(
                    testEmail,
                    resultWrapper.email,
                    'Invalid email value'
            );

            System.assertEquals(
                    TEST_MOBILE,
                    resultWrapper.mobile,
                    'Invalid mobile value'
            );

            System.assertEquals(
                    TEST_LANGUAGE_KEY,
                    resultWrapper.language,
                    'Invalid language value'
            );

            System.assertEquals(
                    TEST_REGION,
                    resultWrapper.region,
                    'Invalid region value'
            );

            System.assertEquals(
                    false,
                    resultWrapper.isFrozen,
                    'Invalid isFrozen value'
            );

            System.assertNotEquals(
                    null,
                    resultWrapper.globalId,
                    'Invalid globalId value'
            );
        }

        Contact contact = [
                SELECT FirstName,LastName,AccountId,Email,MobilePhone,Global_Customer_Id__c
                FROM Contact
                WHERE Id IN (SELECT ContactId FROM User WHERE Id = :resultWrapper.salesforceUserId)
        ];

        System.assertNotEquals(
                null,
                contact.AccountId,
                'Invalid AccountId value'
        );

        System.assertEquals(
                TEST_FIRST_NAME,
                contact.FirstName,
                'Invalid FirstName value'
        );

        System.assertEquals(
                TEST_LAST_NAME,
                contact.LastName,
                'Invalid LastName value'
        );

        System.assertEquals(
                testEmail,
                contact.Email,
                'Invalid Email value'
        );

        System.assertEquals(
                TEST_MOBILE,
                contact.MobilePhone,
                'Invalid mobile value'
        );

        System.assertNotEquals(
                null,
                contact.Global_Customer_Id__c,
                'Invalid global customer Id value'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenMissingParam() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        Boolean exceptionThrown = false;
        PS_WebServiceUserInfoExtWrapper userInfoPasswordWrapper = new PS_WebServiceUserInfoExtWrapper();
        userInfoPasswordWrapper.firstname = TEST_FIRST_NAME;
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(JSON.serialize(userInfoPasswordWrapper));

        //then
        System.runAs(PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME)) {
            try {
                Test.startTest();
                RestContext.request = request;
                PS_RemoteAdminRegisterWebService.register();
                Test.stopTest();
            } catch (Exception e) {
                exceptionThrown = e instanceof IllegalArgumentException;
            }

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should be thrown'
            );
        }
    }

    @IsTest
    public static void shouldThrowError_WhenUserAlreadyExists() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        Boolean exceptionThrown = false;

        User adminUser = PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME);
        PS_WebServiceUserInfoPasswordWrapper userInfoPasswordWrapper = new PS_WebServiceUserInfoPasswordWrapper();
        userInfoPasswordWrapper.firstname = TEST_FIRST_NAME;
        userInfoPasswordWrapper.email = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0).Email;
        userInfoPasswordWrapper.password = 'TestPass1234%$!';
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(JSON.serialize(userInfoPasswordWrapper));

        //then
        System.runAs(adminUser) {
            try {
                Test.startTest();
                RestContext.request = request;
                PS_RemoteAdminRegisterWebService.register();
                Test.stopTest();
            } catch (Exception e) {
                exceptionThrown = e instanceof PS_RemoteAdminRegisterWebService.UserAlreadyExistsException;
            }

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should be thrown'
            );
        }
    }
}
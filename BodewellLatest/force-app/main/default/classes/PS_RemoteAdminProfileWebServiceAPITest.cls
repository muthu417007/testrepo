@IsTest
public with sharing class PS_RemoteAdminProfileWebServiceAPITest {
    private static final String CLASS_NAME = PS_RemoteAdminProfileWebServiceAPITest.class
            .getName()
            .substring(0, 15);
    private static final String TEST_APP_NAME = 'TestApp';
    private static final String TEST_FIRST_NAME = 'TestFirstName';
    private static final String TEST_LAST_NAME = 'TestLastName';
    private static final String TEST_AUTH_FORM = 'TestAuthForm';
    private static final String TEST_MOBILE = '1234567890';
    private static final String TEST_EMAIL = System.now().millisecond() +
            Math.rint(Math.random() * 1000) + 'newemail@test4431.com';
    private static final String TEST_USERNAME = 'testusername@tests.com';
    private static final String TEST_LANGUAGE_KEY = 'en_US';
    private static final String TEST_THIRD_PARTY_ID = '123456';
    private static final String TEST_REVISION_NUMBER = '987654';
    private static final String TEST_GLOBAL_CUSTOMER_ID = '987654';
    private static final String TEST_STREET = 'TestStreet';
    private static final String TEST_CITY = 'TestCity';
    private static final String TEST_STATE = 'TestState';
    private static final String TEST_POSTAL_CODE = '123-332';
    private static final String TEST_COUNTRY = 'TestCountry';
    private static final String TEST_REGION = 'TestRegion';

    @TestSetup
    public static void createData() {
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
        PS_TestHelper.createRemoteAdminUser(CLASS_NAME);
    }

    @IsTest
    public static void shouldReturnAllUserInformation_WhenGETCalledWithParam() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        List<User> adminUsers = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);

        System.runAs(adminUsers.get(0)) {
            ConnectedApplication connectedApplication =
                    UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            UserProvAccount userProvAccount = new UserProvAccount();
            userProvAccount.ConnectedAppId = connectedApplication.Id;
            userProvAccount.LinkState = 'linked';
            userProvAccount.Status = 'Active';
            userProvAccount.SalesforceUserId = portalUser.Id;
            userProvAccount.ExternalUserId = TEST_THIRD_PARTY_ID;
            insert userProvAccount;

            portalUser.FirstName = TEST_FIRST_NAME;
            portalUser.LastName = TEST_LAST_NAME;
            portalUser.Email = TEST_EMAIL;
            portalUser.MobilePhone = TEST_MOBILE;
            portalUser.LanguageLocaleKey = TEST_LANGUAGE_KEY;
            portalUser.ServerRegion__c = TEST_REGION;
            update portalUser;
        }

        AuthorizationForm authorizationForm = new AuthorizationForm(
                Name = TEST_AUTH_FORM,
                RevisionNumber = TEST_REVISION_NUMBER
        );
        insert authorizationForm;

        AuthorizationFormText authorizationFormText = new AuthorizationFormText(
                Name = 'testAuthFormText',
                AuthorizationFormId = authorizationForm.Id
        );
        insert authorizationFormText;

        AuthorizationFormConsent authorizationFormConsent = new AuthorizationFormConsent(
                Name = 'testAuthFormConsent',
                AuthorizationFormTextId = authorizationFormText.Id,
                ConsentGiverId = portalUser.Id
        );
        insert authorizationFormConsent;

        Contact contact = PS_TestHelper.getCreatedPortalContact(CLASS_NAME);
        contact.Global_Customer_Id__c = TEST_GLOBAL_CUSTOMER_ID;
        update contact;
		Test.startTest();
        Account account = PS_TestHelper.getCreatedPortalAccount(CLASS_NAME);
        account.BillingStreet = TEST_STREET;
        account.BillingCountry = TEST_COUNTRY;
        update account;

        System.runAs(portalUser) {

            
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
            RestContext.request = request;
            RestContext.response = new RestResponse();
            PS_WebServiceUserInfoHelper.testAppName = TEST_APP_NAME;
            PS_WebServiceUserInfoExtAdminWrapper userInfoWrapper = PS_RemoteAdminProfileWebServiceAPI.getUser();
            

            System.assertNotEquals(
                    null,
                    userInfoWrapper,
                    'Invalid userWrapper returned'
            );

            System.assertEquals(
                    portalUser.Id,
                    userInfoWrapper.salesforceUserId,
                    'Invalid id value'
            );

            System.assertEquals(
                    portalUser.Username,
                    userInfoWrapper.salesforceUsername,
                    'Invalid username value'
            );

            System.assertEquals(
                    TEST_FIRST_NAME,
                    userInfoWrapper.firstname,
                    'Invalid first name value'
            );

            System.assertEquals(
                    TEST_LAST_NAME,
                    userInfoWrapper.lastname,
                    'Invalid last name value'
            );

            System.assertEquals(
                    TEST_MOBILE,
                    userInfoWrapper.mobile,
                    'Invalid mobile value'
            );

            System.assertEquals(
                    TEST_LANGUAGE_KEY,
                    userInfoWrapper.language,
                    'Invalid language value'
            );

            System.assertEquals(
                    false,
                    userInfoWrapper.isEmailVerified,
                    'Invalid Is Email Verified value'
            );

            System.assertEquals(
                    false,
                    userInfoWrapper.isFrozen,
                    'Invalid Is Email Verified value'
            );

//            System.assertEquals(
//                    TEST_THIRD_PARTY_ID,
//                    userInfoWrapper.thirdPartyUserId,
//                    'Invalid third Party UserId value'
//            );

            System.assertEquals(
                    1,
                    userInfoWrapper.acceptedTerms.size(),
                    'Invalid number of accepted terms returned'
            );

            System.assertEquals(
                    TEST_AUTH_FORM,
                    userInfoWrapper.acceptedTerms.get(0).name,
                    'Invalid accepted terms name value'
            );

            System.assertEquals(
                    TEST_REVISION_NUMBER,
                    userInfoWrapper.acceptedTerms.get(0).revision,
                    'Invalid accepted terms revision value'
            );

            System.assertEquals(
                    TEST_STREET,
                    userInfoWrapper.address.street,
                    'Invalid street value'
            );

            System.assertEquals(
                    TEST_COUNTRY,
                    userInfoWrapper.address.country,
                    'Invalid street value'
            );

            System.assertEquals(
                    10,
                    userInfoWrapper.geolocation.latitude,
                    'Invalid latitude value'
            );
        }
        Test.stopTest();
    }

    @IsTest
    public static void shouldReturnCorrectIsEmailVerifiedValue_WhenGETCalledWithManualOverride() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        List<User> adminUsers = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);

        System.runAs(adminUsers.get(0)) {
            UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            portalUser.Is_User_Verified_Manual__c = true;
            update portalUser;
        }

        Contact contact = PS_TestHelper.getCreatedPortalContact(CLASS_NAME);
        contact.Global_Customer_Id__c = TEST_GLOBAL_CUSTOMER_ID;
        update contact;

        System.runAs(portalUser) {
            Test.startTest();
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
            RestContext.request = request;
            RestContext.response = new RestResponse();
            PS_WebServiceUserInfoHelper.testAppName = TEST_APP_NAME;
            PS_WebServiceUserInfoExtAdminWrapper userInfoWrapper = PS_RemoteAdminProfileWebServiceAPI.getUser();
            Test.stopTest();

            System.assertEquals(
                    true,
                    userInfoWrapper.isEmailVerified,
                    'Invalid Is Email Verified value'
            );
        }
    }

    @IsTest
    public static void shouldThrowException_WhenBothParametersPassed() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        Boolean exceptionThrow = false;

        Test.startTest();
        try {
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.EMAIL_PARAM, TEST_EMAIL);
            RestContext.request = request;
            PS_RemoteAdminProfileWebServiceAPI.getUser();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrow = e instanceof IllegalArgumentException;
        }

        System.assertEquals(
                true,
                exceptionThrow,
                'Exception should be thrown'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenNoUserFound() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        Boolean exceptionThrown = false;

        //then
        try {
            Test.startTest();
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
            RestContext.request = request;
            PS_RemoteAdminProfileWebServiceAPI.getUser();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = e instanceof PS_RemoteAdminProfileWebServiceAPI.NoDataFoundException;
        }

        System.assertEquals(
                true,
                exceptionThrown,
                'Exception should be thrown'
        );
    }

    @IsTest
    public static void shouldUpdateUserInformation_WhenPATCHCalledWithParam() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);

        System.runAs(users.get(0)) {
            ConnectedApplication connectedApplication =
                    UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            insert new BigCommerce_Connection__c(
                    Connected_App_Id__c = connectedApplication.Id
            );

            insert new UserProvAccount(
                    ConnectedAppId = connectedApplication.Id,
                    SalesforceUserId = portalUser.Id,
                    LinkState = 'linked',
                    Status = 'Active',
                    ExternalUserId = '12345'
            );

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

            AuthorizationFormConsent authorizationFormConsent = new AuthorizationFormConsent(
                    Name = 'testAuthFormConsent',
                    AuthorizationFormTextId = authorizationFormText.Id,
                    ConsentGiverId = portalUser.Id
            );
            insert authorizationFormConsent;
        }

        Contact contact = PS_TestHelper.getCreatedPortalContact(CLASS_NAME);
        contact.Global_Customer_Id__c = TEST_GLOBAL_CUSTOMER_ID;
        update contact;

        System.runAs(PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME)) {
            Test.startTest();
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);

            PS_WebServiceUserInfoWrapper userInfoWrapper = new PS_WebServiceUserInfoWrapper();
            userInfoWrapper.firstname = TEST_FIRST_NAME;
            userInfoWrapper.lastname = TEST_LAST_NAME;
            userInfoWrapper.email = TEST_EMAIL;
            userInfoWrapper.mobile = TEST_MOBILE;
            userInfoWrapper.language = TEST_LANGUAGE_KEY;
            userInfoWrapper.region = TEST_REGION;
            userInfoWrapper.isFrozen = true;

            PS_WebServiceUserInfoWrapper.Geolocation geolocation = new PS_WebServiceUserInfoWrapper.Geolocation();
            geolocation.latitude = 10;
            geolocation.longitude = 10;
            userInfoWrapper.geolocation = geolocation;

            PS_WebServiceUserInfoWrapper.Address address = new PS_WebServiceUserInfoWrapper.Address();
            address.street = TEST_STREET;
            address.city = TEST_CITY;
            address.state = TEST_STATE;
            address.zipCode = TEST_POSTAL_CODE;
            address.country = TEST_COUNTRY;
            userInfoWrapper.address = address;

            PS_WebServiceUserInfoWrapper.AcceptedTerms acceptedTerm = new PS_WebServiceUserInfoWrapper.AcceptedTerms();
            acceptedTerm.name = TEST_AUTH_FORM;
            acceptedTerm.revision = TEST_REVISION_NUMBER;
            acceptedTerm.language = TEST_LANGUAGE_KEY;
            PS_WebServiceUserInfoWrapper.AcceptedTerms acceptedTerm2 = new PS_WebServiceUserInfoWrapper.AcceptedTerms();
            acceptedTerm2.name = TEST_AUTH_FORM;
            acceptedTerm2.revision = TEST_REVISION_NUMBER + 1;
            acceptedTerm2.language = TEST_LANGUAGE_KEY;
            userInfoWrapper.acceptedTerms = new List<PS_WebServiceUserInfoWrapper.AcceptedTerms>{
                    acceptedTerm,
                    acceptedTerm2
            };

            request.requestBody = Blob.valueOf(JSON.serialize(userInfoWrapper));

            RestContext.request = request;
            RestContext.response = new RestResponse();

            PS_WebServiceUserInfoHelper.testAppName = TEST_APP_NAME;
            PS_RemoteAdminProfileWebServiceAPI.updateUser();
            Test.stopTest();
        }

        User updatedUser = [
                SELECT
                        Id,FirstName,LastName,MobilePhone,LanguageLocaleKey,ServerRegion__c,
                        Latitude,Longitude,AccountId
                FROM User
                WHERE Id = :portalUser.Id
                LIMIT 1
        ];

        System.assertNotEquals(
                null,
                updatedUser,
                'Invalid user value'
        );

        System.assertEquals(
                portalUser.Id,
                updatedUser.Id,
                'Invalid Id value'
        );

        System.assertEquals(
                TEST_FIRST_NAME,
                updatedUser.FirstName,
                'Invalid first name value'
        );

        System.assertEquals(
                TEST_LAST_NAME,
                updatedUser.LastName,
                'Invalid last name value'
        );

        System.assertEquals(
                TEST_MOBILE,
                updatedUser.MobilePhone,
                'Invalid mobile value'
        );

        System.assertEquals(
                TEST_LANGUAGE_KEY,
                updatedUser.LanguageLocaleKey,
                'Invalid language value'
        );

        System.assertEquals(
                TEST_REGION,
                updatedUser.ServerRegion__c,
                'Invalid Server region value'
        );

        System.assertEquals(
                10,
                updatedUser.Latitude,
                'Invalid latitude value'
        );

        System.assertEquals(
                true,
                [
                        SELECT IsFrozen
                        FROM UserLogin
                        WHERE UserId = :updatedUser.Id
                        ORDER BY LastModifiedDate DESC
                ].IsFrozen,
                'Invalid IsFrozen value'
        );

        List<AuthorizationFormConsent> insertedAuthFormConsents = [
                SELECT Id
                FROM AuthorizationFormConsent
                WHERE ConsentGiverId = :portalUser.Id
        ];

        System.assertEquals(
                2,
                insertedAuthFormConsents.size(),
                'Invalid number of accepted terms inserted'
        );

        Account userAccount = [
                SELECT Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry
                FROM Account
                WHERE Id = :updatedUser.AccountId
        ];

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
    }

    @IsTest
    public static void shouldThrowException_WhenBothParametersPassedPATCH() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        Boolean exceptionThrow = false;

        Test.startTest();
        try {
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.EMAIL_PARAM, TEST_EMAIL);
            request.requestBody = Blob.valueOf('{}');
            RestContext.request = request;
            PS_RemoteAdminProfileWebServiceAPI.updateUser();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrow = e instanceof IllegalArgumentException;
        }

        System.assertEquals(
                true,
                exceptionThrow,
                'Exception should be thrown'
        );
    }

    @IsTest
    public static void shouldThrowException_WhenNoReqParametersPassedPATCH() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        Boolean exceptionThrow = false;

        Test.startTest();
        try {
            RestRequest request = new RestRequest();
            request.requestBody = Blob.valueOf('{}');
            RestContext.request = request;
            PS_RemoteAdminProfileWebServiceAPI.updateUser();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrow = e instanceof IllegalArgumentException;
        }

        System.assertEquals(
                true,
                exceptionThrow,
                'Exception should be thrown'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenNoUserFoundPATCH() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        Boolean exceptionThrown = false;

        //then
        try {
            Test.startTest();
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.EMAIL_PARAM, 'invalid@email.com');
            request.requestBody = Blob.valueOf('{}');
            RestContext.request = request;
            PS_RemoteAdminProfileWebServiceAPI.updateUser();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = e instanceof PS_RemoteAdminProfileWebServiceAPI.NoDataFoundException;
        }

        System.assertEquals(
                true,
                exceptionThrown,
                'Exception should be thrown'
        );
    }

    @IsTest
    public static void shouldDeactivateUser_WhenDELETECalledWithParam() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        List<User> adminUsers = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);

        System.runAs(adminUsers.get(0)) {
            portalUser.Username = TEST_USERNAME;
            portalUser.Email = TEST_EMAIL;
            portalUser.IsPortalEnabled = true;
            update portalUser;
        }

        Contact contact = PS_TestHelper.getCreatedPortalContact(CLASS_NAME);
        contact.Global_Customer_Id__c = TEST_GLOBAL_CUSTOMER_ID;
        update contact;
		Test.startTest();
        System.runAs(PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME)) {

            
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
            RestContext.request = request;
            RestContext.response = new RestResponse();
            PS_WebServiceUserInfoHelper.testAppName = TEST_APP_NAME;
            PS_RemoteAdminProfileWebServiceAPI.deactivateUser();
            RestResponse response = RestContext.response;
            

            System.assertEquals(
                    204,
                    response.statusCode,
                    'Invalid status code value'
            );

            User deactivatedUser = [
                    SELECT Id,IsActive,Username,Email
                    FROM User
                    WHERE Id = :portalUser.Id
                    LIMIT 1
            ];

            System.assertEquals(
                    false,
                    deactivatedUser.IsActive,
                    'Invalid IsActive value'
            );

            System.assertNotEquals(
                    TEST_USERNAME,
                    deactivatedUser.Username,
                    'Invalid username value'
            );

            System.assertNotEquals(
                    TEST_EMAIL,
                    deactivatedUser.Email,
                    'Invalid email value'
            );
        }
        Test.stopTest();
    }

    @IsTest
    public static void shouldThrowException_WhenBothParametersPassedDELETE() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        Boolean exceptionThrow = false;

        Test.startTest();
        try {
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.EMAIL_PARAM, TEST_EMAIL);
            RestContext.request = request;
            PS_RemoteAdminProfileWebServiceAPI.deactivateUser();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrow = e instanceof IllegalArgumentException;
        }

        System.assertEquals(
                true,
                exceptionThrow,
                'Exception should be thrown'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenNoUserFoundDELETE() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        Boolean exceptionThrown = false;

        //then
        try {
            Test.startTest();
            RestRequest request = new RestRequest();
            request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
            RestContext.request = request;
            PS_RemoteAdminProfileWebServiceAPI.deactivateUser();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = e instanceof PS_RemoteAdminProfileWebServiceAPI.NoDataFoundException;
        }

        System.assertEquals(
                true,
                exceptionThrown,
                'Exception should be thrown'
        );
    }

//    @IsTest
//    public static void shouldThrowException_WhenTryingToFreezeUser() {
//        Boolean exceptionThrow = false;
//
//        Contact contact = PS_TestHelper.getCreatedPortalContact(CLASS_NAME);
//        contact.Global_Customer_Id__c = TEST_GLOBAL_CUSTOMER_ID;
//        update contact;
//
//        System.runAs(PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME)) {
//            Test.startTest();
//            try {
//                RestRequest request = new RestRequest();
//                request.params.put(PS_RemoteAdminProfileWebServiceAPI.GLOBAL_ID_PARAM, TEST_GLOBAL_CUSTOMER_ID);
//
//                PS_WebServiceUserInfoWrapper userInfoWrapper = new PS_WebServiceUserInfoWrapper();
//                userInfoWrapper.isFrozen = true;
//
//                request.requestBody = Blob.valueOf(JSON.serialize(userInfoWrapper));
//                RestContext.request = request;
//
//                Test.setMock(HttpCalloutMock.class, new PS_RemoteAdminProfileTestMockGenerator(true));
//                PS_RemoteAdminProfileWebServiceAPI.updateUser();
//                Test.stopTest();
//            } catch (Exception e) {
//                exceptionThrow = e instanceof PS_WebServiceUserInfoHelper.NoDataFoundException;
//            }
//
//            System.assertEquals(
//                    true,
//                    exceptionThrow,
//                    'Exception should be thrown'
//            );
//        }
//    }
}
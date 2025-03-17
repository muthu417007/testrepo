@IsTest
public with sharing class PS_UserProfileWebServiceAPITest {

    private static final String CLASS_NAME = PS_UserProfileWebServiceAPITest.class
            .getName()
            .substring(0, 15);
    private static final String TEST_APP_NAME = 'TestApp';
    private static final String TEST_FIRST_NAME = 'TestFirstName';
    private static final String TEST_LAST_NAME = 'TestLastName';
    private static final String TEST_AUTH_FORM = 'TestAuthForm';
    private static final String TEST_MOBILE = '1234567890';	//CHG0111002 -CHANGED MOBILE NUMBER TO 10 DIGITS TO FIX DEPLOYMENT ERROR
    private static final String TEST_EMAIL = System.now().millisecond() +
            Math.rint(Math.random() * 1000) + 'newemail@test4431.com';
    private static final String TEST_LANGUAGE_KEY = 'en_US';
    private static final String TEST_THIRD_PARTY_ID = '123456';
    private static final String TEST_REVISION_NUMBER = '987654';

    @TestSetup
    public static void createData() {
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
    }

    @IsTest
    public static void shouldReturnBasicUserInformation_WhenGETCalledWithNoParams() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        //given
        List<User> adminUsers = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);

        Connected_Application_Reference__mdt connectedAppConfig;

        System.runAs(adminUsers.get(0)) {
            ConnectedApplication connectedApplication =
                    UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            connectedAppConfig = new Connected_Application_Reference__mdt(
                    Connected_App_Id__c = connectedApplication.Id
            );

            UserProvAccount userProvAccount = new UserProvAccount();
            userProvAccount.ConnectedAppId = connectedApplication.Id;
            userProvAccount.LinkState = 'linked';
            userProvAccount.Status = 'Active';
            userProvAccount.SalesforceUserId = portalUser.Id;
            userProvAccount.ExternalUserId = TEST_THIRD_PARTY_ID;
            insert userProvAccount;

            update new User(
                    Id = portalUser.Id,
                    FirstName = TEST_FIRST_NAME,
                    LastName = TEST_LAST_NAME,
                    MobilePhone = TEST_MOBILE,
                    LanguageLocaleKey = TEST_LANGUAGE_KEY
            );

            update new Contact(
                    Id = portalUser.ContactId,
                    Global_Customer_Id__c = TEST_THIRD_PARTY_ID
            );
        }

        AuthorizationForm authorizationForm = new AuthorizationForm(
                Name = TEST_AUTH_FORM,
                RevisionNumber = TEST_REVISION_NUMBER
        );
        insert authorizationForm;

        AuthorizationFormText authorizationFormText = new AuthorizationFormText(
                Name = 'testAuthFormText',
                Locale = TEST_LANGUAGE_KEY,
                AuthorizationFormId = authorizationForm.Id
        );
        insert authorizationFormText;

        AuthorizationFormConsent authorizationFormConsent = new AuthorizationFormConsent(
                Name = 'testAuthFormConsent',
                AuthorizationFormTextId = authorizationFormText.Id,
                ConsentGiverId = portalUser.Id,
                ConsentCapturedDateTime = System.now()
        );
        insert authorizationFormConsent;

        System.runAs(portalUser) {
            Test.startTest();
            RestContext.request = new RestRequest();
            RestContext.response = new RestResponse();
            PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
            PS_WebServiceUserInfoHelper.testAppName = TEST_APP_NAME;
            PS_WebServiceUserInfoExtWrapper userInfoWrapper = PS_UserProfileWebServiceAPI.getUser();
            Test.stopTest();

            System.assertNotEquals(
                    null,
                    userInfoWrapper,
                    'Invalid userInfoWrapper returned'
            );

            System.assertEquals(
                    System.UserInfo.getUserId(),
                    userInfoWrapper.salesforceUserId,
                    'Invalid first name value'
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

            System.assertEquals(
                    TEST_THIRD_PARTY_ID,
                    userInfoWrapper.thirdPartyUserId,
                    'Invalid third Party UserId value'
            );

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
                    TEST_LANGUAGE_KEY,
                    userInfoWrapper.acceptedTerms.get(0).language,
                    'Invalid accepted terms language value'
            );
        }
    }

    @IsTest
    public static void shouldUpdateUserInfo_WhenUserPATCHCalled() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        
        List<User> portalUsers = PS_TestHelper.getCreatedPortalUser(CLASS_NAME);
        User portalUser = portalUsers.get(0);
        System.runAs(portalUser) {

            Test.startTest();
            RestRequest request = new RestRequest();
            PS_WebServiceUserInfoWrapper wrapper = new PS_WebServiceUserInfoWrapper();
            wrapper.firstname = TEST_FIRST_NAME;
            wrapper.lastname = TEST_LAST_NAME;
            wrapper.email = TEST_EMAIL;
            wrapper.mobile = TEST_MOBILE;
            wrapper.language = TEST_LANGUAGE_KEY;
            request.requestBody = Blob.valueOf(JSON.serialize(wrapper));
            RestContext.request = request;
            RestContext.response = new RestResponse();
            PS_UserProfileWebServiceAPI.updateUser();
            RestResponse restResponse = RestContext.response;
            Test.stopTest();

            User updatedUser = [
                    SELECT Id,FirstName,LastName,Email,Username,LanguageLocaleKey,MobilePhone
                    FROM User
                    WHERE Id = :portalUser.Id
                    LIMIT 1
            ];

            System.assertEquals(
                    204,
                    restResponse.statusCode,
                    'Invalid status code value'
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
                    TEST_EMAIL,
                    updatedUser.Email,
                    'Invalid email value'
            );

            System.assertEquals(
                    TEST_MOBILE,
                    updatedUser.MobilePhone,
                    'Invalid mobile phone value'
            );

            System.assertEquals(
                    TEST_LANGUAGE_KEY,
                    updatedUser.LanguageLocaleKey,
                    'Invalid language key value'
            );
        }
    }
}
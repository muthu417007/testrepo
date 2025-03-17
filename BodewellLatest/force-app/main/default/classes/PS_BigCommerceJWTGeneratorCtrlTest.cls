@IsTest
public with sharing class PS_BigCommerceJWTGeneratorCtrlTest {

    private static final String AUTHORIZATION_CODE = 'AUTHORIZATION_CODE';
    private static final String RET_URL = 'https://return.url.com/test';
    private static final String RET_URL_DOMAIN = 'https://return.url.com';
    private static final String LOGOUT_URL = 'https://logout.url.com/logout';
    private static final String TEST_APP_NAME = 'TestApp';
    private static final String CLIENT_ID = 'bry7v12hobgfka9ih70jpkqo218p8hq';
    private static final String CLIENT_SECRET = '78d5d7534caa02a64b7c929001f0c03631fabac71364452ba0c9707c192db3d8';
    private static final String AUTH_TOKEN = 'pc9ico6zzawnat9r4nq2iflaqipllko';
    private static final String STORE_HASH = 'awav9ocqu';

    @IsTest
    public static void shouldRedirectToLoginWithToken_WhenUserIdDoesMatch() {
        //given
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        ConnectedApplication connectedApplication;
        System.runAs(users.get(0)) {
            connectedApplication =
                    UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            UserProvAccount userProvAccount = new UserProvAccount();
            userProvAccount.ConnectedAppId = connectedApplication.Id;
            userProvAccount.LinkState = 'linked';
            userProvAccount.Status = 'Active';
            userProvAccount.SalesforceUserId = System.UserInfo.getUserId();
            userProvAccount.ExternalUserId = '12345';
            insert userProvAccount;
        }

        PageReference pageReference = Page.PS_BigCommerceJWTGenerator;
        Test.setCurrentPage(pageReference);

        PS_OAuthStateWrapper state = new PS_OAuthStateWrapper(RET_URL, 'originalState');
        System.currentPageReference().getParameters().put('code', AUTHORIZATION_CODE);
        System.currentPageReference().getParameters().put(
                'state',
                EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state)))
        );

        BigCommerce_Connection__c bigCommerceConnection = new BigCommerce_Connection__c();
        bigCommerceConnection.Domain__c = RET_URL_DOMAIN;
        bigCommerceConnection.Connected_App_Name__c = TEST_APP_NAME;
        bigCommerceConnection.Connected_App_Id__c = connectedApplication.Id;
        bigCommerceConnection.Client_Id__c = CLIENT_ID;
        bigCommerceConnection.Client_Secret__c = CLIENT_SECRET;
        bigCommerceConnection.Auth_Token__c = AUTH_TOKEN;
        bigCommerceConnection.Store_Hash__c = STORE_HASH;
        bigCommerceConnection.Preview_Key__c = 'testPreviewKey';
        insert bigCommerceConnection;

        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                UserInfo.getUserName().substringAfterLast('.') :
                null;

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Environment_Name__c = envName,
                Connected_App_Id__c = connectedApplication.Id,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        PS_OAuthAccessTokenWrapper responseData = new PS_OAuthAccessTokenWrapper();
        responseData.access_token = 'testAccessToken';
        responseData.id = System.UserInfo.getUserId();

        PS_BigCommerceUserManagementService.CustomerAPIResponseWrapper bigCommercePOSTResponseData =
                new PS_BigCommerceUserManagementService.CustomerAPIResponseWrapper();
        PS_BigCommerceUserManagementService.Data dataObj = new PS_BigCommerceUserManagementService.Data();
        dataObj.id = '12345';
        bigCommercePOSTResponseData.data = new List<PS_BigCommerceUserManagementService.Data>{
                dataObj
        };

        //then
        Test.startTest();
        Test.setMock(
                HttpCalloutMock.class,
                new PS_JWTServiceMockGenerator(
                        responseData,
                        null,
                        bigCommercePOSTResponseData
                )
        );
        PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
        PS_BigCommerceJWTGeneratorCtrl commerceJWTGeneratorCtrl = new PS_BigCommerceJWTGeneratorCtrl();
        PageReference redirectionPage = commerceJWTGeneratorCtrl.redirect();
        Test.stopTest();

        System.assertNotEquals(
                null,
                redirectionPage,
                'Invalid redirection page returned'
        );

        System.assert(
                redirectionPage.getUrl().contains(RET_URL_DOMAIN + '/login/token'),
                'Invalid redirection url'
        );
    }

    @IsTest
    public static void shouldRedirectToLogout_WhenUserIdDoesNotMatch() {
        //given
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        ConnectedApplication connectedApplication;
        System.runAs(users.get(0)) {
            connectedApplication =
                    UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            UserProvAccount userProvAccount = new UserProvAccount();
            userProvAccount.ConnectedAppId = connectedApplication.Id;
            userProvAccount.LinkState = 'linked';
            userProvAccount.Status = 'Active';
            userProvAccount.SalesforceUserId = System.UserInfo.getUserId();
            userProvAccount.ExternalUserId = '12345';
            insert userProvAccount;
        }

        PageReference pageReference = new PageReference(Page.PS_BigCommerceJWTGenerator + '/test');
        Test.setCurrentPage(pageReference);
        PS_OAuthStateWrapper state = new PS_OAuthStateWrapper(RET_URL, 'originalState');
        System.currentPageReference().getParameters().put('code', AUTHORIZATION_CODE);
        System.currentPageReference().getParameters().put(
                'state',
                EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state)))
        );

        BigCommerce_Connection__c bigCommerceConnection = new BigCommerce_Connection__c();
        bigCommerceConnection.Domain__c = RET_URL_DOMAIN;
        bigCommerceConnection.Connected_App_Name__c = TEST_APP_NAME;
        bigCommerceConnection.Connected_App_Id__c = connectedApplication.Id;
        bigCommerceConnection.Client_Id__c = CLIENT_ID;
        bigCommerceConnection.Client_Secret__c = CLIENT_SECRET;
        bigCommerceConnection.Auth_Token__c = AUTH_TOKEN;
        bigCommerceConnection.Store_Hash__c = STORE_HASH;
        insert bigCommerceConnection;

        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                UserInfo.getUserName().substringAfterLast('.') :
                null;

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Environment_Name__c = envName,
                Connected_App_Id__c = connectedApplication.Id,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        PS_OAuthAccessTokenWrapper responseData = new PS_OAuthAccessTokenWrapper();
        responseData.access_token = 'testAccessToken';
        responseData.id = 'notMatchingId';

        Customer_IdP_Configuration__mdt customerIdPConfiguration = new Customer_IdP_Configuration__mdt(
                Logout_Url__c = LOGOUT_URL
        );

        //then
        Test.startTest();
        Test.setMock(
                HttpCalloutMock.class,
                new PS_JWTServiceMockGenerator(
                        responseData,
                        null,
                        null
                )
        );
        PS_GEAIdPCustomerConfigHelper.customerIdPConfiguration = customerIdPConfiguration;
        PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
        PS_BigCommerceJWTGeneratorCtrl commerceJWTGeneratorCtrl = new PS_BigCommerceJWTGeneratorCtrl();
        PageReference redirectionPage = commerceJWTGeneratorCtrl.redirect();
        Test.stopTest();

        System.assertNotEquals(
                null,
                redirectionPage,
                'Invalid redirection page returned'
        );

        System.assertEquals(
                LOGOUT_URL,
                redirectionPage.getUrl(),
                'Invalid logout url value'
        );
    }

    @IsTest
    public static void shouldRedirectToDefaultLogout_WhenCustomNotProvided() {
        //given
        List<User> users = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        ConnectedApplication connectedApplication;
        System.runAs(users.get(0)) {
            connectedApplication =
                    UserProvisioning.ConnectorTestUtil.createConnectedApp(TEST_APP_NAME);

            UserProvAccount userProvAccount = new UserProvAccount();
            userProvAccount.ConnectedAppId = connectedApplication.Id;
            userProvAccount.LinkState = 'linked';
            userProvAccount.Status = 'Active';
            userProvAccount.SalesforceUserId = System.UserInfo.getUserId();
            userProvAccount.ExternalUserId = '12345';
            insert userProvAccount;
        }

        PageReference pageReference = new PageReference(Page.PS_BigCommerceJWTGenerator + '/test');
        Test.setCurrentPage(pageReference);
        PS_OAuthStateWrapper state = new PS_OAuthStateWrapper(RET_URL, 'originalState');
        System.currentPageReference().getParameters().put('code', AUTHORIZATION_CODE);
        System.currentPageReference().getParameters().put(
                'state',
                EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state)))
        );

        BigCommerce_Connection__c bigCommerceConnection = new BigCommerce_Connection__c();
        bigCommerceConnection.Domain__c = RET_URL_DOMAIN;
        bigCommerceConnection.Connected_App_Name__c = TEST_APP_NAME;
        bigCommerceConnection.Connected_App_Id__c = connectedApplication.Id;
        bigCommerceConnection.Client_Id__c = CLIENT_ID;
        bigCommerceConnection.Client_Secret__c = CLIENT_SECRET;
        bigCommerceConnection.Auth_Token__c = AUTH_TOKEN;
        bigCommerceConnection.Store_Hash__c = STORE_HASH;
        insert bigCommerceConnection;

        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                UserInfo.getUserName().substringAfterLast('.') :
                null;

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Environment_Name__c = envName,
                Connected_App_Id__c = connectedApplication.Id,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        PS_OAuthAccessTokenWrapper responseData = new PS_OAuthAccessTokenWrapper();
        responseData.access_token = 'testAccessToken';
        responseData.id = 'notMatchingId';


        //then
        Test.startTest();
        Test.setMock(
                HttpCalloutMock.class,
                new PS_JWTServiceMockGenerator(
                        responseData,
                        null,
                        null
                )
        );

        PS_GEAIdPCustomerConfigHelper.testSiteName = 'Default';
        PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
        PS_BigCommerceJWTGeneratorCtrl commerceJWTGeneratorCtrl = new PS_BigCommerceJWTGeneratorCtrl();
        PageReference redirectionPage = commerceJWTGeneratorCtrl.redirect();
        Test.stopTest();

        System.assertNotEquals(
                null,
                redirectionPage,
                'Invalid redirection page returned'
        );

        System.assertEquals(
                '/secur/logout.jsp',
                redirectionPage.getUrl(),
                'Invalid logout url value'
        );
    }

    @IsTest
    public static void shouldRedirectToLogout_WhenUserIdForBigCommerceAPIDoesMatch() {
        PageReference pageReference = Page.PS_BigCommerceJWTGenerator;
        Test.setCurrentPage(pageReference);

        PS_OAuthStateWrapper state = new PS_OAuthStateWrapper(RET_URL, 'originalState');
        System.currentPageReference().getParameters().put('code', AUTHORIZATION_CODE);
        System.currentPageReference().getParameters().put(
                'state',
                EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(state)))
        );

        BigCommerce_Connection__c bigCommerceConnection = new BigCommerce_Connection__c();
        bigCommerceConnection.Domain__c = RET_URL_DOMAIN;
        bigCommerceConnection.Connected_App_Name__c = TEST_APP_NAME;
        bigCommerceConnection.Client_Id__c = CLIENT_ID;
        bigCommerceConnection.Client_Secret__c = CLIENT_SECRET;
        bigCommerceConnection.API_Base_Url__c = 'https://baseUrl.com';
        bigCommerceConnection.Auth_Token__c = AUTH_TOKEN;
        bigCommerceConnection.Store_Hash__c = STORE_HASH;
        insert bigCommerceConnection;

        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                UserInfo.getUserName().substringAfterLast('.') :
                null;

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = RET_URL_DOMAIN,
                Environment_Name__c = envName,
                Redirect_URI__c = 'https://redirectURI.com/return'
        );

        PS_OAuthAccessTokenWrapper OAuthResponseData = new PS_OAuthAccessTokenWrapper();
        OAuthResponseData.access_token = 'testAccessToken';
        OAuthResponseData.id = System.UserInfo.getUserId();

        PS_BigCommerceUserManagementService.CustomerAPIResponseWrapper bigCommercePOSTResponseData =
                new PS_BigCommerceUserManagementService.CustomerAPIResponseWrapper();
        PS_BigCommerceUserManagementService.Data dataObj = new PS_BigCommerceUserManagementService.Data();
        dataObj.id = '12345';
        bigCommercePOSTResponseData.data = new List<PS_BigCommerceUserManagementService.Data>{
                dataObj
        };

        //then
        Test.startTest();
        Test.setMock(
                HttpCalloutMock.class,
                new PS_JWTServiceMockGenerator(OAuthResponseData, null, bigCommercePOSTResponseData)
        );
        PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
        PS_BigCommerceJWTGeneratorCtrl commerceJWTGeneratorCtrl = new PS_BigCommerceJWTGeneratorCtrl();
        PageReference redirectionPage = commerceJWTGeneratorCtrl.redirect();
        Test.stopTest();

        System.assertNotEquals(
                null,
                redirectionPage,
                'Invalid redirection page returned'
        );

        System.assert(
                redirectionPage.getUrl().contains(RET_URL_DOMAIN + '/login/token'),
                'Invalid redirection url'
        );
    }
}
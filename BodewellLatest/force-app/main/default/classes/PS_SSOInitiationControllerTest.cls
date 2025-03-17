@IsTest
public with sharing class PS_SSOInitiationControllerTest {

    private static final String REDIRECT_URL = 'https://return.url.com/test';
    private static final String UTF_8 = 'UTF-8';

    @IsTest
    public static void shouldRedirectToLoginPage_WhenGuestUser() {

        PageReference pageReference = Page.CustomerSSO;
        Test.setCurrentPage(pageReference);

        System.currentPageReference().getParameters().put('redirectURL', EncodingUtil.urlEncode(REDIRECT_URL, UTF_8));
        System.currentPageReference().getParameters().put('language', 'en');
        System.currentPageReference().getParameters().put('allowGuest', '1');

        Test.startTest();
        PS_SSOService.userType = 'Guest';
        PS_SSOInitiationController pageCtrl = new PS_SSOInitiationController();
        PageReference redirectionPage = pageCtrl.SSOInitialRedirection();
        Test.stopTest();

        System.assertEquals(
                '1',
                System.currentPageReference().getCookies().get('allowGuest').getValue(),
                'Invalid allowGuest cookie value'
        );

        System.assertNotEquals(
                null,
                redirectionPage,
                'Invalid redirection page returned'
        );

        System.assertEquals(
                '/login',
                new Url(redirectionPage.getUrl()).getPath(),
                'Invalid redirection url path'
        );

        System.assertEquals(
                EncodingUtil.urlEncode(REDIRECT_URL, UTF_8),
                System.currentPageReference().getCookies().get('redirectURL').getValue(),
                'Invalid redirectionURL value'
        );

        System.assertEquals(
                'en',
                redirectionPage.getParameters().get('language'),
                'Invalid language value'
        );
    }

    @IsTest
    public static void shouldRedirectToOAuthFlowPage_WhenLoggedInUser() {
        //given
        PageReference pageReference = Page.CustomerSSO;
        Test.setCurrentPage(pageReference);

        System.currentPageReference().getParameters().put('redirectURL', EncodingUtil.urlEncode(REDIRECT_URL, UTF_8));
        System.currentPageReference().getParameters().put('language', 'en');

        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                Url.getOrgDomainUrl().getHost().split('--').get(1).split('\\.').get(0) :
                null;

        Connected_Application_Reference__mdt connectedAppConfig = new Connected_Application_Reference__mdt(
                Domain__c = 'https://return.url.com',
                Environment_Name__c = envName,
                Auth_Flow__c = 'Implicit_Grant',
                Is_Internally_Managed__c = true
        );

        //then
        Test.startTest();
        PS_ConnectedAppReferenceHelper.connectedAppConfig = connectedAppConfig;
        PS_SSOInitiationController pageCtrl = new PS_SSOInitiationController();
        PageReference redirectionPage = pageCtrl.SSOInitialRedirection();
        Test.stopTest();

        System.assertNotEquals(
                null,
                redirectionPage,
                'Invalid redirection page returned'
        );

        System.assert(
                redirectionPage.getUrl().containsIgnoreCase('/services/oauth2/authorize'),
                'Invalid redirection url path'
        );

        System.assertEquals(
                'token',
                redirectionPage.getParameters().get('response_type'),
                'Invalid response token value'
        );

        System.assert(
                EncodingUtil.base64Decode(
                        redirectionPage.getParameters().get('state')
                ).toString().contains('{"retURL":"' + REDIRECT_URL)
        );
    }

    @IsTest
    public static void shouldThrowException_WhenAppConfigNotFound() {
        //given
        PageReference pageReference = Page.CustomerSSO;
        Test.setCurrentPage(pageReference);

        System.currentPageReference().getParameters().put('redirectURL', 'https://return.invalid.com/test');

        Customer_IdP_Environment_Config__mdt customerEnvConfig=
                new Customer_IdP_Environment_Config__mdt(
                        Default_Redirect_App__c = '0H400000000000ICAU'
                );

        Boolean exceptionThrown = false;
        //then
        try {
            Test.startTest();
            PS_ConnectedAppReferenceHelper.customerEnvConfig = customerEnvConfig;
            PS_SSOInitiationController pageCtrl = new PS_SSOInitiationController();
            pageCtrl.SSOInitialRedirection();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = e instanceof PS_SSOService.NoConfigRecordFoundException;
        }

        System.assertEquals(
                true,
                exceptionThrown,
                'Exception should be thrown'
        );
    }
}
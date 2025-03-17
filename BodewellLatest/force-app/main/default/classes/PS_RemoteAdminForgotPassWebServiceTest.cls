@IsTest
public with sharing class PS_RemoteAdminForgotPassWebServiceTest {

    private static final String CLASS_NAME = PS_RemoteAdminForgotPassWebServiceTest.class
            .getName()
            .substring(0, 15);

    @TestSetup
    public static void createData() {
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
    }

    @IsTest
    public static void shouldSendForgotPasswordNotification_WhenUserFound() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new PS_RemoteAdminForgotPassMock());
        RestContext.response = new RestResponse();
        PS_RemoteAdminForgotPasswordWebService.sendVerificationEmailPOST(
                portalUser.Email,
                null,
                'https://redirect.com/test'
        );
        RestResponse restResponse = RestContext.response;
        Test.stopTest();

        System.assertEquals(
                204,
                restResponse.statusCode,
                'Invalid status code returned'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenNoUserFound() {
        //given
        Boolean exceptionThrown = false;

        //then
        try {
            Test.startTest();
            PS_RemoteAdminForgotPasswordWebService.sendVerificationEmailPOST(
                    'test@email.invalid',
                    null,
                    'https://redirect.com/test'
            );
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = e instanceof PS_ForgotPasswordService.NoDataFoundException;
        }

        System.assertEquals(
                true,
                exceptionThrown,
                'Exception should be thrown'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenMissingRequiredParam() {
        //given
        Boolean exceptionThrown = false;

        //then
        try {
            Test.startTest();
            PS_RemoteAdminForgotPasswordWebService.sendVerificationEmailPOST(
                    null,
                    null,
                    'https://redirect.com/test'
            );
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

    private class PS_RemoteAdminForgotPassMock implements HttpCalloutMock {
        private PS_RemoteAdminForgotPassMock() {
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('success');
            return response;
        }
    }
}
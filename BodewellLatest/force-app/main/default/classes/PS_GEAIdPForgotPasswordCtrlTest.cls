@IsTest
public with sharing class PS_GEAIdPForgotPasswordCtrlTest {

    private static final String CLASS_NAME = PS_GEAIdPForgotPasswordCtrlTest.class
            .getName()
            .substring(0, 15);

    @TestSetup
    public static void createData() {
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
    }

    @IsTest
    public static void shouldSendForgotPasswordEmail_WhenUserFound() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        Boolean exceptionThrown = false;

        //then
        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PS_GEAIdPForgotPassMock(true));
            RestContext.response = new RestResponse();
            PS_GEAIdPForgotPasswordCtrl.sendForgotEmail(
                    portalUser.Email
            );
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = true;
        }

        System.assertEquals(
                false,
                exceptionThrown,
                'No exception should be thrown'
        );
    }

    @IsTest
    public static void shouldThrowGeneralError_WhenCalloutFailed() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        Boolean exceptionThrown = false;

        //then
        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PS_GEAIdPForgotPassMock(false));
            PS_GEAIdPForgotPasswordCtrl.sendForgotEmail(
                    portalUser.Email
            );
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = e instanceof AuraHandledException;
        }

        System.assertEquals(
                true,
                exceptionThrown,
                'Exception should be thrown'
        );
    }

    private class PS_GEAIdPForgotPassMock implements HttpCalloutMock {
        private Boolean isSuccess;
        private PS_GEAIdPForgotPassMock(Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (this.isSuccess) {
                response.setStatusCode(200);
                response.setStatus('success');
            } else {
                response.setStatusCode(500);
                response.setStatus('failure');
            }
            return response;
        }
    }
}
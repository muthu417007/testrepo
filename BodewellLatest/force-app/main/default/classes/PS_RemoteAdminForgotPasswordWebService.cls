@RestResource(UrlMapping='/customer-idm/remote-administration/v1/forgot-password')
global with sharing class PS_RemoteAdminForgotPasswordWebService {

    private static final String EMAIL_PARAM = 'email';

    @HttpPost
    global static void sendVerificationEmailPOST(
            String email,
            String state,
            String redirectURL
    ) {
        if (String.isBlank(email)) {
            throw new IllegalArgumentException('Missing required parameter. [' + EMAIL_PARAM + ']');
        }

        new PS_ForgotPasswordService(email,state,redirectURL).sendForgotEmail();

        RestContext.response.statusCode = 204;
    }
}
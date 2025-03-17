@RestResource(UrlMapping='/customer-idm/user/v1/send-verification-email')
global with sharing class PS_UserSendVerificationWebServiceApi {

    @HttpPost
    global static void sendVerificationEmailPOST() {
        RestRequest request = RestContext.request;
        String experienceName = System.Site.getPathPrefix().replace('/', '');

        PS_SendVerificationWebServiceHelper.sendEmailVerification(
                System.UserInfo.getUserId(),
                request.requestBody,
                experienceName,
                null
        );

        RestContext.response.statusCode = 204;
    }
}
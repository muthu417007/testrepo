@RestResource(UrlMapping='/customer-idm/remote-administration/v1/send-verification-email/*')
global with sharing class PS_RemoteAdminSendVerificationWebService {

    @HttpPost
    global static void sendVerificationEmailPOST() {
        RestRequest request = RestContext.request;

        List<String> paramsSplit = request.requestURI.split('/');
        String globalId = paramsSplit.get(paramsSplit.size() - 1);
        String experienceName = System.Site.getPathPrefix().replace('/', '');

        if (String.isBlank(globalId)) {
            throw new IllegalArgumentException('Missing required path parameter. [globalId]');
        }

        List<User> users = PS_WebServiceUserInfoHelper.getUsersByContactGlobalId(globalId);
        if (users.isEmpty()) {
            throw new NoDataFoundException('User not found.');
        }

        PS_SendVerificationWebServiceHelper.sendEmailVerification(
                users.get(0).Id,
                request.requestBody,
                experienceName,
                null
        );

        RestContext.response.statusCode = 204;
    }

    @TestVisible
    private class NoDataFoundException extends Exception {
    }
}
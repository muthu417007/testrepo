public with sharing class PS_ForgotPasswordService {

    private static final String POST_METHOD = 'POST';
    private static final String CONTENT_TYPE = 'Content-type';
    private static final String APP_X_WWW_URLENCODED = 'application/x-www-form-urlencoded';
    private static final String SECUR_FORGOT_PASSWORD = '/secur/forgotpassword.jsp';
    private static final String LOCALE = 'locale';
    private static final String UN = 'un';
    private static final String START_URL = 'startURL';

    private String email;
    private String state;
    private String redirectURL;

    public PS_ForgotPasswordService(
            String email,
            String state,
            String redirectURL
    ) {
        this.email = email;
        this.state = state;
        this.redirectURL = redirectURL;
    }

    public HttpResponse sendForgotEmail() {
        List<User> users = PS_WebServiceUserInfoHelper.getUsersByEmail(email);
        if (users.isEmpty()) {
            throw new NoDataFoundException('User not found.');
        }
        User currentUser = users.get(0);
        system.debug('currentUser'+currentUser);
        String baseUrl = System.Site.getBaseUrl();
        system.debug('baseUrl'+baseUrl);

        String body = '';
        body += LOCALE + '=' + EncodingUtil.urlEncode(currentUser.LanguageLocaleKey.left(2), 'UTF-8') + '&';
        body += UN + '=' + EncodingUtil.urlEncode(currentUser.Username, 'UTF-8') + '&';
        if (String.isBlank(redirectURL)) {
            body += START_URL + '=/';
        } else {
            PageReference ssoInitPage = new PageReference(Page.CustomerSSO.getUrl());
            ssoInitPage.getParameters().put('redirectURL', redirectURL);
            ssoInitPage.getParameters().put('state', state);
            body += START_URL + '=' + EncodingUtil.urlEncode(ssoInitPage.getUrl(), 'UTF-8');
        }

        HttpRequest request = new HttpRequest();
        request.setBody(body);
        request.setEndpoint(baseUrl + SECUR_FORGOT_PASSWORD);
        request.setMethod(POST_METHOD);
        request.setHeader(CONTENT_TYPE, APP_X_WWW_URLENCODED);

        Http http = new Http();
        return http.send(request);
    }

    @TestVisible
    private class NoDataFoundException extends Exception {
    }
}
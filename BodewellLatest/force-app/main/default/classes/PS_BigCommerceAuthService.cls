public with sharing class PS_BigCommerceAuthService {

    private static final String UTF_8 = 'UTF-8';
    private static final String OPERATION_CUSTOMER_LOGIN = 'customer_login';
    private static final String POST_METHOD = 'POST';
    private static final String OAUTH2_TOKEN_ENDPOINT = '/services/oauth2/token';
    private static final String CONTENT_TYPE = 'Content-type';
    private static final String APP_X_WWW_URLENCODED = 'application/x-www-form-urlencoded';
    private static final String GRANT_TYPE = 'grant_type';
    private static final String AUTHORIZATION_CODE = 'authorization_code';
    private static final String CODE_PARAM = 'code';
    private static final String CLIENT_ID = 'client_id';
    private static final String REDIRECT_URI = 'redirect_uri';
    private static final String REDIRECT_TO = 'redirect_to';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String LINK_STATE_LINKED = 'linked';
    private static final String JTI = 'jti';
    private static final String OPERATION = 'operation';
    private static final String STORE_HASH = 'store_hash';
    private static final String CUSTOMER_ID = 'customer_id';
    private static final String GUEST_TOKEN = 'guestTkn';

    private String code;
    private String state;
    private String stateOriginal;
    private String retURL;
    public String retUrlDomain;
    private String baseURL;

    public PS_BigCommerceAuthService(String code, String state) {
        this.code = code;
        this.state = EncodingUtil.base64Decode(state).toString();
        this.baseURL = System.Site.getBaseUrl();

        PS_OAuthStateWrapper stateWrapper =
                (PS_OAuthStateWrapper) JSON.deserialize(this.state, PS_OAuthStateWrapper.class);
        this.retURL = stateWrapper.retURL;
        this.stateOriginal = stateWrapper.originalState;
        Url returnUrl = new Url(this.retURL);
        this.retUrlDomain = returnUrl.getProtocol() + '://' + returnUrl.getHost();

        System.debug(code);
        System.debug(this.state);
        System.debug(baseURL);
        System.debug(retURL);
        System.debug(retUrlDomain);
    }

    public PageReference redirect() {
        BigCommerce_Connection__c bigCommerceConnection =
                PS_BigCommerceConnectionConfigHelper.getBigCommerceConnectionConfig(this.retUrlDomain);
        System.debug(bigCommerceConnection);

        PS_BigCommerceUserManagementService bigCommerceService =
                new PS_BigCommerceUserManagementService(
                        bigCommerceConnection,
                        System.UserInfo.getUserEmail()
                );

        String userExternalId = getUserExternalId(
                bigCommerceConnection,
                bigCommerceService
        );
        System.debug(userExternalId);

        PS_OAuthAccessTokenWrapper psoAuthAccessTokenWrapper = makeCalloutToOAuthToken();

        bigCommerceService.insertUserProvAccountRecord(bigCommerceConnection.Connected_App_Id__c);

        List<String> idSplit = psoAuthAccessTokenWrapper.id.split('/');
        String oAuthUserId = idSplit.get(idSplit.size() - 1);
        if (oAuthUserId != System.UserInfo.getUserId()) {
            return redirectToLogout();
        }

        return redirectToLoginWithToken(
                psoAuthAccessTokenWrapper,
                userExternalId,
                bigCommerceConnection
        );
    }

    public PageReference redirectToLoginWithToken(
            PS_OAuthAccessTokenWrapper accessTokenWrapper,
            String userExternalId,
            BigCommerce_Connection__c bigCommerceConnection
    ) {
        String token = getJWTToken(
                accessTokenWrapper,
                userExternalId,
                bigCommerceConnection
        );

        String url = this.retUrlDomain + '/login/token/' + token;
        PageReference loginWithTokenPage = new PageReference(url);
        if (String.isNotBlank(bigCommerceConnection.Preview_Key__c)) {
            loginWithTokenPage.getParameters().put(GUEST_TOKEN, bigCommerceConnection.Preview_Key__c);
        }
        System.debug(loginWithTokenPage.getUrl());

        return loginWithTokenPage;
    }

    private String getJWTToken(
            PS_OAuthAccessTokenWrapper accessTokenWrapper,
            String userExternalId,
            BigCommerce_Connection__c bigCommerceConnection
    ) {
        JWT jwt = new JWT(JWT.HS256);
        jwt.includeTypHeader = true;
        jwt.decodeSecret = false;
        jwt.validFor = 30;
        jwt.iss = bigCommerceConnection.Client_Id__c;
        jwt.aud = '';
        jwt.sub = '';
        Map<String, String> claims = new Map<String, String>();
        claims.put(JTI, (System.now().getTime() / 1000) + '-' + userExternalId);
        claims.put(OPERATION, OPERATION_CUSTOMER_LOGIN);
        claims.put(STORE_HASH, bigCommerceConnection.Store_Hash__c);
        claims.put(CUSTOMER_ID, userExternalId);

        Url retURL = new Url(this.retURL);
        String redirectURL = retURL.getPath();
        if (String.isNotBlank(retURL.getQuery())) {
            redirectURL += '?' + retURL.getQuery();
        }
        if (String.isNotBlank(accessTokenWrapper?.access_token)) {
            redirectURL += '#access_token='
                    + accessTokenWrapper?.access_token;
        }
        if (this.stateOriginal != null) {
            redirectURL += '&state=' + this.stateOriginal;
        }
        if (String.isNotBlank(redirectURL)) {
            claims.put(REDIRECT_TO, redirectURL);
        }
        jwt.claims = claims;
        jwt.privateKey = bigCommerceConnection.Client_Secret__c;

        return jwt.issue();
    }

    private String getUserExternalId(
            BigCommerce_Connection__c bigCommerceConnection,
            PS_BigCommerceUserManagementService bigCommerceService
    ) {
        if (String.isNotBlank(bigCommerceConnection.Connected_App_Id__c)) {
            List<UserProvAccount> userProvAccounts = [
                    SELECT Id,ExternalUserId
                    FROM UserProvAccount
                    WHERE SalesforceUserId = :System.UserInfo.getUserId()
                    AND LinkState = :LINK_STATE_LINKED
                    AND Status = :STATUS_ACTIVE
                    AND ConnectedAppId = :bigCommerceConnection.Connected_App_Id__c
                    LIMIT 1
            ];
            System.debug(userProvAccounts);
            if (!userProvAccounts.isEmpty()) {
                return userProvAccounts.get(0).ExternalUserId;
            }
        }

        return bigCommerceService.getUserIdFromBigCommerceAPI();
    }

    private PS_OAuthAccessTokenWrapper makeCalloutToOAuthToken() {
        Connected_Application_Reference__mdt applicationReference =
                PS_ConnectedAppReferenceHelper.getConnectedAppReferenceConfigByDomain(this.retUrlDomain);

        HttpRequest request = new HttpRequest();
        request.setHeader(CONTENT_TYPE, APP_X_WWW_URLENCODED);
        request.setMethod(POST_METHOD);

        String endpoint = baseURL + OAUTH2_TOKEN_ENDPOINT + '?';
        endpoint += GRANT_TYPE + '=' + AUTHORIZATION_CODE + '&';
        endpoint += CODE_PARAM + '=' + code + '&';
        endpoint += CLIENT_ID + '=' + applicationReference.Client_Id__c + '&';
        endpoint += REDIRECT_URI + '=' + EncodingUtil.urlEncode(applicationReference.Redirect_URI__c, UTF_8);
        request.setEndpoint(endpoint);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug(response);
        System.debug(response.getBody());
        System.debug(response.getStatus());
        PS_OAuthAccessTokenWrapper responseData = new PS_OAuthAccessTokenWrapper();
        if (response.getStatusCode() == 200) {
            responseData =
                    (PS_OAuthAccessTokenWrapper) JSON.deserialize(
                            response.getBody(),
                            PS_OAuthAccessTokenWrapper.class
                    );
        }

        return responseData;
    }

    private PageReference redirectToLogout() {
        Customer_IdP_Configuration__mdt customerIdPConfiguration =
                PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
        return new PageReference(customerIdPConfiguration.Logout_Url__c);
    }
}
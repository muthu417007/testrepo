public with sharing class PS_SSOService {

    @TestVisible
    private static String userType;

    private static final String OAUTH_AUTHORIZE_END_POINT = '/services/oauth2/authorize?';
    private static final String AUTH_FLOW_IMPLICIT_GRANT = 'Implicit_Grant';
    private static final String RESPONSE_TYPE_TOKEN = 'token';
    private static final String RESPONSE_TYPE_CODE = 'code';
    private static final String UTF_8 = 'UTF-8';
    private static final String USER_TYPE_GUEST = 'Guest';
    private static final String REDIRECT_URL_COOKIE = 'redirectURL';
    private static final String STATE_COOKIE = 'state';
    private static final String ALLOW_GUEST_COOKIE = 'allowGuest';
    private static final String GUEST_URL_COOKIE = 'guestURL';
    private static final String COMMUNITY_HOME_PAGE_Bodewell = '/mya-my-products';
    private static final String COMMUNITY_HOME_PAGE = '/s/mya-my-products';
    private static final String COMMUNITY_HOME_PAGE_ANW = System.Label.Air_and_Water_Redirection_URL;

    private String redirectURL;
    private String state;
    private String language;
    private String allowGuest;
    private String baseURL = System.Site.getBaseUrl();
   	private String pathPrefix = System.Site.getPathPrefix();
    private Boolean isDefaultConfigUsed = false;
    private String guestURL;
    private String internalRedirect;

    public PS_SSOService(String redirectURL, String state, String language, String allowGuest) {
        this.redirectURL = redirectURL;
        this.state = state;
        this.language = language;
        this.allowGuest = allowGuest;
        this.guestURL =System.currentPageReference().getParameters().get('guestURL');
        this.internalRedirect =System.currentPageReference().getParameters().get('internalRedirect');
    }

    public PageReference redirect() {
        System.debug(redirectURL);
        System.debug(state);
        System.debug(language);
        System.debug(baseURL);
        System.debug(allowGuest);

       
         
        
        handleCookies();
        
        /*when user tries to login from Contact record within internal salesforce application
          redirect him to my product page
         */
        	/*  if((redirectURL==null && state==null )){
               String prefix = Site.getPathPrefix();
	           if( baseURL.contains('/bodewellComercevforcesite') == true) {
	             //return new PageReference( 'https://geapp--qa.sandbox.my.site.com/bodewellCommerce/mya-my-products');
	             return new PageReference( baseURL + COMMUNITY_HOME_PAGE_Bodewell);
	           }
	           
	        } */


        if((redirectURL==null && state==null)){            
            if( pathPrefix.contains('bodewell') == true) {
                List<String> domainURL = baseURL.split('bodewell');
                return new PageReference( domainURL[0] + 'bodewellCommerce' + COMMUNITY_HOME_PAGE_Bodewell);
            } else {                
            	return new PageReference(baseURL + COMMUNITY_HOME_PAGE);
            }
        }

        //if guest user redirect to login page
        if (getUserType().equalsIgnoreCase(USER_TYPE_GUEST)) {
            return getLoginPageRedirect();
        } else {
            //for redirect to internal community page
            if(internalRedirect=='1'){
                return new PageReference(redirectURL);
            } else{
                //if user is logged in initiate OAuth Flow
                return getOAuthPageRedirect();
        	}
        }
    }

    public PageReference getLoginPageRedirect() {
        PageReference loginPage = Network.forwardToAuthPage(System.currentPageReference().getUrl());
        if (Test.isRunningTest() && loginPage == null) {
            loginPage = new PageReference(System.Url.getSalesforceBaseUrl().toExternalForm() + '/login');
        }
        loginPage.setRedirect(true);
        loginPage.getParameters().put('language', language);
		System.debug('loginPage='+loginPage);
        return loginPage;
    }

    public PageReference getOAuthPageRedirect() {
        Connected_Application_Reference__mdt appParameters = getConnectedAppReference();

        String oAuthURL = baseURL + OAUTH_AUTHORIZE_END_POINT;

        PageReference oAuthPage = new PageReference(oAuthURL);
        oAuthPage.setRedirect(true);
        oAuthPage.getParameters().put(
                'response_type',
                appParameters.Auth_Flow__c.equalsIgnoreCase(AUTH_FLOW_IMPLICIT_GRANT) ?
                        RESPONSE_TYPE_TOKEN :
                        RESPONSE_TYPE_CODE
        );
        oAuthPage.getParameters().put('redirect_uri', appParameters.Redirect_URI__c);
        oAuthPage.getParameters().put('client_id', appParameters.Client_Id__c);
        oAuthPage.getParameters().put('scope', appParameters.Scope__c);
        oAuthPage.getParameters().put(
                'state',
                getEncodedRedirectionURL(
                        isDefaultConfigUsed ? appParameters.Domain__c : redirectURL,
                        state,
                        appParameters.Is_Internally_Managed__c
                )
        );
        System.debug('oAuthPage='+oAuthPage);
        return oAuthPage;
    }

    private void handleCookies() {
        Map<String, Cookie> cookiesMap = System.currentPageReference().getCookies();
        List<Cookie> newCookies = new List<Cookie>();

        if (String.isNotBlank(this.redirectURL)) {
            newCookies.add(createRootSessionCookie(
                    REDIRECT_URL_COOKIE,
                    this.redirectURL
            ));
            newCookies.add(createRootSessionCookie(
                    STATE_COOKIE,
                    this.state
            ));
            newCookies.add(createRootSessionCookie(
                    GUEST_URL_COOKIE,
                    this.guestURL
            ));
            
            newCookies.add(createRootSessionCookie(
                    ALLOW_GUEST_COOKIE,
                    this.allowGuest == '1' ? '1' : '0'
            ));
        } else {
            this.redirectURL = cookiesMap.get(REDIRECT_URL_COOKIE)?.getValue();
        }

        if (String.isBlank(this.allowGuest)) {
            this.allowGuest = cookiesMap.get(ALLOW_GUEST_COOKIE)?.getValue();
        }

        if (String.isBlank(this.state)) {
            this.state = cookiesMap.get(STATE_COOKIE)?.getValue();
        }
        if (String.isBlank(this.guestURL)) {
            this.guestURL = cookiesMap.get(GUEST_URL_COOKIE)?.getValue();
        }

        System.currentPageReference().setCookies(
                newCookies
        );
    }

    private static Cookie createRootSessionCookie(String name, String value) {
        return new Cookie(
                name,
                value,
                null,
                -1,
                false,
                'Strict'
        );
    }

    private static String getEncodedRedirectionURL(
            String redirectURL,
            String state,
            Boolean isInternallyManaged
    ) {
        if (!isInternallyManaged) {
            return state;
        }

        PS_OAuthStateWrapper stateWrapper = new PS_OAuthStateWrapper(
                String.isBlank(redirectURL) ? null : EncodingUtil.urlDecode(redirectURL, UTF_8),
                state
        );
        String base64Encode = EncodingUtil.base64Encode(
                Blob.valueOf(
                        JSON.serialize(stateWrapper)
                )
        );
        return base64Encode.replace('=', '');
    }

    private static String getUserType() {
        if (Test.isRunningTest() && userType != null) {
            return userType;
        }
        return System.UserInfo.getUserType();
    }

    private Connected_Application_Reference__mdt getConnectedAppReference() {
        Connected_Application_Reference__mdt appParameters = null;
        if (String.isNotBlank(redirectURL)) {
            Url returnUrl = new Url(EncodingUtil.urlDecode(redirectURL, UTF_8));
            String domain = returnUrl.getProtocol() + '://' + returnUrl.getHost();

            appParameters = PS_ConnectedAppReferenceHelper.getConnectedAppReferenceConfigByDomain(domain);
        }

        if (appParameters == null) {
            List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
            String sitePrefix = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;
            appParameters = PS_ConnectedAppReferenceHelper.getConnectedAppReferenceConfigByEnvConfig(sitePrefix);
            if (appParameters == null) {
                throw new NoConfigRecordFoundException('No Connected Application record found');
            }
            isDefaultConfigUsed = true;
        }
        return appParameters;
    }

   private String getRedirectionURL(){
        User usr =  PS_WebServiceUserInfoHelper.getUserById(System.UserInfo.getUserId());
        String country = usr?.Account.BillingCountry; 
    	String proifile = usr?.CX_Profile_Name__c;
    	redirectURL=COMMUNITY_HOME_PAGE_ANW;
        
        if(proifile.startsWithIgnoreCase('Air and Water Plumber')){
            redirectURL=COMMUNITY_HOME_PAGE_ANW+'/plumbing-partner-program/';
        }
       else if(proifile.startsWithIgnoreCase('VRF')){
           redirectURL=COMMUNITY_HOME_PAGE_ANW+'/vrf-resource-portal/';
        }
        else if(proifile.startsWithIgnoreCase('Air and Water') && (country=='Canada' || country=='CANADA' || country=='CA')){
            redirectURL=COMMUNITY_HOME_PAGE_ANW+'/hvac-partner-program/ca/';
        }
       else 
            redirectURL=COMMUNITY_HOME_PAGE_ANW+'/hvac-partner-program/';
        return redirectURL;
    }
    
    @TestVisible
    private class NoConfigRecordFoundException extends Exception {
    }
}
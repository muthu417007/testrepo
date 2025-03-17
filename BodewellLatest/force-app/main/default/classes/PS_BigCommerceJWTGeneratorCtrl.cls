global with sharing class PS_BigCommerceJWTGeneratorCtrl {

    global PS_BigCommerceJWTGeneratorCtrl() {
    }

    // Code we will invoke on page load.
    global PageReference redirect() {
        String code = System.currentPageReference().getParameters().get('code');
        String state = System.currentPageReference().getParameters().get('state');
        System.debug(code);
        System.debug(state);
        return new PS_BigCommerceAuthService(code, state).redirect();
    }
}
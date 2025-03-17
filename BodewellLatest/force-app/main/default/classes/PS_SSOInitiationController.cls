global with sharing class PS_SSOInitiationController {

    global PS_SSOInitiationController () {}

    // Code we will invoke on page load.
    global PageReference SSOInitialRedirection() {
        String retURL = System.currentPageReference().getParameters().get('redirectURL');
        String state = System.currentPageReference().getParameters().get('state');
        String language = System.currentPageReference().getParameters().get('language');
        String allowGuest = System.currentPageReference().getParameters().get('allowGuest');
        return new PS_SSOService(retURL, state, language, allowGuest).redirect();
    }
}
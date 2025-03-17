public with sharing class PS_OAuthStateWrapper {

    public String retURL;
    public String originalState;

    public PS_OAuthStateWrapper(String retURL, String originalState) {
        this.retURL = retURL;
        this.originalState = originalState;
    }
}
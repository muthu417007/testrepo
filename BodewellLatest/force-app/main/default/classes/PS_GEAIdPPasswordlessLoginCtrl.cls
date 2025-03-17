public with sharing class PS_GEAIdPPasswordlessLoginCtrl {

    @TestVisible
    private static final String PASSWORDLESS_ID = 'passwordlessId';
    @TestVisible
    private static final String USER_ID = 'userId';
    @TestVisible
    private static final String IS_SUCCESS = 'isSuccess';
    @TestVisible
    private static final String REDIRECT_URL = 'redirectUrl';
    @TestVisible
    private static Auth.VerificationResult testVerificationResult = null;

    @AuraEnabled
    public static Map<String, String> sendPasswordlessLogin(String email) {
        PS_GEAIdPPasswordlessLoginService passwordlessLoginService = new PS_GEAIdPPasswordlessLoginService();
        List<User> users = PS_WebServiceUserInfoHelper.getUsersByEmail(email);
        if (users.isEmpty()) {
            return new Map<String, String>();
        }
        User currentUser = users.get(0);

        String passwordlessId = passwordlessLoginService.initPasswordlessLogin(currentUser.Id);

        return new Map<String, String>{
                PASSWORDLESS_ID => passwordlessId,
                USER_ID => currentUser.Id
        };
    }

    @AuraEnabled
    public static Map<String, Object> verifyPasswordlessLogin(
            String userId,
            String passwordlessId,
            String code,
            String startUrl
    ) {
        Auth.VerificationResult verificationResult;
        if (Test.isRunningTest() && testVerificationResult != null) {
            verificationResult = testVerificationResult;
        } else {
            verificationResult = System.UserManagement.verifyPasswordlessLogin(
                    userId,
                    Auth.VerificationMethod.EMAIL,
                    passwordlessId,
                    code,
                    String.isEmpty(startUrl) ? Page.CustomerSSO.getUrl() : startUrl
            );
        }

        return new Map<String, Object>{
                IS_SUCCESS => verificationResult.success,
                REDIRECT_URL => verificationResult.redirect?.getUrl()
        };
    }
}
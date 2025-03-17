public without sharing class PS_GEAIdPPasswordlessLoginService {

    @TestVisible
    private static Boolean testIsUserEmailVerified = false;
    @TestVisible
    private static String testPasswordlessId = null;

    public PS_GEAIdPPasswordlessLoginService() {
    }

    public String initPasswordlessLogin(String userId) {
        //send one time password email
        if (isUserEmailIsVerified(userId)) {
            if (Test.isRunningTest() && testPasswordlessId != null) {
                return testPasswordlessId;
            }
            return System.UserManagement.initPasswordlessLogin(
                    userId,
                    Auth.VerificationMethod.EMAIL
            );
        } else {

            //send verification link
            List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
            String experienceName = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;
            String callbackUrl = '/s/passwordless-login';

            PS_SendVerificationWebServiceHelper.sendEmailVerification(userId, null, experienceName, callbackUrl);
        }

        return null;
    }

    public static Boolean isUserEmailIsVerified(String userId) {
        List<TwoFactorMethodsInfo> twoFactorMethodsInfo = [
                SELECT
                        HasUserVerifiedEmailAddress
                FROM TwoFactorMethodsInfo
                WHERE UserId = :userId
                LIMIT 1
        ];

        if (Test.isRunningTest() && testIsUserEmailVerified) {
            return true;
        }

        if (twoFactorMethodsInfo.isEmpty()) {
            return false;
        }
        return twoFactorMethodsInfo.get(0).HasUserVerifiedEmailAddress;
    }
}
public without sharing class PS_AuthSessionService {

    private Id userId;
    @TestVisible
    private static List<String> testAuthSessionsLoginHistoryApplications;

    public PS_AuthSessionService(Id userId) {
        this.userId = userId;
    }

    public List<String> getAuthSessionsLoginHistoryApplicationsForUser() {
        if (Test.isRunningTest() && testAuthSessionsLoginHistoryApplications != null) {
            return testAuthSessionsLoginHistoryApplications;
        }

        List<String> loginHistoryApplications = new List<String>();
        for (AuthSession authSession : [
                SELECT Id,LoginHistory.Application
                FROM AuthSession
                WHERE UsersId = :this.userId
        ]) {
            loginHistoryApplications.add(authSession.LoginHistory.Application);
        }
        return loginHistoryApplications;
    }

    public void deleteAuthSessionsForUser() {
        delete [
                SELECT Id
                FROM AuthSession
                WHERE UsersId = :userId
        ];
    }
}
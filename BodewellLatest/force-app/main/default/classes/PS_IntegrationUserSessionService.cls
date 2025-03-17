public with sharing class PS_IntegrationUserSessionService {

    public class InputParameters {
        @InvocableVariable
        public String userId;
    }

    @InvocableMethod
    public static void removeUserSession(List<InputParameters> inputList) {
        InputParameters input = inputList.get(0);

        PS_AuthSessionService psAuthSessionService = new PS_AuthSessionService(input.userId);
//      delete all auth sessions
        psAuthSessionService.deleteAuthSessionsForUser();
    }
}
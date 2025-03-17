@IsTest
public with sharing class PS_IntegrationUserSessionServiceTest {

    private static final String CLASS_NAME = PS_IntegrationUserSessionServiceTest.class
            .getName()
            .substring(0, 15);

    @TestSetup
    public static void createData() {
        PS_TestHelper.createRemoteAdminUser(CLASS_NAME);
    }

    @IsTest
    public static void shouldTryToRemoveAuthSessions_WhenCalled() {
        //given
        User remoteAdminUser = PS_TestHelper.getCreatedRemoteAdminUser(CLASS_NAME);
        PS_IntegrationUserSessionService.InputParameters inputParameters =
                new PS_IntegrationUserSessionService.InputParameters();
        inputParameters.userId = remoteAdminUser.Id;

        //then
        System.runAs(remoteAdminUser) {
            Test.startTest();
            PS_IntegrationUserSessionService.removeUserSession(
                    new List<PS_IntegrationUserSessionService.InputParameters>{
                            inputParameters
                    }
            );
            Test.stopTest();
        }

        System.assertEquals(
                0,
                [
                        SELECT Id
                        FROM AuthSession
                        WHERE UsersId = :remoteAdminUser.Id
                ].size(),
                'AuthSession record should have been removed'
        );
    }
}
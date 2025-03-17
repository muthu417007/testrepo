@IsTest
public with sharing class PS_GEAIdPPasswordlessLoginCtrlTest {

    private static final String CLASS_NAME = PS_GEAIdPPasswordlessLoginCtrlTest.class
            .getName()
            .substring(0, 15);

    @TestSetup
    public static void generateData() {
        PS_TestHelper.createGuestUser(CLASS_NAME);
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
    }

    @IsTest
    public static void shouldInitPasswordlessLogin_WhenEmailVerified() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            PS_GEAIdPPasswordlessLoginService.testIsUserEmailVerified = true;
            PS_GEAIdPPasswordlessLoginService.testPasswordlessId = 'passwordlessId';
            Map<String, String> resultMap = PS_GEAIdPPasswordlessLoginCtrl.sendPasswordlessLogin(
                    portalUser.Username
            );
            Test.stopTest();

            System.assertEquals(
                    portalUser.Id,
                    resultMap.get(PS_GEAIdPPasswordlessLoginCtrl.USER_ID),
                    'Invalid userIs value'
            );

            System.assertNotEquals(
                    null,
                    resultMap.get(PS_GEAIdPPasswordlessLoginCtrl.PASSWORDLESS_ID),
                    'Invalid passwordless id value'
            );
        }
    }

    @IsTest
    public static void shouldReturnEmptyMap_WhenNoUserFound() {
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            Map<String, String> resultMap = PS_GEAIdPPasswordlessLoginCtrl.sendPasswordlessLogin(
                    'invalidUser@test.com'
            );
            Test.stopTest();

            System.assertEquals(
                    true,
                    resultMap.isEmpty(),
                    'Invalid result returned'
            );
        }
    }

    @IsTest
    public static void shouldThrowError_WhenTryingToInitPasswordLessLogin() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        Boolean exceptionThrown = false;

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            try {
                Test.startTest();
                PS_GEAIdPPasswordlessLoginService.testIsUserEmailVerified = true;
                PS_GEAIdPPasswordlessLoginCtrl.sendPasswordlessLogin(
                        portalUser.Username
                );
                Test.stopTest();
            } catch (Exception e) {
                exceptionThrown = e instanceof NoAccessException;
            }

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should have been thrown'
            );
        }
    }

    @IsTest
    public static void shouldThrowError_WhenTryingToSendVerificationEmail() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        Network network = new Network(
                Id = '0DBRM000000015i',
                VerificationEmailTemplateId = '00XRM000000hxnG'
        );
        Boolean exceptionThrown = false;

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            try {
                Test.startTest();
            PS_SendVerificationWebServiceHelper.testNetwork = network;
                PS_SendVerificationWebServiceHelper.sendAsyncEmailConfirmation = true;
                PS_GEAIdPPasswordlessLoginCtrl.sendPasswordlessLogin(
                        portalUser.Username
                );
                Test.stopTest();
            } catch (Exception e) {
                exceptionThrown = e instanceof NoDataFoundException;
            }

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should have been thrown'
            );
        }
    }

    @IsTest
    public static void shouldVerifyPasswordlessCode_WhenValidParameters() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        Auth.VerificationResult verificationResult = new Auth.VerificationResult(
                Page.CustomerSSO,
                true,
                'testMessage'
        );

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            Test.startTest();
            PS_GEAIdPPasswordlessLoginCtrl.testVerificationResult = verificationResult;
            Map<String, Object> resultMap = PS_GEAIdPPasswordlessLoginCtrl.verifyPasswordlessLogin(
                    portalUser.Id,
                    'passwordlessId',
                    'code',
                    null
            );
            Test.stopTest();

            System.assertEquals(
                    true,
                    resultMap.get(PS_GEAIdPPasswordlessLoginCtrl.IS_SUCCESS),
                    'Invalid isSuccess value'
            );

            System.assertEquals(
                    Page.CustomerSSO.getUrl(),
                    resultMap.get(PS_GEAIdPPasswordlessLoginCtrl.REDIRECT_URL),
                    'Invalid redirectUrl value'
            );
        }
    }

    @IsTest
    public static void shouldThrowException_WhenTryingToVerifyPasswordlessLogin() {
        //given
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        Boolean exceptionThrown = false;

        //then
        System.runAs(PS_TestHelper.getCreatedGuestUser(CLASS_NAME)) {
            try {
                Test.startTest();
                PS_GEAIdPPasswordlessLoginCtrl.verifyPasswordlessLogin(
                        portalUser.Id,
                        'passwordlessId',
                        'code',
                        null
                );
                Test.stopTest();
            } catch (Exception e) {
                exceptionThrown = e instanceof NoAccessException;
            }

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should have been thrown'
            );
        }
    }
}
@IsTest
public with sharing class PS_UserSendVerificationWebServiceApiTest {

    private static final String CLASS_NAME = PS_UserSendVerificationWebServiceApiTest.class
            .getName()
            .substring(0, 15);

    @TestSetup
    public static void createData() {
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
    }

    @IsTest
    public static void shouldSentVerificationEmail_OnPOSTRequest() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"successURL":"https://testReturn.com/retURL","successState":"success"}');
        request.requestURI = '/customer-idm/user/v1/send-verification-email/ejt';
        RestContext.request = request;

        Network network = new Network(
                Id = '0DBRM000000015i',
                VerificationEmailTemplateId = '00XRM000000hxnG'
        );

        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.runAs(portalUser) {
            Test.startTest();
            PS_SendVerificationWebServiceHelper.testNetwork = network;
            RestContext.response = new RestResponse();
            PS_UserSendVerificationWebServiceApi.sendVerificationEmailPOST();
            RestResponse restResponse = RestContext.response;
            Test.stopTest();

            System.assertEquals(
                    204,
                    restResponse.statusCode,
                    'Invalid status code returned'
            );
        }
    }

    @IsTest
    public static void shouldSentVerificationEmail_OnPOSTRequestWithDefaultSuccessURL() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('');
        request.requestURI = '/customer-idm/user/v1/send-verification-email/ejt';
        RestContext.request = request;

        Network network = new Network(
                Id = '0DBRM000000015i',
                VerificationEmailTemplateId = '00XRM000000hxnG'
        );

        Customer_IdP_Configuration__mdt customerIdPConfiguration = new Customer_IdP_Configuration__mdt(
                Email_Template_Verification__c = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration().Email_Template_Verification__c,
                Email_Verification_Success_URL__c = 'https://successemail@ver.com'
        );

        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.runAs(portalUser) {
            Test.startTest();
            PS_GEAIdPCustomerConfigHelper.customerIdPConfiguration = customerIdPConfiguration;
            PS_SendVerificationWebServiceHelper.testNetwork = network;
            RestContext.response = new RestResponse();
            PS_UserSendVerificationWebServiceApi.sendVerificationEmailPOST();
            RestResponse restResponse = RestContext.response;
            Test.stopTest();

            System.assertEquals(
                    204,
                    restResponse.statusCode,
                    'Invalid status code returned'
            );
        }
    }

    @IsTest
    public static void shouldThrowError_WhenNoNetworkFound() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"successURL":"https://testReturn.com/retURL"}');
        request.requestURI = '/customer-idm/user/v1/send-verification-email/invalid';
        RestContext.request = request;

        Boolean exceptionThrown = false;

        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.runAs(portalUser) {
            Test.startTest();
            try {
                PS_UserSendVerificationWebServiceApi.sendVerificationEmailPOST();
            } catch (Exception e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should be thrown'
            );
        }
    }

    @IsTest
    public static void shouldThrowError_WhenSendingEmailConfirmationWithInvalidParams() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"successURL":"https://testReturn.com/retURL","successState":"success"}');
        request.requestURI = '/customer-idm/user/v1/send-verification-email/invalid';
        RestContext.request = request;

        Network network = new Network(
                Id = '0DBRM000000015i',
                VerificationEmailTemplateId = '00XRM000000hxnG'
        );

        Boolean exceptionThrown = false;

        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.runAs(portalUser) {
            Test.startTest();
            try {
                PS_SendVerificationWebServiceHelper.testNetwork = network;
                PS_SendVerificationWebServiceHelper.sendAsyncEmailConfirmation = true;
                PS_UserSendVerificationWebServiceApi.sendVerificationEmailPOST();
            } catch (Exception e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assertEquals(
                    true,
                    exceptionThrown,
                    'Exception should be thrown'
            );
        }
    }
}
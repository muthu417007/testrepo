@IsTest
public with sharing class PS_RemoteAdminSendVerificationTest {

    private static final String CLASS_NAME = PS_RemoteAdminSendVerificationTest.class
            .getName()
            .substring(0, 15);
    private static final String TEST_GLOBAL_CUSTOMER_ID = '987654';

    @TestSetup
    public static void createData() {
        PS_TestHelper.createPortalUserWithAccount(CLASS_NAME);
    }

    @IsTest
    public static void shouldSentVerificationEmail_OnPOSTRequest() {

        Contact contact = PS_TestHelper.getCreatedPortalContact(CLASS_NAME);
        contact.Global_Customer_Id__c = TEST_GLOBAL_CUSTOMER_ID;
        update contact;

        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"successURL":"https://testReturn.com/retURL","successState":"success"}');
        request.requestURI = '/customer-idm/user/v1/send-verification-email/' + TEST_GLOBAL_CUSTOMER_ID;
        RestContext.request = request;

        Network network = new Network(
                Id = '0DBRM000000015i',
                VerificationEmailTemplateId = '00XRM000000hxnG'
        );

        Test.startTest();
        PS_SendVerificationWebServiceHelper.testNetwork = network;
        RestContext.response = new RestResponse();

        PS_RemoteAdminSendVerificationWebService.sendVerificationEmailPOST();
        RestResponse restResponse = RestContext.response;
        Test.stopTest();

        System.assertEquals(
                204,
                restResponse.statusCode,
                'Invalid status code returned'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenNoUserFound() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"successURL":"https://testReturn.com/retURL,"successState":"success""}');
        request.requestURI = '/customer-idm/user/v1/send-verification-email/' + TEST_GLOBAL_CUSTOMER_ID;
        RestContext.request = request;

        Boolean exceptionThrown = false;

        RestResponse restResponse;
        Test.startTest();
        try {
            RestContext.response = new RestResponse();
            PS_RemoteAdminSendVerificationWebService.sendVerificationEmailPOST();
            restResponse = RestContext.response;
        } catch (Exception e) {
            exceptionThrown = e instanceof PS_RemoteAdminSendVerificationWebService.NoDataFoundException;
        }
        Test.stopTest();

        System.assertEquals(
                true,
                exceptionThrown,
                'Error should be thrown'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenParameterMissing() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"successURL":"https://testReturn.com/retURL,"successState":"success""}');
        request.requestURI = '/ ';
        RestContext.request = request;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            PS_RemoteAdminSendVerificationWebService.sendVerificationEmailPOST();
        } catch (Exception e) {
            exceptionThrown = e instanceof IllegalArgumentException;
        }
        Test.stopTest();

        System.assertEquals(
                true,
                exceptionThrown,
                'Exception should be thrown'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenSendingEmailConfirmationWithInvalidParams() {

        Contact contact = PS_TestHelper.getCreatedPortalContact(CLASS_NAME);
        contact.Global_Customer_Id__c = TEST_GLOBAL_CUSTOMER_ID;
        update contact;

        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"successURL":"https://testReturn.com/retURL,"successState":"success""}');
        request.requestURI = '/customer-idm/user/v1/send-verification-email/testExperienceName/' + TEST_GLOBAL_CUSTOMER_ID;
        RestContext.request = request;

        Network network = new Network(
                Id = '0DBRM000000015i',
                VerificationEmailTemplateId = '00XRM000000hxnG'
        );

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            PS_SendVerificationWebServiceHelper.testNetwork = network;
            PS_SendVerificationWebServiceHelper.sendAsyncEmailConfirmation = true;
            PS_RemoteAdminSendVerificationWebService.sendVerificationEmailPOST();
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
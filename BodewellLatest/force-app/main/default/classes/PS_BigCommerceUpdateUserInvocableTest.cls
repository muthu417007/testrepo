@IsTest
public with sharing class PS_BigCommerceUpdateUserInvocableTest {

    
    
    
    @IsTest
    public static void shouldMakeCalloutToBigCommerce_WhenValidParameters() {
        //given
        PS_BigCommerceUpdateUserInvocable.UpdateUserPUTCalloutInput inputWrapper =
                new PS_BigCommerceUpdateUserInvocable.UpdateUserPUTCalloutInput();
        inputWrapper.endpoint = 'https://test.com';
        inputWrapper.authToken = 'authToken';
        inputWrapper.storeHash = 'storeHash';
        inputWrapper.firstName = 'testFirstName';
        inputWrapper.lastName = 'testLastName';
        inputWrapper.id = '1145';
        inputWrapper.siteName='Air and Water';

        Boolean exceptionThrown = false;
        //then
        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BigCommerceCustomerPutAPIMock());
            PS_BigCommerceUpdateUserInvocable.updateUserPUTCallout(
                    new List<PS_BigCommerceUpdateUserInvocable.UpdateUserPUTCalloutInput>{
                            inputWrapper
                    }
            );
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = true;
        }

        System.assertEquals(
                false,
                exceptionThrown,
                'No exception should be thrown'
        );
    }

    public class BigCommerceCustomerPutAPIMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest param1) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('success');

            return response;
        }
    }
}
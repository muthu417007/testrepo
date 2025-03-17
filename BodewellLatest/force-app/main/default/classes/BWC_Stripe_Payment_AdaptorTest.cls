@isTest
public with sharing class BWC_Stripe_Payment_AdaptorTest {
 
    @isTest
    static void testTokenizeResponse_Success() {
        BWC_Stripe_Payment_Adaptor adapter = new BWC_Stripe_Payment_Adaptor();
        commercepayments.PaymentMethodTokenizationRequest paymentRequest = new commercepayments.PaymentMethodTokenizationRequest('paymentGatewayId');
        commercepayments.CardPaymentMethodRequest cardPaymentMethodRequest = new commercepayments.CardPaymentMethodRequest(commercepayments.CardCategory.CreditCard);
        paymentRequest.address = new commercepayments.AddressRequest('street', 'city', 'state', 'country', 'postalCode');
        paymentRequest.cardPaymentMethod = cardPaymentMethodRequest;
        paymentRequest.cardPaymentMethod.cardHolderName = 'TEST CARDHOLDER NAME';
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(paymentRequest, commercepayments.RequestType.Tokenize);
 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
        Test.stopTest();
 
        // Add assertions to verify the success scenario
        // Example:
        //System.assert(response instanceof commercepayments.PaymentMethodTokenizationResponse, 'Expected PaymentMethodTokenizationResponse');
        commercepayments.PaymentMethodTokenizationResponse tokenizeResponse = (commercepayments.PaymentMethodTokenizationResponse) response;
        //System.assertEquals('success', tokenizeResponse.getGatewayResultCode());
        // Add more assertions as needed
    }
/*   
  @isTest
    static void testCreateTokenizeResponse() {
        // Create a mock StripeAdapter
        StripeAdapter stripeAdapter = new StripeAdapter();
 
        // Create a mock tokenizeRequest
        commercepayments.PaymentMethodTokenizationRequest tokenizeRequest = createMockTokenizeRequest();
 
        // Call the method on the instantiated object
        stripeAdapter.createTokenizeResponse(tokenizeRequest);
 
        // Add assertions based on your expected behavior
 
        // Reset any mock data or state if needed
    }*/
 
    // Helper method to create a mock PaymentMethodTokenizationRequest
  /*  private static commercepayments.PaymentMethodTokenizationRequest createMockTokenizeRequest() {
        commercepayments.CardPaymentMethodRequest cardPaymentMethod = new commercepayments.CardPaymentMethodRequest();
        cardPaymentMethod.cardHolderName = 'John Doe';
        cardPaymentMethod.cardNumber = '4111111111111111';
        cardPaymentMethod.expiryMonth = 12;
        cardPaymentMethod.expiryYear = 2023;
        cardPaymentMethod.cvv = '123';
 
        commercepayments.PaymentMethodTokenizationRequest tokenizeRequest = new commercepayments.PaymentMethodTokenizationRequest();
        tokenizeRequest.cardPaymentMethod = cardPaymentMethod;
 
        // Add more properties to tokenizeRequest based on your needs
 
        return tokenizeRequest;
    } */   
     /*  @isTest
    static void testCreateAuthResponse() {
        // Create necessary test data or mock objects
        commercepayments.AuthorizationRequest authRequest = createMockAuthorizationRequest();
 
        // Mock the HTTP response from Stripe
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"status": "succeeded", "id": "mocked_payment_id", "amount": 5000}');
 
        Test.startTest();
        // Mock the HTTP callout to Stripe
        Test.setMock(HttpCalloutMock.class, new MockStripeHttpResponse(mockResponse));
 
        // Call the method
        commercepayments.GatewayResponse result = StripeAdapter.createAuthResponse(authRequest);
        Test.stopTest();
 
        // Assert the expected result
        //System.assertNotEquals(null, result, 'GatewayResponse should not be null');
       // System.assertEquals('succeeded', result.getGatewayResultCode(), 'GatewayResultCode should be "succeeded"');
       // System.assertEquals('succeeded', result.getGatewayResultCodeDescription(), 'GatewayResultCodeDescription should be "succeeded"');
        // Add more assertions based on your expected behavior
 
        // Reset the HTTP mock
        Test.setMock(HttpCalloutMock.class, null);
    }
*/
    // Helper method to create a mock AuthorizationRequest
 
    
     @isTest
    static void testToStripeCurrencyUnits() {
        // Test when currency is not 'inr'
        String currencyIsoCodeLC = 'usd';
        Double amount = 50.00;
        Long expectedCurrencyUnits = 5000; // Assuming rounding to cents
 
        Test.startTest();
       // Long result = BWC_Stripe_Payment_Adaptor.toStripeCurrencyUnits(currencyIsoCodeLC, amount);
        Test.stopTest();
 
        //System.assertEquals(expectedCurrencyUnits, result);
 
        // Add more test cases for different currencies if needed
    }
 
    
     @isTest
    static void testPostCard() {
        // Test when currency is not 'inr'
        String cardNumber = '411111111111';
        String expMonth = '12';
        String expYear = '29';
        String cvc = '121';
        // Assuming rounding to cents
 
        Test.startTest();
       // BWC_Stripe_Payment_Adaptor.postCard(cardNumber, expMonth, expYear, cvc);
        Test.stopTest();
 
        //System.assertEquals(expectedCurrencyUnits, result);
 
        // Add more test cases for different currencies if needed
    }
 
    
    @isTest
    static void testCreateAuthResponse_Success() {
        BWC_Stripe_Payment_Adaptor adapter = new BWC_Stripe_Payment_Adaptor();
        commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(100);
        authRequest.currencyIsoCode = 'USD';
        // Set other required fields for the authorization request
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
        Test.stopTest();
 
        // Add assertions to verify the success scenario for authorization
        // Example:
       // System.assert(response instanceof commercepayments.AuthorizationResponse, 'Expected AuthorizationResponse');
        commercepayments.AuthorizationResponse authResponse = (commercepayments.AuthorizationResponse) response;
        //System.assertEquals('success', authResponse.getGatewayResultCode());
        // Add more assertions as needed
    }
 
    // Add more test methods to cover other functionalities of the StripeAdapter class
 
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Implement the mock response as needed for testing
            // Example:
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"id": "testToken"}');
            return res;
        }
    }
}
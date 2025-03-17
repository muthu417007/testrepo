@IsTest
public class BWC_CybersourceHPP_PaymentAdapterTest {

    @IsTest
    static void processRequestTest() {
        Double amt = 25;
        commercepayments.AuthorizationRequest cr = new commercepayments.AuthorizationRequest(amt);
        commercepayments.RequestType rt = commercepayments.RequestType.Authorize;
        BWC_CybersourceHPP_PaymentAdapter adapter = new BWC_CybersourceHPP_PaymentAdapter();
        commercepayments.PaymentGatewayContext ctx = new commercepayments.PaymentGatewayContext(cr, rt); // <-- optional constructor for tests only
        commercepayments.GatewayResponse resp = adapter.processRequest(ctx);
        System.assertNotEquals(null, resp, 'Unit test passed');
    }

    @isTest
    static void testCreateTokenizeResponse() {
        Test.startTest();
        BWC_CybersourceHPP_PaymentAdapter adapter = new BWC_CybersourceHPP_PaymentAdapter();
        commercepayments.PaymentMethodTokenizationRequest paymentRequest = new commercepayments.PaymentMethodTokenizationRequest('paymentGatewayId');
        commercepayments.CardPaymentMethodRequest cardPaymentMethodRequest = new commercepayments.CardPaymentMethodRequest(
            commercepayments.CardCategory.CreditCard
        );
        paymentRequest.address = new commercepayments.AddressRequest('street', 'city', 'state', 'country', 'postalCode');
        paymentRequest.cardPaymentMethod = cardPaymentMethodRequest;
        paymentRequest.cardPaymentMethod.cardHolderName = 'TEST CARDHOLDER NAME';
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(
            paymentRequest,
            commercepayments.RequestType.Tokenize
        );
        System.assertNotEquals(null, gatewayContext, 'Unit test passed');
        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
        Test.stopTest();
    }
}
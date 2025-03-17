global class BWC_Stripe_Payment_Adaptor implements commercepayments.PaymentGatewayAdapter {
  global BWC_Stripe_Payment_Adaptor() {
    }

     private static final commercepayments.SalesforceResultCodeInfo SUCCESS_SALESFORCE_RESULT_CODE_INFO = new commercepayments.SalesforceResultCodeInfo(
        commercepayments.SalesforceResultCode.Success
    );

    private static final commercepayments.SalesforceResultCodeInfo DECLINE_SALESFORCE_RESULT_CODE_INFO = new commercepayments.SalesforceResultCodeInfo(
        commercepayments.SalesforceResultCode.Decline
    );

       global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.GatewayResponse response;
        try {
            if (requestType == commercepayments.RequestType.Authorize) {
                response = createAuthResponse((commercepayments.AuthorizationRequest) gatewayContext.getPaymentRequest());
            } else if (requestType == commercepayments.RequestType.Tokenize) {
                response = createTokenizeResponse((commercepayments.PaymentMethodTokenizationRequest)gatewayContext.getPaymentRequest());
            }
            return response;
        } catch (SalesforceValidationException e) {
            commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('400', e.getMessage());
            return error;
        }
    }
      /**
     * @description  processRequest
     * @param authRequest authRequest
     * @return `commercepayments.GatewayResponse` commercepayments.GatewayResponse
     */
    public commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
        commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
        commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
        if (authRequest.amount != null) {
            authResponse.setAmount(authRequest.amount);
        } else {
            throw new SalesforceValidationException('Required Field Missing : Amount');
        }

        authResponse.setGatewayResultCode('00');
        authResponse.setGatewayResultCodeDescription('Transaction Normal');
        authResponse.setGatewayAuthCode('SF' + getRandomNumber(6));
        authResponse.setGatewayReferenceNumber(getRandomNumber(10));
        authResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        authResponse.setGatewayDate(system.now());
        paymentMethodTokenizationResponse.setGatewayToken(getRandomNumber(8) + getRandomNumber(8));
        authResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);
        return authResponse;
    }
    
    /**
     * @description This method is reauired for PaymentMethod record creation in FiservPaymentController class
     * @param tokenizeRequest 
     * @return  `commercepayments.GatewayResponse`
     */
    public commercepayments.GatewayResponse createTokenizeResponse(commercepayments.PaymentMethodTokenizationRequest tokenizeRequest) {
        commercepayments.PaymentMethodTokenizationResponse tokenizeResponse = new commercepayments.PaymentMethodTokenizationResponse();
        tokenizeResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        tokenizeResponse.setGatewayToken(getRandomNumber(8)+getRandomNumber(8));
        tokenizeResponse.setGatewayDate(system.now());
        return tokenizeResponse;
    }

       /**
     * @description  getRandomNumber
     * @param stringLength stringLength
     * @return `String`
     */
    private String getRandomNumber(integer stringLength) {
        final integer MAX = integer.valueOf(Math.pow(10, stringLength) - 1);
        return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength, '0');
    }
    public class SalesforceValidationException extends Exception {
    }

}
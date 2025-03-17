@SuppressWarnings('PMD')

/**
 * @description This class is for the Cybersource controller
 */
public without sharing class BWC_CybersourceController {
    // This interface is used for stubbing/mocking out the calls to the ConnectApi.Payments class for testing
    public interface BWC_ConnectApiProxy {
        String tokenizePaymentMethod(ConnectApi.PaymentMethodTokenizationRequest tokenizeRequest);
        ConnectApi.AuthorizationResponse authorize(ConnectApi.AuthorizationRequest request);
    }

    // This is the implementation class for the BWC_ConnectApiProxy interface
    @TestVisible private class RealConnectApiProxy implements BWC_ConnectApiProxy {
        public String tokenizePaymentMethod(ConnectApi.PaymentMethodTokenizationRequest tokenizeRequest) {
            return ConnectApi.Payments.tokenizePaymentMethod(tokenizeRequest)?.paymentMethod?.id;
        }
        public ConnectApi.AuthorizationResponse authorize(ConnectApi.AuthorizationRequest request) {
            return ConnectApi.Payments.authorize(request);
        }
    }

    // This is the object that will be used for stubbing/mocking out the calls to the ConnectApi.Payments class for testing
    // It will get replaced with a mock object in the test class
    @TestVisible private static BWC_ConnectApiProxy myProxy = new RealConnectApiProxy();

    private static final String LEVEL = 'Error';
    private static final String SOURCE_CLASS = 'BWC_CybersourceController';

    /**
     * @description This method is used to get the parameters for the Cybersource request
     * @param {String} deliveryAddress - The delivery address of the cart
     * @param {String} cartSummary - The cart summary
     * @return {Map<String, String>} The parameters for the Cybersource request
     */
    @AuraEnabled
    public static Map<String, String> getParameters(String accountId, String cartSummary) {
        try {
            Map<String, String> config = getConfig();
            Map<String, String> result = new Map<String, String>();

            List<ContactPointAddress> billingAddressList = [SELECT Street, City, State, Country, PostalCode
                                                 FROM ContactPointAddress
                                                 WHERE ParentId = :accountId AND IsDefault = true AND AddressType = 'Billing'
                                                 LIMIT 1];

            if (billingAddressList.size() == 0) {
                throw new AuraHandledException('No default Shipping Address found for account: ' + accountId);
            }

            ContactPointAddress billingAddress = billingAddressList[0];

            BWC_CybersourceCartSummary csCartSummary = BWC_CybersourceCartSummary.parse(cartSummary);
            String myLocale = UserInfo.getLocale();

            // The order of the fields below is important, if the order is changed then Cybersource will not accept it.
            result.put('merchant_defined_data1', config.get('merchant_defined_data1'));
            result.put('merchant_defined_data2', config.get('merchant_defined_data2'));
            result.put('merchant_defined_data3', config.get('merchant_defined_data3'));
            result.put('tax_amount', csCartSummary.totalTaxAmount);
            result.put('amount', csCartSummary.grandTotalAmount);
            result.put('transaction_uuid', getUUID());
            result.put('unsigned_field_names', '');
            result.put('signed_field_names', 'merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,tax_amount,amount,transaction_uuid,unsigned_field_names,signed_field_names,signed_date_time,transaction_type,locale,currency,override_custom_receipt_page,override_custom_cancel_page,reference_number,access_key,profile_id,merchant_defined_data4,bill_to_address_country,bill_to_address_line1,bill_to_forename,bill_to_address_postal_code,bill_to_address_state,bill_to_surname,bill_to_address_city,bill_to_email');
            result.put('signed_date_time', getUTCDateTime());
            result.put('transaction_type', 'authorization,create_payment_token');
            result.put('locale', myLocale.indexOf('_') != -1 ? myLocale.split('_')[0] : myLocale);
            result.put('currency', csCartSummary.currencyIsoCode);
            result.put('override_custom_receipt_page', config.get('override_custom_receipt_page'));
            result.put('override_custom_cancel_page', config.get('override_custom_cancel_page'));
            result.put('reference_number', csCartSummary.cartId + config.get('reference_number_suffix'));
            result.put('access_key', config.get('access_key'));
            result.put('profile_id', config.get('profile_id'));
            result.put('merchant_defined_data4', config.get('merchant_defined_data4'));
            result.put('bill_to_address_country', convertToCountryCode(billingAddress.Country));
            result.put('bill_to_address_line1', billingAddress.Street);
            result.put('bill_to_forename',  UserInfo.getFirstName());
            result.put('bill_to_address_postal_code', billingAddress.PostalCode);
            result.put('bill_to_address_state', billingAddress.State);
            result.put('bill_to_surname', UserInfo.getLastName());
            result.put('bill_to_address_city', billingAddress.City);
            result.put('bill_to_email', UserInfo.getUserEmail());
            String data = '';
            for(String key : result.keyset()) {
                data += key + '=' + result.get(key) + ',';
            }
            data = data.removeEnd(',');
            result.put('signature', sign(data, config.get('secret_key')));
            result.put('hosted_payment_page_url', config.get('hosted_payment_page_url'));
            result.put('iframe_url', config.get('iframe_url'));
            return result;
        } catch (Exception e) {
            CX_Logger logger = new CX_Logger();
            String sourceFunction = 'getParameters';
            logger.logMessage(LEVEL, SOURCE_CLASS, sourceFunction, e.getMessage(), null, null, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String convertToCountryCode(String country) {
        if (country == 'United States of America') {
            return 'US';
        }
        return country;
    }

    /**
     * @description This method is used to authorize the payment using Cybersource
     * @param {String} strPaymentRecord The payment record to authorize
     * @return {void} This method will return nothing on success, it will throw an exception on failure
     */
    @AuraEnabled
    public static void authorizePayment(String strPaymentRecord) {
        try {
            BWC_CybersourcePaymentRecord paymentRecord = BWC_CybersourcePaymentRecord.parse(strPaymentRecord);

            ConnectApi.AuthorizationRequest request = new ConnectApi.AuthorizationRequest();

            String pgId = [SELECT Id, Integration FROM StoreIntegratedService WHERE ServiceProviderType = 'Payment' AND StoreId = :paymentRecord.webstoreId LIMIT 1]?.Integration;

            request.paymentGatewayId = pgId;
            request.amount = paymentRecord.auth_amount;
            request.accountId = paymentRecord.accountId;
            request.comments = 'AUTHORIZING ' + paymentRecord.auth_amount;
            request.currencyIsoCode = paymentRecord.currencyIsoCode;

            ConnectApi.PaymentGroupRequest paymentGroupRequest = new ConnectApi.PaymentGroupRequest();
            paymentGroupRequest.currencyIsoCode = paymentRecord.currencyIsoCode;
            paymentGroupRequest.createPaymentGroup = true;

            request.paymentGroup = paymentGroupRequest;
            request.accountId = paymentRecord.accountId;

            ConnectApi.AuthApiPaymentMethodRequest authApiPayMethodRequest = new ConnectApi.AuthApiPaymentMethodRequest();

            ConnectApi.AddressRequest addressRequest = new ConnectApi.AddressRequest();
            addressRequest.street = paymentRecord.req_bill_to_street;
            addressRequest.city = paymentRecord.req_bill_to_city;
            addressRequest.state = paymentRecord.req_bill_to_state;
            addressRequest.postalCode = paymentRecord.req_bill_to_postal_code;
            addressRequest.country = paymentRecord.req_bill_to_country;

            String sPaymentMethodId = getCardPaymentMethodId(paymentRecord, addressRequest, pgId);

            authApiPayMethodRequest.id = sPaymentMethodId;
            request.paymentMethod = authApiPayMethodRequest;
            ConnectApi.AuthorizationResponse response = myProxy.authorize(request);
            updatePaymentDetailsInCart(paymentRecord.cartId, sPaymentMethodId, response?.paymentGroup?.id);
            updatePaymentDetailsInCardPayment(sPaymentMethodId, paymentRecord);
        } catch (Exception e) {
            CX_Logger logger = new CX_Logger();
            String sourceFunction = 'authorizePayment';
            logger.logMessage(LEVEL, SOURCE_CLASS, sourceFunction, e.getMessage(), null, null, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description This method is used to get the order information
     * @param {String} orderNumber The order number
     * @return {Map<String, String>} The order information
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getOrderInfo(String orderNumber) {
        try {
            String orderNumberTrimmed = orderNumber.trim();
            Map<String, String> results = new Map<String, String>();
            List<OrderSummary> orderSummaries = [SELECT OriginalOrder.bwc_Order_Number__c,OriginalOrder.BWC_ORIG_SYS_DOCUMENT_REF__c FROM OrderSummary WHERE OrderNumber = :orderNumberTrimmed];
            if (orderSummaries.size() > 0) {
                results.put('email', UserInfo.getUserEmail());
                results.put('orderNumber', orderSummaries[0].OriginalOrder.BWC_ORIG_SYS_DOCUMENT_REF__c);
                //OrderReferenceNumber
               // results.put('bdeOrderNUmber',orderSummaries[0].OriginalOrder.bwc_Order_Number__c);
            }
            return results;
        } catch (Exception e) {
            CX_Logger logger = new CX_Logger();
            String sourceFunction = 'getOrderInfo';
            logger.logMessage(LEVEL, SOURCE_CLASS, sourceFunction, e.getMessage(), null, null, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description This method logs the error response returned by Cybersource
     * @param {String} message The error message
     * @param {String} payLoad The error payLoad
     * @return {void} This method will return nothing on success, it will throw an exception on failure
     */
    @AuraEnabled
    public static void logError(String message, String payLoad) {
        try {
            CX_Logger logger = new CX_Logger();
            String sourceClass = 'bwc_cybersourceHPP (LWC)';
            String sourceFunction = 'handlePayment';
            logger.logMessage(LEVEL, sourceClass, sourceFunction, message, payLoad, null, null);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description This method is used to get the card payment method id
     * @param {BWC_CybersourcePaymentRecord} paymentRecord The payment record to authorize
     * @param {ConnectApi.AddressRequest} addressRequest The address request
     * @param {String} pgId The payment gateway id
     * @return {String} The card payment method id
     * @throws {AuraHandledException} This method will throw an exception if the card payment method id cannot be retrieved
     */
    private static String getCardPaymentMethodId(BWC_CybersourcePaymentRecord paymentRecord, ConnectApi.AddressRequest addressRequest, String pgId) {
        ConnectApi.CardPaymentMethodRequest cardPaymentMethodRequest = new ConnectApi.CardPaymentMethodRequest();
        cardPaymentMethodRequest.accountId = paymentRecord.accountId;
        cardPaymentMethodRequest.cardNumber = '000000000000' + paymentRecord.req_card_number.right(4);
        cardPaymentMethodRequest.expiryYear = paymentRecord.expiryYear;
        cardPaymentMethodRequest.expiryMonth = paymentRecord.expiryMonth;
        cardPaymentMethodRequest.cardHolderName = paymentRecord.req_bill_to_forename + ' ' + paymentRecord.req_bill_to_surname;
        cardPaymentMethodRequest.cardType = mapCardName(paymentRecord.card_type_name);
        cardPaymentMethodRequest.cardCategory = ConnectApi.CardCategory.CreditCard;

        ConnectApi.PaymentMethodTokenizationRequest tokenizeRequest = new ConnectApi.PaymentMethodTokenizationRequest();
        tokenizeRequest.address = addressRequest;
        tokenizeRequest.cardPaymentMethod = cardPaymentMethodRequest;
        tokenizeRequest.paymentGatewayId = String.isBlank(pgId) ? '' : pgId;

        String sPaymentMethodId = myProxy.tokenizePaymentMethod(tokenizeRequest);
        return sPaymentMethodId;
    }

    /**
     * @description This method is used to update the payment details in the cart
     * @param {String} cartId The cart id
     * @param {String} paymentMethodId The card payment method id
     * @param {String} paymentGroupId The payment group id
     * @return {void} This method will return nothing on success, it will throw an exception on failure
     */
    private static void updatePaymentDetailsInCart(String cartId, String paymentMethodId, String paymentGroupId) {
        List<Webcart> currentCart = [SELECT Id, PaymentMethodId, PaymentGroupId FROM Webcart WHERE Id = :cartId];
        if (currentCart.size() > 0) {
            currentCart[0].PaymentMethodId = paymentMethodId;
            currentCart[0].PaymentGroupId = paymentGroupId;
            update currentCart;
        }
    }

    /**
     * @description This method is used to update the CardPaymentMethod record with the details from the CyberSource response
     * @param {String} paymentMethodId - The card payment method id
     * @param {BWC_CybersourcePaymentRecord} paymentRecord - The CyberSource payment record
     * @return {void} This method will return nothing on success, it will throw an exception on failure
     *
     * NOTE: The following custom attributes are updated on the CardPaymentMethod object
        "ATTRIBUTE1": "6915650048926339804006", --> transaction_id (Label: Payment Transaction Id)
        "ATTRIBUTE2": "Axj/7wSTduXshtBvR6tmABsY4py58 YzhQ7U2UojmVxP 0BURzK4n/bpA3xCZKwyaSZYuvge5hAnJu3L2Q2g3o9WzAAA3gmB", --> request_token (Label: Payment Request Token)
        "ATTRIBUTE3": "2023-08-09T02:10:05.000Z", -- > TrxDateTime (date and time) (Label: Payment Transaction Date and Time)
        "PAYMENT_NUMBER": 1, --> (hardcoaded) (Label: Payment Number)
        "PAYMENT_AMOUNT": 77.13, --> auth_amount (Label: Payment Amount)
        "PAYMENT_TYPE_CODE": "CREDIT_CARD" --> (hardcoaded) (Label: Payment Type Code)
        "CREDIT_CARD_CODE": "UNKNOWN", --> (hardcoaded) (Label: Credit Card Code)
        "CREDIT_CARD_APPROVAL_CODE": "831000", --> auth_code (Label: Credit Card Approval Code)
        "CREDIT_CARD_APPROVAL_DATE": "2023-08-09T02:10:05", --> auth_time (Label: Credit Card Approval Date)
        "CREDIT_CARD_NUMBER": "9909000389822936", --> payment_token (Label: Credit Card Number)
        "CREDIT_CARD_EXPIRATION_DATE": "2023-11-30T19:00:00", --> req_card_expiry_date (Label: Credit Card Expiration Date)
        "CREDIT_CARD_HOLDER_NAME": "Test Test VISA 1111", --> req_bill_to_forename + req_bill_to_surname + req_card_type + req_card_number(last 4 digits) (Label: Credit Card Holder Name)
        "PAYMENT_COLLECTION_EVENT": "PREPAY", --> (hardcoaded) (Label: Payment Collection Event)
        "CONTEXT": 82, --> (hardcoaded) (Label: Context)
        "OPERATION": "CREATE", --> (hardcoaded) (Label: Operation)
     */
    private static void updatePaymentDetailsInCardPayment(String paymentMethodId, BWC_CybersourcePaymentRecord paymentRecord) {
        List<CardPaymentMethod> cpm = [SELECT Id FROM CardPaymentMethod WHERE Id = :paymentMethodId LIMIT 1];
        if (cpm.size() > 0) {
            cpm[0].ATTRIBUTE1__c = paymentRecord.transaction_id;
            cpm[0].ATTRIBUTE2__c = paymentRecord.request_token;
            cpm[0].ATTRIBUTE3__c = paymentRecord.signed_date_time;
            cpm[0].PAYMENT_NUMBER__c = '1';
            cpm[0].PAYMENT_AMOUNT__c = paymentRecord.auth_amount.toPlainString();
            cpm[0].PAYMENT_TYPE_CODE__c = 'CREDIT_CARD';
            cpm[0].CREDIT_CARD_CODE__c = 'UNKNOWN';
            cpm[0].CREDIT_CARD_APPROVAL_CODE__c = paymentRecord.auth_code;
            cpm[0].CREDIT_CARD_APPROVAL_DATE__c = paymentRecord.auth_time;
            cpm[0].CREDIT_CARD_NUMBER__c = paymentRecord.payment_token;
            cpm[0].CREDIT_CARD_EXPIRATION_DATE__c = paymentRecord.req_card_expiry_date;
            cpm[0].CREDIT_CARD_HOLDER_NAME__c = paymentRecord.req_bill_to_forename + ' ' + paymentRecord.req_bill_to_surname + ' ' + paymentRecord.card_type_name + ' ' + paymentRecord.req_card_number.right(4);
            cpm[0].PAYMENT_COLLECTION_EVENT__c = 'PREPAY';
            cpm[0].BWC_Payment_Provider__c='Cybersource';
            cpm[0].CONTEXT__c = '82';
            cpm[0].OPERATION__c = 'CREATE';
            update cpm;
        }
    }

    /**
     * @description This method is used to map the card name to the card type code
     * The values for the card name need to match up with the values from the picklist field CardPaymentMethod#CardType
     * @param {String} cardName The card name
     * @return {String} The card type code (ie VISA, MASTERCARD, etc)
     */
    private static String mapCardName(String cardName) {
        if (cardName == 'Visa') {
            return ConnectApi.CardType.VISA.name();
        } else if (cardName == 'Mastercard') {
            return 'Master Card';
        } else if (cardName == 'Amex') {
            return 'American Express';
        }
        return ConnectApi.CardType.VISA.name();
    }

    /**
     * @description This method is used to generate a unique id
     * @return {String} The unique id (ie a UUID)
     */
    private static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    /**
     * @description This method is used to get the current date and time in UTC format
     * @return {String} The current date and time in UTC format
     */
    private static String getUTCDateTime() {
        DateTime dt = Datetime.now();
        String strUTCDateTime = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return strUTCDateTime;
    }

    /**
     * @description Creates a cryptographic hash of the data
     * @param {String} data The data to sign
     * @param {String} secretKey The secret key
     * @return {String} The signed data
     */
    private static String sign(String data, String secretKey){
        String result = EncodingUtil.base64Encode(Crypto.generateMac('hmacSHA256', Blob.valueOf(data), Blob.valueOf(secretKey)));
        return result;
    }

    /**
     * @description This method is used to get the configuration values from the custom metadata type
     * @return {Map<String, String>} The configuration values from the custom metadata type
     */
    private static Map<String, String> getConfig() {
        BWC_PaymentGateWay_Configuration__mdt config = [SELECT Id, DeveloperName, reference_number_suffix__c, secret_key__c,
                                                                    merchant_defined_data1__c, merchant_defined_data2__c, merchant_defined_data3__c,
                                                                    merchant_defined_data4__c, access_key__c, profile_id__c, hosted_payment_page_url__c,
                                                                    iframe_url__c, override_custom_receipt_page__c, override_custom_cancel_page__c
                                                                    FROM BWC_PaymentGateWay_Configuration__mdt
                                                                    WHERE DeveloperName = 'cybersource'];
        Map<String, String> result = new Map<String, String>();
        result.put('merchant_defined_data1', nullValue(config?.merchant_defined_data1__c, ''));
        result.put('merchant_defined_data2', nullValue(config?.merchant_defined_data2__c, ''));
        result.put('merchant_defined_data3', nullValue(config?.merchant_defined_data3__c, ''));
        result.put('merchant_defined_data4', nullValue(config?.merchant_defined_data4__c, ''));
        result.put('reference_number_suffix', nullValue(config?.reference_number_suffix__c, ''));
        result.put('hosted_payment_page_url', nullValue(config?.hosted_payment_page_url__c, ''));
        result.put('iframe_url', nullValue(config?.iframe_url__c, ''));
        result.put('override_custom_receipt_page', nullValue(config?.override_custom_receipt_page__c, ''));
        result.put('override_custom_cancel_page', nullValue(config?.override_custom_cancel_page__c, ''));
        result.put('secret_key', nullValue(config?.secret_key__c, ''));
        result.put('access_key', nullValue(config?.access_key__c, ''));
        result.put('profile_id', nullValue(config?.profile_id__c, ''));
        System.debug('result = ' + result);
        return result;
    }

    /**
     * @description helper function that converts null values to an empty string
     * @param {String} s1 The first string
     * @param {String} s2 The second string
     * @return {String} The first string if not null, otherwise the second string
     */
    private static String nullValue(String s1, String s2) {
        return s1 == null ? s2 : s1;
    }
}
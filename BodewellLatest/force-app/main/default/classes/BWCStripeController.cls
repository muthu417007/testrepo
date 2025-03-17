public without sharing class BWCStripeController {
    private static final String LEVEL = 'Error';
    private static final String SOURCE_CLASS = 'BWCStripeController';
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
    
    public static String getSecretKey() {
        BWC_PaymentGateWay_Configuration__mdt config = [SELECT Id, DeveloperName, reference_number_suffix__c, secret_key__c,
                                                        merchant_defined_data1__c, merchant_defined_data2__c, merchant_defined_data3__c,
                                                        merchant_defined_data4__c, access_key__c, profile_id__c, hosted_payment_page_url__c,
                                                        iframe_url__c, override_custom_receipt_page__c, override_custom_cancel_page__c
                                                        FROM BWC_PaymentGateWay_Configuration__mdt
                                                        WHERE DeveloperName = 'BWC_Stripe'];
        return  config?.secret_key__c;
    }
    
    @AuraEnabled
    public static String createPaymentIntent(Double amount,String customerId,String cartId) {
        
        String apiKey = getSecretKey();
        // String apiKey='sk_test_51Oc7gvSAppYRkwGQNymdqEFBaLxmPN8SxoCRfV3ixVRrY5WB4p4WcsJSTvS5nRX9MVUoAiR3Rnu9D3Kovhf8fQxv00tbnRNTrL';
        String apiEndpoint = 'https://api.stripe.com/v1/payment_intents';
        // String apiEndpoint = 'https://api.stripe.com/v1/setup_intents';
        // payment_method_types=[affirm];
        // Decimal amountAffirm=9000;
        Long amountParse= toStripeCurrencyUnits('USD',amount);
        String currencyType='USD';
        String description='test Payment';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiEndpoint);
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        List<String> paymethods=new List<String>();
        //  paymethods.add('affirm');
        paymethods.add('card');
        // request.setBody('usage=off_session&payment_method_types[0]=affirm');
        
        request.setBody('amount=' + amountParse + '&capture_method=manual&currency=' + currencyType+'&description='+description+'&shipping[name]=Jenny Rosen&shipping[address][line1]=510 Townsend St&shipping[address][postal_code]=98140&shipping[address][city]=San Francisco&shipping[address][state]=CA&shipping[address][country]=US&customer='+customerId+'&payment_method_types[0]=card&payment_method_types[1]=affirm&metadata[orderNumber]='+cartId);
        HttpResponse response=new HttpResponse();
        Http http=new Http();
        response= http.send(request);
        system.debug('response==='+response.getBody());
        String result=response.getBody();
        //stripeJsonParser result =stripeJsonParser.parse(String.valueOf( JSON.deserializeUntyped(response.getBody()) ));
        // JSON2Apex result = JSON.deserialize(response.getBody(), JSON2Apex.class);
        return result ;
    }
    
   
    private static Long toStripeCurrencyUnits(String currencyIsoCodeLC, Double amount) {
        // see https://stripe.com/docs/currencies#zero-decimal
        //if (currencyIsoCodeLC.equals('usd')) {
        return Math.roundToLong(amount * 100); // TODO: make sure there are no rounding/precission issues
        // }
        
    }
    @AuraEnabled
    public static String createStripeCustomer(String accountID) {
        String customerId;
                    String accountIdreal=[Select Id, accountId from User where id=:accountId].accountId;
        Account account=[Select Id,Email__c,phone,BWC_Stripe_Customer_Id__c from account where id=:accountIdreal];

        ContactPointAddress accountShippingAddresses=[SELECT Id,Name ,BWC_Address_Line_2__c, Address, AddressType,BWC_Formatted_Address__c, Street, City, State, PostalCode, Country, IsDefault , ParentId FROM ContactPointAddress WHERE ParentId=:accountIdreal and AddressType='Shipping' and IsDefault=true  ORDER BY IsDefault DESC LIMIT 1  ] ;
        ContactPointAddress accountBillingAddresses=[SELECT Id,Name ,BWC_Address_Line_2__c, Address, AddressType,BWC_Formatted_Address__c, Street, City, State, PostalCode, Country, IsDefault , ParentId FROM ContactPointAddress WHERE ParentId=:accountIdreal and AddressType='Billing' and IsDefault=true  ORDER BY IsDefault DESC LIMIT 1  ] ;
        
        if(account.BWC_Stripe_Customer_Id__c==null)
        {
            
            String apiKey = getSecretKey();
            Map<String, String> requestBodyMap = new Map<String, String>();
            requestBodyMap.put('name', UserInfo.getuserName());
            requestBodyMap.put('email',UserInfo.getUserEmail());
            requestBodyMap.put('address[city]', accountBillingAddresses.City);
            requestBodyMap.put('address[country]',accountBillingAddresses.Country);
            requestBodyMap.put('address[line1]', accountBillingAddresses.Street);
            // requestBodyMap.put('address[line2]', accountBillingAddresses.BWC_Address_Line_2__c);
            requestBodyMap.put('address[postal_code]', accountBillingAddresses.PostalCode);
            requestBodyMap.put('address[state]', accountBillingAddresses.State);
            requestBodyMap.put('description', 'Bodewell Commercer Customer');
            requestBodyMap.put('phone', '123456789');
            
            
            
            String requestBody = ('');
            for (String key : requestBodyMap.keySet()) {
                String value = requestBodyMap.get(key);
                requestBody += key + '=' + EncodingUtil.urlEncode(value, 'UTF-8') + '&';
            }
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.stripe.com/v1/customers');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer '+apiKey);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(requestBody);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Process the response as needed
            if (res.getStatusCode() == 200) {
                system.debug('result===='+res.getbody());
                // Success
                customerWrapper customerWrapper = (customerWrapper) JSON.deserialize(res.getbody(), customerWrapper.class);
                customerId=customerWrapper.id;
                account.BWC_Stripe_Customer_Id__c=customerId;
                update account;
            } else {
                // Error handling
            } 
        }
        else
        {
            customerId=account.BWC_Stripe_Customer_Id__c;
        }
        return customerId;
    }
    public class fromJSON{
        public String id;	//cus_NffrFeUfNV2Hib
        public  fromJSON parse(String json){
            return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
        }
        
        
        
    }
    public class customerWrapper {
        
        public String id;
    }
    /**
* @description This method is used to authorize the payment using Cybersource
* @param {String} strPaymentRecord The payment record to authorize
* @return {void} This method will return nothing on success, it will throw an exception on failure
*/
    @AuraEnabled
    public static void authorizePayment(String cartId,String webstoreId,String userId,List<String> paymentIntentResult) {
        try {
            //  BWC_CybersourcePaymentRecord paymentRecord = BWC_CybersourcePaymentRecord.parse(strPaymentRecord);
            system.debug('authorizePayment start');
            //String webstoreId='0ZER00000008e09OAA';
            String accountId=[Select Id, accountId from User where id=:userId].accountId;
            ContactPointAddress cpa=[SELECT Id,Name , Address, AddressType, Street, City, State, PostalCode, Country, IsDefault , ParentId FROM ContactPointAddress WHERE ParentId=:accountId and AddressType='Billing' and IsDefault=true LIMIT 1  ] ;
            List<BWC_PaymentIntentWrapper> payIntent=new List<BWC_PaymentIntentWrapper>();
            for(String intent:paymentIntentResult)
            {
                system.debug('intent=='+intent);
                payIntent.add(BWC_PaymentIntentWrapper.parseIntent(intent ));
                
            }
            Map<String,PaymentMethodWrapper> methods=new Map<String,PaymentMethodWrapper>();
            for(BWC_PaymentIntentWrapper intent:payIntent)
            {
                String json= getPaymentMethod(intent.payment_method);
               // attachPaymentMethodToCustomer(accountId,intent.payment_method);
                PaymentMethodWrapper responseMethod=(PaymentMethodWrapper) System.JSON.deserialize(json, PaymentMethodWrapper.class); 
                methods.put(intent.payment_method,responseMethod);
            }
          
            for(BWC_PaymentIntentWrapper intent:payIntent)
            {
                ConnectApi.AuthorizationRequest request = new ConnectApi.AuthorizationRequest();
                String pgId = [SELECT Id, Integration FROM StoreIntegratedService WHERE ServiceProviderType = 'Payment' AND StoreId =:webstoreId LIMIT 1]?.Integration;
                system.debug('intent=='+intent);
                request.paymentGatewayId = pgId;
                request.amount =(intent.amount)/100;
                request.accountId =accountId;
                request.comments = 'AUTHORIZING '+intent.amount;
                request.currencyIsoCode ='USD';
                
                ConnectApi.PaymentGroupRequest paymentGroupRequest = new ConnectApi.PaymentGroupRequest();
                paymentGroupRequest.currencyIsoCode = 'USD';
                paymentGroupRequest.createPaymentGroup = true;
                
                request.paymentGroup = paymentGroupRequest;
                request.accountId = accountId;
                
                ConnectApi.AuthApiPaymentMethodRequest authApiPayMethodRequest = new ConnectApi.AuthApiPaymentMethodRequest();
                
                ConnectApi.AddressRequest addressRequest = new ConnectApi.AddressRequest();
                addressRequest.street =cpa.Street;
                addressRequest.city =cpa.City;
                addressRequest.state = cpa.State;
                addressRequest.postalCode =cpa.PostalCode;
                addressRequest.country =cpa.Country;
                system.debug('method=='+intent.payment_method);
                
                String sPaymentMethodId = getCardPaymentMethodId( addressRequest, pgId,accountId,methods.get(intent.payment_method),cpa.Name,intent);
                
                authApiPayMethodRequest.id = sPaymentMethodId;
                request.paymentMethod = authApiPayMethodRequest;
                ConnectApi.AuthorizationResponse response = myProxy.authorize(request);
                updatePaymentDetailsInCart(cartId, sPaymentMethodId, response?.paymentGroup?.id);
                
                updatePaymentDetailsInCardPayment(sPaymentMethodId,methods.get(intent.payment_method),intent,cpa.Name);
            }
            system.debug('authorizePayment end');
        } catch (Exception e) {
            CX_Logger logger = new CX_Logger();
            String sourceFunction = 'authorizePayment';
            logger.logMessage(LEVEL, SOURCE_CLASS, sourceFunction, e.getMessage(), null, null, null);
            system.debug(e.getMessage());
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
    private static String getCardPaymentMethodId(ConnectApi.AddressRequest addressRequest, String pgId,String accountId,PaymentMethodWrapper responseMethod,String name,BWC_PaymentIntentWrapper intent) {
        system.debug('getCardPaymentMethodId start');
        
        ConnectApi.CardPaymentMethodRequest cardPaymentMethodRequest = new ConnectApi.CardPaymentMethodRequest();
        cardPaymentMethodRequest.accountId =accountId;
        if(responseMethod.type=='affirm')
        {
                cardPaymentMethodRequest.cardNumber = String.valueOf(intent.created)+'1111';
        cardPaymentMethodRequest.expiryYear =2030;
        cardPaymentMethodRequest.expiryMonth = 12;
        cardPaymentMethodRequest.cardHolderName =  name+' visa 1111' ;
        
        cardPaymentMethodRequest.cardType = 'VISA';
        cardPaymentMethodRequest.cardCategory = ConnectApi.CardCategory.CreditCard;
        }
        else
        {
                cardPaymentMethodRequest.cardNumber = String.valueOf(intent.created)+responseMethod.card.last4 ;
        cardPaymentMethodRequest.expiryYear =responseMethod.card.exp_year;
        cardPaymentMethodRequest.expiryMonth = responseMethod.card.exp_month;
        cardPaymentMethodRequest.cardHolderName = name+' '+responseMethod.card.brand+' '+responseMethod.card.last4 ;
        
        cardPaymentMethodRequest.cardType = responseMethod.card.brand;
        ConnectApi.CardCategory cardCategory= getcardCategory(responseMethod.card.funding);
        cardPaymentMethodRequest.cardCategory = cardCategory; 
        }
   
        
        ConnectApi.PaymentMethodTokenizationRequest tokenizeRequest = new ConnectApi.PaymentMethodTokenizationRequest();
        tokenizeRequest.address = addressRequest;
        tokenizeRequest.cardPaymentMethod = cardPaymentMethodRequest;
        tokenizeRequest.paymentGatewayId = String.isBlank(pgId) ? '' : pgId;
        String sPaymentMethodId = myProxy.tokenizePaymentMethod(tokenizeRequest);
        system.debug('getCardPaymentMethodId end');
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
        system.debug('updatePaymentDetailsInCart start');
        List<Webcart> currentCart = [SELECT Id, PaymentMethodId, PaymentGroupId FROM Webcart WHERE Id = :cartId];
        if (currentCart.size() > 0) {
            currentCart[0].PaymentMethodId = paymentMethodId;
            currentCart[0].PaymentGroupId = paymentGroupId;
            update currentCart;
        }
        system.debug('updatePaymentDetailsInCart end');
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
    private static void updatePaymentDetailsInCardPayment(String paymentMethodId,PaymentMethodWrapper responseMethod,BWC_PaymentIntentWrapper intent,String name) {
        List<CardPaymentMethod> cpm = [SELECT Id FROM CardPaymentMethod WHERE Id = :paymentMethodId LIMIT 1];
        if (cpm.size() > 0) {
            cpm[0].ATTRIBUTE1__c = intent.id;
            cpm[0].ATTRIBUTE2__c =responseMethod.id;
            cpm[0].ATTRIBUTE3__c = getdateTimeFromStripe(intent.created);
            cpm[0].PAYMENT_NUMBER__c = '1';
            cpm[0].PAYMENT_AMOUNT__c = String.valueOf((intent.amount)/100);
            cpm[0].PAYMENT_TYPE_CODE__c =  'CREDIT_CARD';
            cpm[0].CREDIT_CARD_CODE__c = 'UNKNOWN';
            cpm[0].CREDIT_CARD_APPROVAL_CODE__c =intent.id;
            cpm[0].CREDIT_CARD_APPROVAL_DATE__c = getdateTimeFromStripeCard(intent.created);
             if(responseMethod.type=='affirm')
        {
               cpm[0].CREDIT_CARD_NUMBER__c =String.valueOf(intent.created)+'1111' ;
            cpm[0].CREDIT_CARD_EXPIRATION_DATE__c =  '12-2050';
            cpm[0].CREDIT_CARD_HOLDER_NAME__c =  name+' visa 1111' ;
             cpm[0].ATTRIBUTE4__c='visa';
             cpm[0].ATTRIBUTE5__c='1111';
        }
            else
            {
                  cpm[0].CREDIT_CARD_NUMBER__c =String.valueOf(intent.created)+responseMethod.card.last4 ;
            cpm[0].CREDIT_CARD_EXPIRATION_DATE__c =  responseMethod.card.exp_month+'-'+responseMethod.card.exp_year;
            cpm[0].CREDIT_CARD_HOLDER_NAME__c =  name+' '+responseMethod.card.brand+' '+responseMethod.card.last4 ;
             cpm[0].ATTRIBUTE4__c=responseMethod.card.brand;
             cpm[0].ATTRIBUTE5__c=responseMethod.card.last4 ; 
            }
         
            cpm[0].PAYMENT_COLLECTION_EVENT__c = 'PREPAY';
            
             cpm[0].BWC_Payment_Provider__c='Stripe';
            cpm[0].CONTEXT__c = '83';
            cpm[0].OPERATION__c = 'CREATE'; 
            update cpm;
        }
    }
    
    public static String getPaymentMethod(String paymentMethodId) {
        HttpRequest request = new HttpRequest();
        String apiKey = getSecretKey();
        request.setEndpoint('https://api.stripe.com/v1/payment_methods/' + paymentMethodId);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        // Set any required request headers
        
        // Authenticate the request if needed
        
        // Send the request and get the response
        HttpResponse response = new Http().send(request);
        
        String responseBody = response.getBody();
        system.debug('response=='+response.getBody());
        
        return response.getBody();
        
    }
    @AuraEnabled
    public static void attachPaymentMethodToCustomer(String accountId, String paymentMethodId) {
        try
        {
            String apiKey = getSecretKey();
            Account account=[Select Id,Email__c,phone,BWC_Stripe_Customer_Id__c from account where id=:accountId];
            
            String endpoint = 'https://api.stripe.com/v1/payment_methods/' + paymentMethodId + '/attach';
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + apiKey);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody('customer=' + account.BWC_Stripe_Customer_Id__c);
            
            HttpResponse response = new Http().send(request);
            system.debug(response.getBody());
            
        }
        
        catch(Exception e) {
            CX_Logger logger = new CX_Logger();
            String sourceFunction = 'attachPaymentMethodToCustomer';
            logger.logMessage(LEVEL, SOURCE_CLASS, sourceFunction, e.getMessage(), null, null, null);
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    public static ConnectApi.CardCategory getcardCategory(String funding) 
    {
        if(funding=='credit')
        {
            return ConnectApi.CardCategory.CreditCard;
        }
        else
        {
            return ConnectApi.CardCategory.DebitCard;
        }
        
    }
    public static String getdateTimeFromStripe(Integer created) 
    {
        
        Datetime createdDateTime = Datetime.newInstance(created * 1000L);
        
        // Convert DateTime object to a desired string format with timezone
        String formattedDateTime = createdDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
        
        System.debug(formattedDateTime); // Output: 2022-01-13 07:40:37
        return formattedDateTime;
    }
    public static String getdateTimeFromStripeCard(Integer created) 
    {
        
        Datetime createdDateTime = Datetime.newInstance(created * 1000L);
        
        // Convert DateTime object to a desired string format with timezone
        String formattedDateTime = createdDateTime.format('yyyy-MM-dd\'T\'HHmmss\'Z\'', 'GMT');
        
        System.debug(formattedDateTime); // Output: 2022-01-13 07:40:37
        return formattedDateTime;
    }
    
}
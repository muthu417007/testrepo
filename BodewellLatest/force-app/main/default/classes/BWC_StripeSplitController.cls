public without sharing class BWC_StripeSplitController {
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
    public static String createPaymentIntent(Double amount,String customerId,String cartId,String webstoreId) {
        
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
         HttpResponse response=new HttpResponse();
        Http http=new Http();
        String result;
                    String accId=[Select id,BWC_Stripe_Customer_Id__c from account where BWC_Stripe_Customer_Id__c=:customerId].id;
        ContactpointAddress cpa=[SELECT Id,Name,AddressFirstName,AddressLastName ,BWC_Formatted_Address__c, Address, AddressType, Street, City, State, PostalCode, Country, IsDefault , ParentId FROM ContactPointAddress WHERE ParentId=:accId and AddressType='Shipping' and IsDefault=true limit 1];
       

        // request.setBody('usage=off_session&payment_method_types[0]=affirm');
        if(amount>=50)
        {
                  request.setBody('amount=' + amountParse + '&capture_method=manual&currency=' + currencyType+'&description='+description+'&shipping[name]='+cpa.Name+'&shipping[address][line1]='+cpa.Street+'&shipping[address][postal_code]='+cpa.PostalCode+'&shipping[address][city]='+cpa.City+'&shipping[address][state]='+cpa.State+'&shipping[address][country]=US&customer='+customerId+'&payment_method_types[0]=card&payment_method_types[1]=affirm&metadata[cartId]='+cartId+'&metadata[webstoreId]='+webstoreId+'&metadata[source]=Bodewell Commerce');
  
        }
        else
        {
                  request.setBody('amount=' + amountParse + '&capture_method=manual&currency=' + currencyType+'&description='+description+'&shipping[name]='+cpa.Name+'&shipping[address][line1]='+cpa.Street+'&shipping[address][postal_code]='+cpa.PostalCode+'&shipping[address][city]='+cpa.City+'&shipping[address][state]='+cpa.State+'&shipping[address][country]=US&customer='+customerId+'&payment_method_types[0]=card&metadata[cartId]='+cartId+'&metadata[webstoreId]='+webstoreId+'&metadata[source]=Bodewell Commerce');

        }
        
        if(!test.isRunningTest())
        {
        response= http.send(request);
             system.debug('response==='+response.getBody());
         result=response.getBody();
        }
        else
        {
           result='[    {        "item": "GXSL55R",        "values": [            {                "shippingMethod": "Parts-FEDEX-Ground-1-7-Days",                "shippingRate": "7.95",                "shippingItem": "SMALL PACKAGE DELIVERY"            },            {                "shippingMethod": "Parts-FEDEX-2nd Day Air",                "shippingRate": "17.95",                "shippingItem": "SMALL PACKAGE DELIVERY"            },            {                "shippingMethod": "Parts-FEDEX-Priority-Overnight",                "shippingRate": "19.95",                "shippingItem": "SMALL PACKAGE DELIVERY"            }        ]    }]';
           
        }
        
       
        //stripeJsonParser result =stripeJsonParser.parse(String.valueOf( JSON.deserializeUntyped(response.getBody()) ));
        // JSON2Apex result = JSON.deserialize(response.getBody(), JSON2Apex.class);
        return result ;
    }
       @AuraEnabled
    public static String searchPaymentIntent(String cartId) {
      String cartStatus=[select id,name,status from webcart where id=:cartId].status;
        String apiKey = getSecretKey();
       String status='requires_capture';
        String encodedStatus = EncodingUtil.urlEncode(status, 'UTF-8');
String encodedCartId = EncodingUtil.urlEncode(cartId, 'UTF-8');
        String apiEndpoint = 'https://api.stripe.com/v1/payment_intents/search?query=metadata[\"cartId\"]:\"'+encodedCartId+'\"';
        //metadata[\"cartId\"]:\"'+cartId+'\"'+'and
      
   
     
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiEndpoint);
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       
       // request.setBody('metadata[orderNumber]='+orderSummaries[0].OriginalOrder.BWC_ORIG_SYS_DOCUMENT_REF__c);
           HttpResponse response=new HttpResponse();
        Http http=new Http();
         String result;
          if(!test.isRunningTest())
        {

        response= http.send(request);
          system.debug('response==='+response);
        system.debug('response==='+response.getBody());
         result=response.getBody();
        }
        else
        {
result='{"object":"search_result","url":"/v1/payment_intents/search","has_more":false,"data":[{"id":"pi_3MtwBwLkdIwHu7ix28a3tqPa","object":"payment_intent","amount":2000,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":{"enabled":true},"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","client_secret":"pi_3MtwBwLkdIwHu7ix28a3tqPa_secret_YrKJUKribcBjcG8HVhfZluoGH","confirmation_method":"automatic","created":1680800504,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"},"link":{"persistent_token":null}},"payment_method_types":["card","link"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}]}';
    }                    
        return result ;
    }
    
        @AuraEnabled
    public static List<String> updatePaymentIntent(List<String> intentArray,String orderNumber) {
        //    updatePaymentIntent({intentArray:this.paymentIntentResultArray,orderNumber:this.rid})
List<String> resultList=new List<String>();
         String apiKey = getSecretKey();
          String recId=orderNumber.trim();
                    List<OrderSummary> orderSummaries = [SELECT OriginalOrder.bwc_Order_Number__c,OriginalOrder.BWC_ORIG_SYS_DOCUMENT_REF__c FROM OrderSummary WHERE OrderNumber = :recId];
                    List<BWC_PaymentIntentWrapper> payIntent=new List<BWC_PaymentIntentWrapper>();
                    for(String intent:intentArray)
                    {
                        system.debug('intent=='+intent);
                        payIntent.add(BWC_PaymentIntentWrapper.parseIntent(intent ));
                        
                    }
                    for(BWC_PaymentIntentWrapper intent:payIntent)
                    {
       
       
        String apiEndpoint = 'https://api.stripe.com/v1/payment_intents/'+intent.id;
   
     
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiEndpoint);
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       
        request.setBody('metadata[orderNumber]='+orderSummaries[0].OriginalOrder.BWC_ORIG_SYS_DOCUMENT_REF__c);
           HttpResponse response=new HttpResponse();
        Http http=new Http();
                        String result;
            if(!test.isRunningTest())
        {              
        response= http.send(request);
        system.debug('response==='+response.getBody());
         result=response.getBody();
        resultList.add(result);
        }
                        else
                        {
                                String intent1='{"id":"pi_3MtwBwLkdIwHu7ix28a3tqPa","object":"payment_intent","amount":2000,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":{"enabled":true},"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","client_secret":"pi_3MtwBwLkdIwHu7ix28a3tqPa_secret_YrKJUKribcBjcG8HVhfZluoGH","confirmation_method":"automatic","created":1680800504,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"},"link":{"persistent_token":null}},"payment_method_types":["card","link"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';
resultList.add(intent1);
                        }
        //stripeJsonParser result =stripeJsonParser.parse(String.valueOf( JSON.deserializeUntyped(response.getBody()) ));
        // JSON2Apex result = JSON.deserialize(response.getBody(), JSON2Apex.class);
                    }
        return resultList ;
    }
    
      @AuraEnabled
    public static String updatePaymentIntentAmount(String intentId,Double amount) {
        //    updatePaymentIntent({intentArray:this.paymentIntentResultArray,orderNumber:this.rid})

          
              Long amountParse= toStripeCurrencyUnits('USD',amount);     
        String apiKey = getSecretKey();
       
        String apiEndpoint = 'https://api.stripe.com/v1/payment_intents/'+intentId;
   
     
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiEndpoint);
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
         if(amount>=50)
        {
        request.setBody('amount='+amountParse);
        }
        else
        {
             request.setBody('amount='+amountParse+'&payment_method_types[0]=card');
            //payment_method_types[0]=card&payment_method_types[1]=affirm
        }
           HttpResponse response=new HttpResponse();
        Http http=new Http();
         String result;
            if(!test.isRunningTest())
        {   
        response= http.send(request);
        system.debug('response==='+response.getBody());
         result=response.getBody();
        }
        else
        {
         result='{"id":"pi_3MtwBwLkdIwHu7ix28a3tqPa","object":"payment_intent","amount":2000,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":{"enabled":true},"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","client_secret":"pi_3MtwBwLkdIwHu7ix28a3tqPa_secret_YrKJUKribcBjcG8HVhfZluoGH","confirmation_method":"automatic","created":1680800504,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"},"link":{"persistent_token":null}},"payment_method_types":["card","link"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';

        }
      return result;
    }
    
    public static Long toStripeCurrencyUnits(String currencyIsoCodeLC, Double amount) {
        // see https://stripe.com/docs/currencies#zero-decimal
        //if (currencyIsoCodeLC.equals('usd')) {
        return Math.roundToLong(amount * 100); // TODO: make sure there are no rounding/precission issues
        // }
        
    }
    @AuraEnabled
      public static String getPaymentIntent(String paymentIntentId) {
        String endpoint = 'https://api.stripe.com/v1/payment_intents/' + paymentIntentId;
         String apiKey = getSecretKey();
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        
        Http http = new Http();
          String result;
              if(!test.isRunningTest())
        {    
        HttpResponse response = http.send(request);
        result=response.getBody();
        }
          else
          {
            result='{"id":"pi_3MtwBwLkdIwHu7ix28a3tqPa","object":"payment_intent","amount":2000,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":{"enabled":true},"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","client_secret":"pi_3MtwBwLkdIwHu7ix28a3tqPa_secret_YrKJUKribcBjcG8HVhfZluoGH","confirmation_method":"automatic","created":1680800504,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"},"link":{"persistent_token":null}},"payment_method_types":["card","link"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';
 
          }
    
          return result;
    }
    @AuraEnabled
    public static String createStripeCustomer(String accountID) {
        String customerId;
                    String accountIdreal=[Select Id, accountId from User where id=:accountID].accountId;
        Account account=[Select Id,Email__c,phone,BWC_Stripe_Customer_Id__c from account where id=:accountIdreal];

        //ContactPointAddress accountShippingAddresses=[SELECT Id,Name ,BWC_Address_Line_2__c, Address, AddressType,BWC_Formatted_Address__c, Street, City, State, PostalCode, Country, IsDefault , ParentId FROM ContactPointAddress WHERE ParentId=:accountIdreal and AddressType='Shipping' and IsDefault=true  ORDER BY IsDefault DESC LIMIT 1  ] ;
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
            String result;
         
            Http http = new Http();
               if(!test.isRunningTest())
        {  
                 HttpResponse res = http.send(req);
            result=res.getbody();
            }
          
            else
            {
                result='{"id":"cus_NffrFeUfNV2Hib","object":"customer","address":null,"balance":0,"created":1680893993,"currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"jennyrosen@example.com","invoice_prefix":"0759376C","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"Jenny Rosen","next_invoice_sequence":1,"phone":null,"preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}';
            }
            
        
                customerWrapper customerWrapper = (customerWrapper) JSON.deserialize(result, customerWrapper.class);
                customerId=customerWrapper.id;
                account.BWC_Stripe_Customer_Id__c=customerId;
                update account;
           
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
    public static List<String> authorizePayment(String cartId,String webstoreId,String userId,List<String> paymentIntentResult) {
        try {
            //  BWC_CybersourcePaymentRecord paymentRecord = BWC_CybersourcePaymentRecord.parse(strPaymentRecord);
            system.debug('authorizePayment start');
            //String webstoreId='0ZER00000008e09OAA';
            List<String> methodsIds=new List<String> ();
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
                                        Map<String,String> methodsAll=new Map<String,String>();
               
                
                
                ConnectApi.AddressRequest addressRequest = new ConnectApi.AddressRequest();
                addressRequest.street =cpa.Street;
                addressRequest.city =cpa.City;
                addressRequest.state = cpa.State;
                addressRequest.postalCode =cpa.PostalCode;
                addressRequest.country =cpa.Country;
             Map<String,ConnectApi.AuthorizationRequest>  requestMap = new Map<String,ConnectApi.AuthorizationRequest>(); 
            for(BWC_PaymentIntentWrapper intent:payIntent)
            {
                 ConnectApi.AuthorizationRequest request = new ConnectApi.AuthorizationRequest();
   
                ConnectApi.PaymentGroupRequest paymentGroupRequest = new ConnectApi.PaymentGroupRequest();
                paymentGroupRequest.currencyIsoCode = 'USD';
                paymentGroupRequest.createPaymentGroup = true;
                
                request.paymentGroup = paymentGroupRequest;
                request.accountId = accountId;
                String pgId = [SELECT Id, Integration FROM StoreIntegratedService WHERE ServiceProviderType = 'Payment' AND StoreId =:webstoreId LIMIT 1]?.Integration;
                system.debug('intent=='+intent);
                request.paymentGatewayId = pgId;
                request.amount =(intent.amount)/100;
                request.accountId =accountId;
                request.comments = 'AUTHORIZING '+intent.amount;
                request.currencyIsoCode ='USD';
             
              requestMap.put(intent.id,request);
                system.debug('addressRequest=='+addressRequest);
                                system.debug('addressRequest=='+addressRequest);
                system.debug('pgId=='+pgId);
                system.debug('accountId=='+accountId);
                system.debug('methods.get(intent.payment_method)=='+methods.get(intent.payment_method));
                system.debug('cpa.Name=='+cpa.Name);
system.debug('intent'+intent);
                String sPaymentMethodId = getCardPaymentMethodId( addressRequest, pgId,accountId,methods.get(intent.payment_method),cpa.Name,intent);
                system.debug('sPaymentMethodId'+sPaymentMethodId);
                methodsAll.put(intent.id,sPaymentMethodId);
                methodsIds.add(sPaymentMethodId);
          
            }
                        Map<String,String> methodsRes=new Map<String,String>();

               for(BWC_PaymentIntentWrapper intent:payIntent)
            {                 ConnectApi.AuthApiPaymentMethodRequest authApiPayMethodRequest = new ConnectApi.AuthApiPaymentMethodRequest();

                authApiPayMethodRequest.id = methodsAll.get(intent.id);
             ConnectApi.AuthorizationRequest request =  (requestMap.get(intent.id));
              request.paymentMethod = authApiPayMethodRequest;
                ConnectApi.AuthorizationResponse response = myProxy.authorize(request);
             system.debug('response==='+response);
             methodsRes.put(intent.id,response?.paymentGroup?.id);
            }
                for(BWC_PaymentIntentWrapper intent:payIntent)
            {                

                updatePaymentDetailsInCart(cartId, methodsAll.get(intent.id), methodsRes.get(intent.id));
                
                updatePaymentDetailsInCardPayment(methodsAll.get(intent.id),methods.get(intent.payment_method),intent,cpa.Name);
             
            }
                        system.debug('authorizePayment end');

            return methodsIds;
        } catch (Exception e) {
            CX_Logger logger = new CX_Logger();
            String sourceFunction = 'authorizePayment';
            //logger.logMessage(LEVEL, SOURCE_CLASS, sourceFunction, e.getMessage(), null, null, null);
            system.debug('error=='+e.getMessage()+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
       @AuraEnabled(Cacheable=true)
     public static Map<String, String> getOrderDeliveryPaymentSummary(String orderSummaryId)
    { 
        
        try {
                        Map<String, String> results = new Map<String, String>();

             system.debug('get order delivery payment summary'+orderSummaryId);
        String recId=orderSummaryId.trim();
      //  OrderSummary ordSummary = [select id, OrderNumber from OrderSummary where OrderNumber =:recId LIMIT 1];
      //  String orderNumber = ordSummary.OrderNumber;
        List<OrderPaymentSummary> ordPaymentSummary = [SELECT id,Method, OrderSummary.BillingStreet, OrderSummary.BillingCity,  
                             OrderSummary.BillingState, OrderSummary.BillingPostalCode ,OrderSummary.OrderNumber, ordersummary.OrderedDate ,OrderSummary.TotalAdjDistAMount,OrderSummary.BWC_Billing_Name__c,
                             OrderSummary.TotalAdjustedProductAmount,OrderSummary.TotalDeliveryAmount ,OrderSummary.BWC_Cart_Id__c, OrderSummary.TotalAdjustedDeliveryAmount ,OrderSummary.TotalTaxAmount ,OrderSummary.GrandTotalAmount
                             from OrderPaymentSummary 
                             where( OrderSummary.OrderNumber = :recId) LIMIT 1];
      
                     // return ordPaymentSummary;
                     results.put('email', UserInfo.getUserEmail());
            if (ordPaymentSummary.size() > 0) {
                
                results.put('paymentSummaryId', ordPaymentSummary[0].Id);
                
            }
            return results;
        } catch (Exception e) {
          //  CX_Logger logger = new CX_Logger();
          //  String sourceFunction = 'getOrderDeliveryPaymentSummary';
           // logger.logMessage(LEVEL, SOURCE_CLASS, sourceFunction, e.getMessage(), null, null, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
     
      @AuraEnabled
      public static List<PaymentAuthorization> getPaymentsOnOrderPaymentSummary(String ordRefNumber,List<String> methods) {
        List<PaymentAuthorization> payments=new List<PaymentAuthorization>();
   
          OrderPaymentSummary ordPaymentSummary = [SELECT id from OrderPaymentSummary where (id = :ordRefNumber) LIMIT 1];
             List<PaymentAuthorization> previousAuth=[SELECT id,PaymentMethodId,OrderPaymentSummaryId from PaymentAuthorization where OrderPaymentSummaryId=:ordPaymentSummary.id];
       
          for(String s:methods)
          {
              if(previousAuth[0].PaymentMethodId!=s)
              {
                   PaymentAuthorization pay=new PaymentAuthorization();
              pay.OrderPaymentSummaryId=ordPaymentSummary.id;
              pay.PaymentMethodId=s;
              pay.Status='Processed';
          //    pay.Type='Capture';
              pay.ProcessingMode='External';
              String amt=[SELECT Id, PAYMENT_AMOUNT__c FROM CardPaymentMethod where id=:s].PAYMENT_AMOUNT__c;
              pay.Amount=Decimal.valueOf(amt);
              payments.add(pay);
              }
       
          }
          insert payments;
          return payments;
      }
    /**
* @description This method is used to get the card payment method id
* @param {BWC_CybersourcePaymentRecord} paymentRecord The payment record to authorize
* @param {ConnectApi.AddressRequest} addressRequest The address request
* @param {String} pgId The payment gateway id
* @return {String} The card payment method id
* @throws {AuraHandledException} This method will throw an exception if the card payment method id cannot be retrieved
*/
    public static String getCardPaymentMethodId(ConnectApi.AddressRequest addressRequest, String pgId,String accountId,PaymentMethodWrapper responseMethod,String name,BWC_PaymentIntentWrapper intent) {
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
        if(responseMethod.card.brand=='mastercard')
        {
          cardPaymentMethodRequest.cardType = 'Master Card';   
        }
            else if(responseMethod.card.brand=='amex')
            {
               cardPaymentMethodRequest.cardType = 'American Express';
            }
             else if(responseMethod.card.brand=='discover')
            {
               cardPaymentMethodRequest.cardType = 'American Express';
                   system.debug('responseMethod.card.brand'+responseMethod.card.brand);
            }
             else if(responseMethod.card.brand=='diners')
            {
               cardPaymentMethodRequest.cardType = 'Diners Club';
                   system.debug('responseMethod.card.brand'+responseMethod.card.brand);
            }
            
            else 
            {
               cardPaymentMethodRequest.cardType = responseMethod.card.brand;
            }
     
       
      //  ConnectApi.CardCategory cardCategory= getcardCategory(responseMethod.card.funding);
        cardPaymentMethodRequest.cardCategory = ConnectApi.CardCategory.CreditCard;
            //cardCategory; 
        }
   
          system.debug('tokenizeRequest start');
        ConnectApi.PaymentMethodTokenizationRequest tokenizeRequest = new ConnectApi.PaymentMethodTokenizationRequest();
        tokenizeRequest.address = addressRequest;
        tokenizeRequest.cardPaymentMethod = cardPaymentMethodRequest;
        tokenizeRequest.paymentGatewayId = String.isBlank(pgId) ? '' : pgId;
          system.debug('tokenizeRequest tokenizePaymentMethod');
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
             cpm[0].ATTRIBUTE4__c='Affirm';
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
       @AuraEnabled
    public static String getPaymentMethod(String paymentMethodId) {
        HttpRequest request = new HttpRequest();
        String apiKey = getSecretKey();
        request.setEndpoint('https://api.stripe.com/v1/payment_methods/' + paymentMethodId);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        // Set any required request headers
        
        // Authenticate the request if needed
        
        // Send the request and get the response
        String result;
             if(!test.isRunningTest())
        {  
        HttpResponse response = new Http().send(request);
        
         result = response.getBody();
        system.debug('response=='+response.getBody());
        }
        else
        {
           result='{"id":"pm_1MqLiJLkdIwHu7ixUEgbFdYF","object":"payment_method","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":"unchecked"},"country":"US","exp_month":8,"exp_year":2026,"fingerprint":"mToisGZ01V71BCos","funding":"credit","generated_from":null,"last4":"4242","networks":{"available":["visa"],"preferred":null},"three_d_secure_usage":{"supported":true},"wallet":null},"created":1679945299,"customer":null,"livemode":false,"metadata":{},"type":"card"}';
            
        }
        return result;
        
    }
   /* @AuraEnabled
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
        
    }*/
  
    /*public static ConnectApi.CardCategory getcardCategory(String funding) 
    {
        if(funding=='credit')
        {
            return ConnectApi.CardCategory.CreditCard;
        }
        else
        {
            return ConnectApi.CardCategory.DebitCard;
        }
        
    }*/
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
           /*
* @description This method is called in OrderBodyCreater and Bwc_InvoiceTaxPayloadCreater class to add total amount into the payload.
* @param cartItemList - This parameter contains all the cartItems added into the cart.
* @return Double
*/
 /*   @AuraEnabled
    public static Double calculateTotalAmount(Id cartId){
        try{
            List<CartItem> cartItemList = [SELECT Id
                                          FROM CartItem
                                          WHERE CartId =:cartId];
            Double totalAmountService=0;
            Boolean isHD = false;
            Boolean isSDS = false;
            for(BWC_Product_Service__c productServiceRecord: [SELECT Id,
                                                              BWC_SKU__c,
                                                              BWC_Service_Price__c,
                                                              Cart_Item__r.Product2.BWC_Delivery_Type__c
                                                              FROM BWC_Product_Service__c
                                                              WHERE Cart_Item__c IN: cartItemList]){
                                                                  if(isHD != true && productServiceRecord.BWC_SKU__c == 'Home Delivery'){
                                                                      totalAmountService += productServiceRecord.BWC_Service_Price__c;
                                                                      isHD = true;
                                                                  }
                                                                  else if(productServiceRecord.BWC_SKU__c == 'Home Delivery' && isHD == true){
                                                                      continue;
                                                                  }
                                                                  else{
                                                                      totalAmountService += productServiceRecord.BWC_Service_Price__c;
                                                                  }
                                                                  // For Delivery oversize product
                                                                  if(productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c == 'sds' && isSDS != true){
                                                                      totalAmountService += 150;
                                                                      isSDS = true;
                                                                  }  
                                                                  // For Delivery oversize product
                                                              }
            if(totalAmountService==0)
            {
                     List<CartItem> cartItemList1 = [SELECT Id,product2.BWC_Delivery_Type__c
                                          FROM CartItem
                                          WHERE CartId =:cartId];
                for(CartItem ct:cartItemList1)
                {
                    if(ct.product2.BWC_Delivery_Type__c == 'hd')
                    {
                      totalAmountService=99;  
                    }
                }
            }
            return totalAmountService;
        }catch(Exception e){
            System.debug('Exception in Bwc_InvoiceTaxPayloadCreator-->'+e.getMessage()+'at line Number-->'+e.getLineNumber());
            return null;
        }
        
    }*/
    
}
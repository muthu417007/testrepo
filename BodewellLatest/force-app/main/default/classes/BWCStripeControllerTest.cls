@isTest
public class BWCStripeControllerTest {
    
    @testSetup static void setup() {
        
        Id p = [SELECT Id
                FROM Profile 	
                WHERE Name='Bodewell Commerce D2C Login User'].Id;
        
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        User userWithRole = new User(alias = 'hasrole', 
                                     email='userwithrole@roletest.com', 
                                     userroleid = r.id,
                                     emailencodingkey='UTF-8',
                                     lastname='Testing',
                                     languagelocalekey='en_US', 
                                     localesidkey='en_US',
                                     profileid = UserInfo.getProfileId(), 
                                     timezonesidkey='America/Los_Angeles',
                                     username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account ac;
        System.runAs(userWithRole){
            
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            ac= new Account(
                RecordTypeID=recordTypeId ,
                FirstName='Test FName',
                LastName='Test LName',
                PersonMailingStreet='test@yahoo.com',
                PersonMailingPostalCode='12345',
                PersonMailingCity='SFO',
                PersonEmail='test@yahoo.com',
                PersonHomePhone='1234567',
                PersonMobilePhone='12345678',
                EBS_X_PARTY_ID__pc='123',
                EBS_X_CUST_ACCOUNT_ID__pc='1234'
            );
            
            insert ac;
        }
        
        Account acc = [SELECT PersonContactId 
                       FROM Account 
                       WHERE Id = :ac.Id];
        
        
        User user = new User(alias = 'demo',
                             email='demo123@noemail.com',
                             emailencodingkey='UTF-8',
                             lastname='demo',
                             languagelocalekey='en_US',
                             localesidkey='en_US',
                             profileid = p,
                             country='United States',
                             IsActive =true,
                             ContactId = acc.PersonContactId,
                             timezonesidkey='America/Los_Angeles',
                             username='demo@noemail.com');
        insert user;
        
    }
    
    @isTest static void getSecretKeyTest(){
        String result = BWCStripeController.getSecretKey();
    }
    @isTest
    static void testCreatePaymentIntent() {
        String customerId = 'testCustomerId';
        String cartId = 'testCartId';
        Double amount = 1000.0;
        
        Test.setMock(HttpCalloutMock.class, new PaymentIntentHttpMock());
        
        Test.startTest();
        String result = BWCStripeController.createPaymentIntent(amount, customerId, cartId);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals('', result, 'Result should not be empty');
    }
    
    @isTest
    static void testCreateStripeCustomer() {
        
        User u = [SELECT Id,
                  AccountId
                  FROM User
                  WHERE alias = 'demo'
                  LIMIT 1];
        
        ContactPointAddress testShippingAddress = new ContactPointAddress(
            Name = 'Test Shipping Address',
            ParentId = u.AccountId,
            AddressType = 'Shipping',
            IsDefault = true,
            City = 'Test City',
            Country = 'Test Country',
            Street = 'Test Street',
            PostalCode = '12345',
            State = 'Test State'
        );
        insert testShippingAddress;
        
        ContactPointAddress testBillingAddress = new ContactPointAddress(
            Name = 'Test Billing Address',
            ParentId = u.AccountId,
            AddressType = 'Billing',
            IsDefault = true,
            City = 'Test City',
            Country = 'Test Country',
            Street = 'Test Street',
            PostalCode = '12345',
            State = 'Test State'
        );
        insert testBillingAddress;
        
        String accountId = u.Id;
        
        Test.setMock(HttpCalloutMock.class, new CreateStripeCustomerHttpMock());
        
        Test.startTest();
        String result = BWCStripeController.createStripeCustomer(accountId);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals('', result, 'Result should not be empty');
    }
    
    @isTest
    static void testAuthorizePayment() {
        User u = [SELECT Id,
                  AccountId
                  FROM User
                  WHERE alias = 'demo'
                  LIMIT 1];
        
        ContactPointAddress testBillingAddress = new ContactPointAddress(
            Name = 'Test Billing Address',
            ParentId = u.AccountId,
            AddressType = 'Billing',
            IsDefault = true,
            City = 'Test City',
            Country = 'Test Country',
            Street = 'Test Street',
            PostalCode = '12345',
            State = 'Test State'
        );
        insert testBillingAddress;
        
        List<String> paymentIntentResults = new List<String>();
        
        BWC_PaymentIntentWrapper intent1 = new BWC_PaymentIntentWrapper();
        intent1.id = '1';
        intent1.amount = 500;
        intent1.amount_capturable = 500;
        intent1.amount_received = 0;
        intent1.application = null;
        intent1.application_fee_amount = null;
        intent1.automatic_payment_methods = new BWC_PaymentIntentWrapper.AutomaticPaymentMethods();
        intent1.automatic_payment_methods.enabled = true;
        intent1.canceled_at = null;
        intent1.cancellation_reason = null;
        intent1.capture_method = 'automatic';
        intent1.client_secret = 'client_secret_1';
        intent1.confirmation_method = 'manual';
        intent1.created = 1647106860;
        intent1.customer = 'customer_id_1';
        intent1.description = 'Test Payment 1';
        intent1.invoice = null;
        intent1.last_payment_error = null;
        intent1.livemode = false;
        intent1.payment_method = 'payment_method_id_1';
        intent1.payment_method_types = new List<String>{'card'};
            intent1.status = 'requires_payment_method';
        
        String intent1Json = JSON.serialize(intent1);
        paymentIntentResults.add(intent1Json);
        
        BWC_PaymentIntentWrapper intent2 = new BWC_PaymentIntentWrapper();
        intent2.id = '2';
        intent2.amount = 700;
        intent2.amount_capturable = 700;
        intent2.amount_received = 0;
        intent2.application = null;
        intent2.application_fee_amount = null;
        intent2.automatic_payment_methods = new BWC_PaymentIntentWrapper.AutomaticPaymentMethods();
        intent2.automatic_payment_methods.enabled = true;
        intent2.canceled_at = null;
        intent2.cancellation_reason = null;
        intent2.capture_method = 'automatic';
        intent2.client_secret = 'client_secret_2';
        intent2.confirmation_method = 'manual';
        intent2.created = 1647106860;
        intent2.customer = 'customer_id_2';
        intent2.description = 'Test Payment 2';
        intent2.invoice = null;
        intent2.last_payment_error = null;
        intent2.livemode = false;
        intent2.payment_method = 'payment_method_id_2';
        intent2.payment_method_types = new List<String>{'card'};
            intent2.status = 'requires_payment_method';
        String intent2Json = JSON.serialize(intent2);
        paymentIntentResults.add(intent2Json);
        
        WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=u.AccountId);
        insert cart;
        
        String cartId = cart.Id;
        String webstoreId = webStore.Id;
        String userId = u.Id;
    	CardPaymentMethod cardPaymentMethod = new CardPaymentMethod(AccountId=u.AccountId, ProcessingMode='External', Status='Active');
        insert cardPaymentMethod;        
        Test.setMock(HttpCalloutMock.class, new AuthorizePaymentHttpMock());
        
        MockConnectApiProxy myProxy = new MockConnectApiProxy();
        myProxy.paymentMethodId = cardPaymentMethod.Id;
        BWCStripeController.myProxy = myProxy;
        
        Test.startTest();
        BWCStripeController.authorizePayment(cartId, webstoreId, userId, paymentIntentResults);
        Test.stopTest();

    }
    
    public class MockConnectApiProxy implements BWCStripeController.BWC_ConnectApiProxy {
        public Integer timesCalledAuth = 0;
        public Integer timesCalledTokenized = 0;
        public String paymentMethodId;
        public String tokenizePaymentMethod(ConnectApi.PaymentMethodTokenizationRequest tokenizeRequest) {
            timesCalledTokenized++;
            return paymentMethodId;
        }
        public ConnectApi.AuthorizationResponse authorize(ConnectApi.AuthorizationRequest request) {
            timesCalledAuth++;
            return null;
        }
    }
    
     @isTest static void testAttachPaymentMethodToCustomer() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Email__c = 'test@example.com',
            Phone = '1234567890',
            BWC_Stripe_Customer_Id__c = 'stripe_customer_id'
        );
        insert testAccount;

        String mockResponse = '{ "id": "pm_12345", "object": "payment_method", "customer": "cus_12345", "card": { "brand": "visa" }}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', mockResponse));

        Test.startTest();
        BWCStripeController.attachPaymentMethodToCustomer(testAccount.Id, 'pm_12345');
        Test.stopTest();

        Account updatedAccount = [SELECT Id, BWC_Stripe_Customer_Id__c FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals('stripe_customer_id', updatedAccount.BWC_Stripe_Customer_Id__c, 'Stripe Customer Id should remain unchanged');
    }
    
    @isTest
    public static void getcardCategoryTest(){
        Test.startTest();
        BWCStripeController.getcardCategory('credit');
        Test.stopTest();
    }
    
    @isTest
    public static void getcardCategoryTestElse(){
        Test.startTest();
        BWCStripeController.getcardCategory('non-credit');
        Test.stopTest();
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String status;
        private String body;

        MockHttpResponseGenerator(Integer statusCode, String status, String body) {
            this.statusCode = statusCode;
            this.status = status;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setStatus(status);
            res.setBody(body);
            return res;
        }
    }
    
    private class AuthorizePaymentHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"paymentGroup": {"id": "mockPaymentGroupId"},"type":"affirm"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    private class CreateStripeCustomerHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "mockCustomerId"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class PaymentIntentHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success", "message": "Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
}
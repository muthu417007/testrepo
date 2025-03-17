@IsTest(seeAllData=true)
public class BWC_StripeSplitControllerTest {
        public class MockConnectApiProxy implements BWC_StripeSplitController.BWC_ConnectApiProxy {
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
    
 
        
      @IsTest
    static void testgetSecretKey() {
       String params = BWC_StripeSplitController.getSecretKey();
      
    }
    
      @IsTest
    static void testCreatePaymentIntent() {
        //Double amount,String customerId,String cartId,String webstoreId
        Account account=new Account();
          account.BillingStreet = 'New York Street1';
        account.BillingCity = 'New York';
        account.BillingCountry = 'USA';
        account.BillingPostalCode = '234324';

        account.ShippingStreet = 'Candata Street';
        account.ShippingCity = 'Canada';
        account.ShippingCountry = 'Canada';
        account.ShippingPostalCode = '32432';
        account.Name = 'Buyer Account 1';
        account.AccountNumber = '500022996';
   
        account.BWC_Stripe_Customer_Id__c='stp_123456';

        insert account;
          ContactPointAddress cpa=new ContactPointAddress();
        
        cpa.Street='Address';
        cpa.AddressType='Shipping';
        
        cpa.State='Us';
        
        cpa.City='US';
        cpa.Country='US';
        cpa.PostalCode='40222';
        cpa.Name='Shubhada K';
        
        cpa.IsDefault=true;
        cpa.ParentId=account.Id;
        insert cpa;
         // Account account = [SELECT Id,BWC_Stripe_Customer_Id__c FROM Account WHERE Name = 'Buyer Account' LIMIT 1];
       String params = BWC_StripeSplitController.createPaymentIntent(500,account.BWC_Stripe_Customer_Id__c,'123412341234','w2345234');
      
    }

     
      @IsTest
    static void testsearchPaymentIntent() {
            Account account = new Account();
        Contact contact = new Contact();

        Test.startTest();
        User user = new User();
        BWC_TestDataFactory.returnSysAdminUser();
        Test.stopTest();
        user = [SELECT Id, Name, UserRoleId FROM User WHERE FirstName = 'Arellano' AND UserRoleId != NULL LIMIT 1];
        account.BillingStreet = 'New York Street';
        account.BillingCity = 'New York';
        account.BillingCountry = 'USA';
        account.BillingPostalCode = '234324';

        account.ShippingStreet = 'Candata Street';
        account.ShippingCity = 'Canada';
        account.ShippingCountry = 'Canada';
        account.ShippingPostalCode = '32432';
        account.Name = 'Buyer Account';
        account.AccountNumber = '50002299';
        account.ownerId = user.Id;
        account.BWC_Stripe_Customer_Id__c='stp_12345';

        insert account;
 
        contact = BWC_TestDataFactory.createContact(true, account.Id);
        User commerceUser = new User();
        commerceUser = BWC_TestDataFactory.createCommerceUser(contact.Id);

        WebStore webStore = new WebStore(Name = 'TestWebStore');
        insert webStore;
   
        WebCart cart = new WebCart(Name = 'Cart',status='Checkout', WebStoreId = webStore.Id, AccountId = account.Id);
        insert cart;
         // Account account = [SELECT Id,BWC_Stripe_Customer_Id__c FROM Account WHERE Name = 'Buyer Account' LIMIT 1];
       String params = BWC_StripeSplitController.searchPaymentIntent(cart.Id);
      
    }
    
    
        @IsTest
    static void testupdatePaymentIntentAmount() {
     
   // String intent='{"id":"pi_3MtwBwLkdIwHu7ix28a3tqPa","object":"payment_intent","amount":2000,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":{"enabled":true},"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","client_secret":"pi_3MtwBwLkdIwHu7ix28a3tqPa_secret_YrKJUKribcBjcG8HVhfZluoGH","confirmation_method":"automatic","created":1680800504,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"},"link":{"persistent_token":null}},"payment_method_types":["card","link"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';
      
         // Account account = [SELECT Id,BWC_Stripe_Customer_Id__c FROM Account WHERE Name = 'Buyer Account' LIMIT 1];
       String result = BWC_StripeSplitController.updatePaymentIntentAmount('pi_3MtwBwLkdIwHu7ix28a3tqPa',500);
      
    }
    
       
     @IsTest
    static void toStripeCurrencyUnitsTest() {
     
     long result = BWC_StripeSplitController.toStripeCurrencyUnits('usd',50);
      
    }

   @IsTest
    static void getPaymentIntentTest() {
     
     String result = BWC_StripeSplitController.getPaymentIntent('pi_3MtwBwLkdIwHu7ix28a3tqPa');
      
    }
        
     @IsTest
    static void testupdatePaymentIntent() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         
          Account acc= new Account(Name= 'Test Account');
        insert acc;
        Pricebook2 pb = [
            SELECT Id
            FROM Pricebook2
            WHERE isStandard = true
            LIMIT 1
        ];
        Order order = new Order(
            AccountId = acc.Id,
            OrderReferenceNumber = 'BDC00654321',
          //  BWC_ORIG_SYS_DOCUMENT_REF__c='BDC00654321',
            // SalesStoreId = cart.WebStoreId,
            // PoNumber = cart.PoNumber,
            // BillingStreet = cart.BillingStreet,
            // BillingCity = cart.BillingCity,
            // BillingState = cart.BillingState,
            // BillingPostalCode = cart.BillingPostalCode,
            // BillingCountry = cart.BillingCountry,
            // BillingLatitude = cart.BillingLatitude,
            // BillingLongitude = cart.BillingLongitude,
            Pricebook2Id = pb.Id,
            EffectiveDate = Date.today(),
            OrderedDate = Date.today(),
            Status = 'Draft'
        );
        insert(order);
        
       
        
        
        system.debug('order created ');
        OrderDeliveryMethod m = new OrderDeliveryMethod();
        m.Name = 'Test';
        insert m;
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
            Description = 'cartDeliveryGroup.Description',
            DesiredDeliveryDate = Date.today(),
            DeliverToName = 'cartDeliveryGroup.DeliverToName',
            DeliveryInstructions = 'cartDeliveryGroup.ShippingInstructions',
            // DeliverToStreet = cartDeliveryGroup.DeliverToStreet,
            // DeliverToCity = cartDeliveryGroup.DeliverToCity,
            // DeliverToState = cartDeliveryGroup.DeliverToState,
            // DeliverToPostalCode = cartDeliveryGroup.DeliverToPostalCode,
            // DeliverToCountry = cartDeliveryGroup.DeliverToCountry,
            // DeliverToLatitude = cartDeliveryGroup.DeliverToLatitude,
            // DeliverToLongitude = cartDeliveryGroup.DeliverToLongitude,
            OrderDeliveryMethodId = m.Id,
            OrderId = order.Id
        );
        insert orderDeliveryGroup;
        system.debug('order delivery method');
        Product2 prod = new Product2(name = 'Test',Item_Number__c='Order12345');
        insert prod;
        /*Pricebook2 pb = new Pricebook2(
Name = 'Example Price Book',
Description = 'This is the Price Book description.',
IsActive = true,
IsStandard = true
);
insert pb;*/
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = prod.Id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        OrderItem orderItem = new OrderItem(
            Product2Id = prod.Id,
            // Type = orderItemType,
            Quantity = 1,
            ListPrice = 1,
            UnitPrice = 1,
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            OrderDeliveryGroupId = orderDeliveryGroup.Id
            // TotalLineAmount = cartItem.TotalLineAmount
        );
        insert(orderItem);
        
        
        
        order.Status = 'Activated';
        update order;
        ConnectApi.OrderSummaryInputRepresentation osir = new
            ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId=order.Id; //replace this recordId with an appropriate value.
        osir.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor =
            ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        system.debug('osor==='+osor);
        OrderSummary ordSummary= [select id ,OrderNumber,OriginalOrder.BWC_ORIG_SYS_DOCUMENT_REF__c from OrderSummary LIMIT 1];
      
        
    String intent='{"id":"pi_3MtwBwLkdIwHu7ix28a3tqPa","object":"payment_intent","amount":2000,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":{"enabled":true},"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","client_secret":"pi_3MtwBwLkdIwHu7ix28a3tqPa_secret_YrKJUKribcBjcG8HVhfZluoGH","confirmation_method":"automatic","created":1680800504,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"},"link":{"persistent_token":null}},"payment_method_types":["card","link"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';
        List<String> intentArray=new List<String>();
        intentArray.add(intent);
         // Account account = [SELECT Id,BWC_Stripe_Customer_Id__c FROM Account WHERE Name = 'Buyer Account' LIMIT 1];
       List<String> result = BWC_StripeSplitController.updatePaymentIntent(intentArray,ordSummary.OrderNumber);
      
    }

    
          @IsTest
    static void testcreateStripeCustomer() {
          Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='Grazitti',BWC_Stripe_Customer_Id__c='test123') ;
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
         ContactPointAddress cpa=new ContactPointAddress();
        
        cpa.Street='Address';
        cpa.AddressType='Billing';
        
        cpa.State='Us';
        
        cpa.City='US';
        cpa.Country='US';
        cpa.PostalCode='40222';
        cpa.Name='Shubhada K';
        
        cpa.IsDefault=true;
        cpa.ParentId=ac.Id;
        insert cpa;
        
        Account ac1 = new Account(name ='Grazitti233') ;
        insert ac1; 
        
        Contact con1 = new Contact(LastName ='testCon1',AccountId = ac1.Id);
        insert con1;  
        
        User user1 = new User(alias = 'test12', email='test12323@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con1.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail123.com');
        
        insert user1;
         ContactPointAddress cpa1=new ContactPointAddress();
        
        cpa1.Street='Address';
        cpa1.AddressType='Billing';
        
        cpa1.State='Us';
        
        cpa1.City='US';
        cpa1.Country='US';
        cpa1.PostalCode='40229';
        cpa1.Name='Shubhada K t';
        
        cpa1.IsDefault=true;
        cpa1.ParentId=ac1.Id;
        insert cpa1;
         // Account account = [SELECT Id,BWC_Stripe_Customer_Id__c FROM Account WHERE Name = 'Buyer Account' LIMIT 1];
  
        
        Test.startTest();
     String params = BWC_StripeSplitController.createStripeCustomer(user.Id);
             String params1 = BWC_StripeSplitController.createStripeCustomer(user1.Id);

        Test.stopTest();
      
    }
    
     @isTest
    public static void getOrderDeliveryPaymentSummarytest()
    {
          User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         
          Account acc= new Account(Name= 'Test Account');
        insert acc;
        Pricebook2 pb = [
            SELECT Id
            FROM Pricebook2
            WHERE isStandard = true
            LIMIT 1
        ];
        Order order = new Order(
            AccountId = acc.Id,
            OrderReferenceNumber = 'BDC00654321',
            // SalesStoreId = cart.WebStoreId,
            // PoNumber = cart.PoNumber,
            // BillingStreet = cart.BillingStreet,
            // BillingCity = cart.BillingCity,
            // BillingState = cart.BillingState,
            // BillingPostalCode = cart.BillingPostalCode,
            // BillingCountry = cart.BillingCountry,
            // BillingLatitude = cart.BillingLatitude,
            // BillingLongitude = cart.BillingLongitude,
            Pricebook2Id = pb.Id,
            EffectiveDate = Date.today(),
            OrderedDate = Date.today(),
            Status = 'Draft'
        );
        insert(order);
        
       
        
        
        system.debug('order created ');
        OrderDeliveryMethod m = new OrderDeliveryMethod();
        m.Name = 'Test';
        insert m;
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
            Description = 'cartDeliveryGroup.Description',
            DesiredDeliveryDate = Date.today(),
            DeliverToName = 'cartDeliveryGroup.DeliverToName',
            DeliveryInstructions = 'cartDeliveryGroup.ShippingInstructions',
            // DeliverToStreet = cartDeliveryGroup.DeliverToStreet,
            // DeliverToCity = cartDeliveryGroup.DeliverToCity,
            // DeliverToState = cartDeliveryGroup.DeliverToState,
            // DeliverToPostalCode = cartDeliveryGroup.DeliverToPostalCode,
            // DeliverToCountry = cartDeliveryGroup.DeliverToCountry,
            // DeliverToLatitude = cartDeliveryGroup.DeliverToLatitude,
            // DeliverToLongitude = cartDeliveryGroup.DeliverToLongitude,
            OrderDeliveryMethodId = m.Id,
            OrderId = order.Id
        );
        insert orderDeliveryGroup;
        system.debug('order delivery method');
        Product2 prod = new Product2(name = 'Test',Item_Number__c='Order12345');
        insert prod;
        /*Pricebook2 pb = new Pricebook2(
Name = 'Example Price Book',
Description = 'This is the Price Book description.',
IsActive = true,
IsStandard = true
);
insert pb;*/
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = prod.Id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        OrderItem orderItem = new OrderItem(
            Product2Id = prod.Id,
            // Type = orderItemType,
            Quantity = 1,
            ListPrice = 1,
            UnitPrice = 1,
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            OrderDeliveryGroupId = orderDeliveryGroup.Id
            // TotalLineAmount = cartItem.TotalLineAmount
        );
        insert(orderItem);
        
        
        
        order.Status = 'Activated';
        update order;
        ConnectApi.OrderSummaryInputRepresentation osir = new
            ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId=order.Id; //replace this recordId with an appropriate value.
        osir.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor =
            ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        system.debug('osor==='+osor);
        OrderSummary ordSummary= [select id ,OrderNumber from OrderSummary LIMIT 1];
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=acc.Id, Status = 'Checkout');
        insert cart;
        
            CardPaymentMethod cmpInstance = new CardPaymentMethod(OPERATION__c='test',
                CONTEXT__c='82',
                CREDIT_CARD_APPROVAL_CODE__c='123',
                CREDIT_CARD_APPROVAL_DATE__c='123',
                CREDIT_CARD_CODE__c='1213',
                CREDIT_CARD_EXPIRATION_DATE__c='09-2029',
                CREDIT_CARD_HOLDER_NAME__c='test',
                CREDIT_CARD_NUMBER__c='567897654',
                PAYMENT_AMOUNT__c='344',
                PAYMENT_COLLECTION_EVENT__c='PREPAY',
                PAYMENT_NUMBER__c='1',
                ATTRIBUTE2__c='22',
                ATTRIBUTE3__c='324567',
                ATTRIBUTE1__c='dwfeerfe33',
                PAYMENT_TYPE_CODE__c='d12516',
                Status='Active',
                ProcessingMode='External'
              );
            //cmpInstance.CardPaymentMethodNumber = '123';
            
            insert cmpInstance;
        //SELECT Id, OrderSummaryId, PaymentMethodId, Type, FullName FROM OrderPaymentSummary
       
//       OrderPaymentSummary ordPaymentSummary=[SELECT id,Method from OrderPaymentSummary where( OrderSummaryId=:ordSummary.Id)];
           PaymentAuthorization pay=new PaymentAuthorization();
             // pay.OrderPaymentSummaryId=ordPaymentSummary.id;
              pay.PaymentMethodId=cmpInstance.Id;
              pay.Status='Processed';
          //    pay.Type='Capture';
              pay.ProcessingMode='External';
             // String amt=[SELECT Id, PAYMENT_AMOUNT__c FROM CardPaymentMethod where id=:s].PAYMENT_AMOUNT__c;
              pay.Amount=Decimal.valueOf('20');
            // insert pay;
             CardPaymentMethod cardPaymentMethod = new CardPaymentMethod(AccountId=acc.Id, ProcessingMode='External', Status='Active');
        insert cardPaymentMethod;
        List<String> method=new List<String>();
        method.add(cardPaymentMethod.Id);
        
         
         //   OrderPaymentSummary ordPaymentSummary = [SELECT id,Method, OrderSummary.BillingStreet, OrderSummary.BillingCity,  
//OrderSummary.BillingState, OrderSummary.BillingPostalCode ,OrderSummary.OrderNumber, ordersummary.OrderedDate ,OrderSummary.TotalAdjDistAMount,OrderSummary.BWC_Billing_Name__c,
///OrderSummary.TotalAdjustedProductAmount,OrderSummary.TotalDeliveryAmount ,OrderSummary.BWC_Cart_Id__c, OrderSummary.TotalAdjustedDeliveryAmount ,OrderSummary.TotalTaxAmount ,OrderSummary.GrandTotalAmount
                             //from OrderPaymentSummary 
                             //where( OrderSummary.OrderNumber = :ordSummary.orderNumber) LIMIT 1];
        test.startTest();
      MockConnectApiProxy myProxy = new MockConnectApiProxy();
        myProxy.paymentMethodId = cardPaymentMethod.Id;
        BWC_StripeSplitController.myProxy = myProxy;
        Map<String, String> paymentSummary=BWC_StripeSplitController.getOrderDeliveryPaymentSummary(ordSummary.orderNumber); 
        
    //    List<PaymentAuthorization> paymentAuths=BWC_StripeSplitController.getPaymentsOnOrderPaymentSummary(ordPaymentSummary.id,method); 
               
            test.stoptest();
        
    } 
    
     @IsTest
    static void testAuthorizePayment() {
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
                  Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;

        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
            
        User user1 = new User(alias = 'test12', email='test12323@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail123.com');
        
        insert user1;
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        WebCart cart = new WebCart(Name = 'Cart', WebStoreId = webStore.Id, AccountId = ac.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
        insert cartDeliveryGroup;  
        CartItem cartItem = new CartItem(
            CartId = cart.Id,
            Sku = 'SKU_Test1',
            SalesPrice = 10.00,
            Quantity = 3.0,
            Type = 'Product',
            Name = 'TestProduct',
            TotalPrice = 10.00,
            CartDeliveryGroupId = cartDeliveryGroup.Id
        );
        insert cartItem;

        CardPaymentMethod cardPaymentMethod = new CardPaymentMethod(AccountId=ac.Id, ProcessingMode='External', Status='Active');
        insert cardPaymentMethod;

        ContactPointAddress cpa = new ContactPointAddress();
		cpa.ParentId = ac.Id;
        cpa.AddressType = 'Billing';
        cpa.Street = '279  CEDARCREST DR';
        cpa.City = 'LEXINGTON ';
        cpa.State = 'SC';
        cpa.PostalCode = '29072';
        cpa.Country = 'United States';
        cpa.Name = 'ABC Billing';
        cpa.IsDefault=true;
        insert cpa;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
		update standardPricebook;

        Test.startTest();
        String strPaymentRecord = '{ "cartId": "' + cart.Id + '", "webstoreId": "' + webStore.Id + '", "accountId": "' + account.Id + '", "currencyIsoCode": "USD", "signed_date_time": "2023-09-21T22:28:58Z", "request_token": "Axj/7wSTePEpqGWxB487ABsY4c2KtObQg1bM6aojmiINSYBURzREGpNpA/gzGYEMmkmWLr4HuYQJybx4lNQy2IPHnYAAJjfC", "transaction_id": "6953353377506692403003", "auth_code": "831000", "auth_time": "2023-09-21T222858Z", "payment_token": "9909000391643114", "req_card_expiry_date": "09-2029", "req_bill_to_forename": "Non-Member Registered Owner", "req_bill_to_surname": "User", "req_bill_to_street": "781 Orphan Road", "req_bill_to_city": "Green Bay", "req_bill_to_state": "WI", "req_bill_to_postal_code": "54321", "req_bill_to_country": "US", "req_card_type": "001", "req_card_number": "xxxxxxxxxxxx1111", "auth_amount": "287.74", "cardNumber": "xxxxxxxxxxxx1111", "card_type_name": "Visa", "expiryYear": "2029", "expiryMonth": "09" }';

        MockConnectApiProxy myProxy = new MockConnectApiProxy();
        myProxy.paymentMethodId = cardPaymentMethod.Id;
        BWC_StripeSplitController.myProxy = myProxy;
        //String cartId,String webstoreId,String userId,List<String> paymentIntentResult
        List<string> intentArray=new List<String>();
        String affirmintent='{"id":"py_3OslYeBOkkWwHBP01JCnuXyV","object":"charge","livemode":false,"payment_intent":"pi_3OslYeBOkkWwHBP01BCVhmFk","status":"succeeded","amount":18250,"amount_captured":0,"amount_refunded":0,"application":null,"application_fee":null,"application_fee_amount":null,"balance_transaction":null,"billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"calculated_statement_descriptor":null,"captured":false,"created":1710074056,"currency":"usd","customer":"cus_Pew3A5W6QJgfkh","description":"test Payment","destination":null,"dispute":null,"disputed":false,"failure_balance_transaction":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":null,"metadata":{"cartId":"0a68B0000000HUaQAM","source":"Bodewell Commerce","webstoreId":"0ZE8B000000Gq4ZWAS"},"on_behalf_of":null,"order":null,"outcome":{"network_status":"approved_by_network","reason":null,"risk_level":"not_assessed","seller_message":"Payment complete.","type":"authorized"},"paid":true,"payment_method":"pm_1OslZ0BOkkWwHBP0pSPc1Qz3","payment_method_details":{"affirm":{},"type":"affirm"},"radar_options":{},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xTk9RcW9CT2trV3dIQlAwKMjRtq8GMgaxBV_T1Gw6LBYaO6oolc-JyPR8qyOIp3Pqp-JjXkrkqjYJxqamngDceNXMCfO0rA36yQnl","refunded":false,"review":null,"shipping":{"address":{"city":"Ashland","country":"US","line1":"Lake Side","line2":null,"postal_code":"41114","state":"KY"},"carrier":null,"name":"Shubhada K","phone":null,"tracking_number":null},"source":null,"source_transfer":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"transfer_data":null,"transfer_group":null}';
        string intent='{"id":"pi_3MtweELkdIwHu7ix0Dt0gF2H","object":"payment_intent","amount":2000,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":2000,"application":null,"application_fee_amount":null,"automatic_payment_methods":{"enabled":true},"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","client_secret":"pi_3MtweELkdIwHu7ix0Dt0gF2H_secret_ALlpPMIZse0ac8YzPxkMkFgGC","confirmation_method":"automatic","created":1680802258,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":"ch_3MtweELkdIwHu7ix05lnLAFd","livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":"pm_1MtweELkdIwHu7ixxrsejPtG","payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"},"link":{"persistent_token":null}},"payment_method_types":["card","link"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}';
      intentArray.add(intent);
       intentArray.add(affirmintent);
        List<String> result= BWC_StripeSplitController.authorizePayment(cart.id,webStore.id,user1.id,intentArray);
        Test.stopTest();

        Assert.areEqual(2, myProxy.timesCalledTokenized, 'Success');
        Assert.areEqual(2, myProxy.timesCalledAuth, 'Success');
    }
    
        
     @IsTest
    static void testgetCardPaymentMethodIdTest() {
     Account ac = new Account(name ='Grazitti') ;
        insert ac; 
                  Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;

        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
            
        User user1 = new User(alias = 'test12', email='test12323@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail123.com');
        
        insert user1;
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        WebCart cart = new WebCart(Name = 'Cart', WebStoreId = webStore.Id, AccountId = ac.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
        insert cartDeliveryGroup;  
        CartItem cartItem = new CartItem(
            CartId = cart.Id,
            Sku = 'SKU_Test1',
            SalesPrice = 10.00,
            Quantity = 3.0,
            Type = 'Product',
            Name = 'TestProduct',
            TotalPrice = 10.00,
            CartDeliveryGroupId = cartDeliveryGroup.Id
        );
        insert cartItem;

        CardPaymentMethod cardPaymentMethod = new CardPaymentMethod(AccountId=ac.Id, ProcessingMode='External', Status='Active');
        insert cardPaymentMethod;

              MockConnectApiProxy myProxy = new MockConnectApiProxy();
        myProxy.paymentMethodId = cardPaymentMethod.Id;
        BWC_StripeSplitController.myProxy = myProxy;
           ConnectApi.AddressRequest addressRequest = new ConnectApi.AddressRequest();
                addressRequest.street ='test';
                addressRequest.city ='US';
                addressRequest.state = 'Us';
                addressRequest.postalCode ='40222';
                addressRequest.country ='US';
        
                          String resultMastercard='{"id":"pm_1MqLiJLkdIwHu7ixUEgbFdYF","object":"payment_method","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"card":{"brand":"mastercard","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":"unchecked"},"country":"US","exp_month":8,"exp_year":2026,"fingerprint":"mToisGZ01V71BCos","funding":"credit","generated_from":null,"last4":"4242","networks":{"available":["visa"],"preferred":null},"three_d_secure_usage":{"supported":true},"wallet":null},"created":1679945299,"customer":null,"livemode":false,"metadata":{},"type":"card"}';
                                String intent1='{"id":"pi_3MtwBwLkdIwHu7ix28a3tqPa","object":"payment_intent","amount":2000,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":{"enabled":true},"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","client_secret":"pi_3MtwBwLkdIwHu7ix28a3tqPa_secret_YrKJUKribcBjcG8HVhfZluoGH","confirmation_method":"automatic","created":1680800504,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_options":{"card":{"installments":null,"mandate_options":null,"network":null,"request_three_d_secure":"automatic"},"link":{"persistent_token":null}},"payment_method_types":["card","link"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';
BWC_PaymentIntentWrapper intentwrapper=BWC_PaymentIntentWrapper.parseIntent(intent1 );
     PaymentMethodWrapper responseMethod=(PaymentMethodWrapper) System.JSON.deserialize(resultMastercard, PaymentMethodWrapper.class); 
        String affirmre='{"id":"pm_1OslZ0BOkkWwHBP0pSPc1Qz3","object":"payment_method","affirm":{},"billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"created":1710073994,"customer":null,"livemode":false,"metadata":{},"type":"affirm"}';
             PaymentMethodWrapper responseMethodaffirm=(PaymentMethodWrapper) System.JSON.deserialize(affirmre, PaymentMethodWrapper.class); 
         
        String resultBasic='{"id":"pm_1MqLiJLkdIwHu7ixUEgbFdYF","object":"payment_method","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":null,"state":null},"email":null,"name":null,"phone":null},"card":{"brand":"visa","checks":{"address_line1_check":null,"address_postal_code_check":null,"cvc_check":"unchecked"},"country":"US","exp_month":8,"exp_year":2026,"fingerprint":"mToisGZ01V71BCos","funding":"credit","generated_from":null,"last4":"4242","networks":{"available":["visa"],"preferred":null},"three_d_secure_usage":{"supported":true},"wallet":null},"created":1679945299,"customer":null,"livemode":false,"metadata":{},"type":"card"}';
 String result=BWC_StripeSplitController.getCardPaymentMethodId(addressRequest,'',ac.id,responseMethod,'test123',intentwrapper);
         String result1=BWC_StripeSplitController.getCardPaymentMethodId(addressRequest,'',ac.id,responseMethodaffirm,'test123',intentwrapper);

    }


}
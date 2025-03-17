@SuppressWarnings('PMD')

@IsTest
public class BWC_CybersourceControllerTest {

    public class MockConnectApiProxy implements BWC_CybersourceController.BWC_ConnectApiProxy {
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

    /**
     * @description test setup for creating data
     */
    @TestSetup
    public static void createCustomerUser() {
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

        insert account;

        contact = BWC_TestDataFactory.createContact(true, account.Id);
        User commerceUser = new User();
        commerceUser = BWC_TestDataFactory.createCommerceUser(contact.Id);

        WebStore webStore = new WebStore(Name = 'TestWebStore');
        insert webStore;
        addStoreIntegratedService(webStore);
    }

     /**
     * @description addStoreIntegratedService Setup code that creates a non-functional store integrated service
     * @param webStore
     */
    public static void addStoreIntegratedService(WebStore webStore) {
        // Any named credential should do for the purposes of tests that don't 100% complete
        NamedCredential namedCredential = [SELECT Id FROM NamedCredential LIMIT 1];

        // This provider should be installed while running the SFDX installation that this test is associated with
        PaymentGatewayProvider paymentGatewayProvider = [SELECT Id FROM PaymentGatewayProvider WHERE DeveloperName='BWC_CybersourceHPP' LIMIT 1];

        PaymentGateway paymentGateway = new PaymentGateway(PaymentGatewayName='PGN', MerchantCredentialId=namedCredential.Id,
                                                           PaymentGatewayProviderId=paymentGatewayProvider.Id, Status='Active');
        insert paymentGateway;

        StoreIntegratedService newStoreIntegratedService = new StoreIntegratedService(Integration=paymentGateway.Id,
                                                                                      ServiceProviderType='Payment', StoreId=webStore.Id);
        insert newStoreIntegratedService;
    }

    @IsTest
    static void testGetParameters() {
        Account acct = new Account(Name = 'TestAccount');
        insert acct;

        ContactPointAddress cpa = new ContactPointAddress(
            Name = 'Billing Address',
            ParentId = acct.id,
            Street = 'street',
            City = 'city',
            State = 'state',
            Country = 'country',
            PostalCode = 'postalcode',
            IsDefault = true,
            AddressType = 'Billing'
        );
        insert cpa;

        String cartSummary = '{ "asyncOperationStatus": null, "cartId": "0a68B00000009Z6QAI", "currencyIsoCode": "USD", "grandTotalAmount": "252.00", "isSecondary": false, "messagesSummary": { "errorCount": 0, "hasErrors": false, "limitedMessages": [], "relatedEntityId": "0a68B00000009Z6QAI", "totalLineItemsWithErrors": 0 }, "name": "Cart", "orderOwnerId": null, "ownerId": "0058B000002hPUDQA2", "purchaseOrderNumber": null, "status": "Checkout", "taxType": "Net", "totalChargeAmount": "0.00", "totalListPrice": "0.00", "totalProductAmount": "380.00", "totalProductAmountAfterAdjustments": "252.00", "totalProductCount": "1.0", "totalProductListAmount": "0.00", "totalPromotionalAdjustmentAmount": "-128.00", "totalTaxAmount": "0.00", "type": "Cart", "uniqueProductCount": 1, "webstoreId": "0ZE8B000000Gq4ZWAS" }';
        Map<String, String> params = BWC_CybersourceController.getParameters(acct.id, cartSummary);
        Assert.areNotEqual(null, params, 'Success');
    }
      @IsTest
    static void testGetOrderInfo() {
        Map<String, String> params = BWC_CybersourceController.getOrderInfo('12341234');
        Assert.areNotEqual(null, params, 'Success');
    }

    @IsTest
    static void testAuthorizePayment() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Buyer Account' LIMIT 1];
        WebStore webStore = [Select Id from WebStore WHERE Name = 'TestWebStore'];
        WebCart cart = new WebCart(Name = 'Cart', WebStoreId = webStore.Id, AccountId = account.Id);
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

        CardPaymentMethod cardPaymentMethod = new CardPaymentMethod(AccountId=account.Id, ProcessingMode='External', Status='Active');
        insert cardPaymentMethod;

        ContactPointAddress cpa = new ContactPointAddress();
		cpa.ParentId = account.Id;
        cpa.AddressType = 'Shipping';
        cpa.Street = '279  CEDARCREST DR';
        cpa.City = 'LEXINGTON ';
        cpa.State = 'SC';
        cpa.PostalCode = '29072';
        cpa.Country = 'United States';
        cpa.Name = 'ABC Billing';
        insert cpa;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
		update standardPricebook;

        Test.startTest();
        String strPaymentRecord = '{ "cartId": "' + cart.Id + '", "webstoreId": "' + webStore.Id + '", "accountId": "' + account.Id + '", "currencyIsoCode": "USD", "signed_date_time": "2023-09-21T22:28:58Z", "request_token": "Axj/7wSTePEpqGWxB487ABsY4c2KtObQg1bM6aojmiINSYBURzREGpNpA/gzGYEMmkmWLr4HuYQJybx4lNQy2IPHnYAAJjfC", "transaction_id": "6953353377506692403003", "auth_code": "831000", "auth_time": "2023-09-21T222858Z", "payment_token": "9909000391643114", "req_card_expiry_date": "09-2029", "req_bill_to_forename": "Non-Member Registered Owner", "req_bill_to_surname": "User", "req_bill_to_street": "781 Orphan Road", "req_bill_to_city": "Green Bay", "req_bill_to_state": "WI", "req_bill_to_postal_code": "54321", "req_bill_to_country": "US", "req_card_type": "001", "req_card_number": "xxxxxxxxxxxx1111", "auth_amount": "287.74", "cardNumber": "xxxxxxxxxxxx1111", "card_type_name": "Visa", "expiryYear": "2029", "expiryMonth": "09" }';

        MockConnectApiProxy myProxy = new MockConnectApiProxy();
        myProxy.paymentMethodId = cardPaymentMethod.Id;
        BWC_CybersourceController.myProxy = myProxy;
        BWC_CybersourceController.authorizePayment(strPaymentRecord);
        Test.stopTest();

        Assert.areEqual(1, myProxy.timesCalledTokenized, 'Success');
        Assert.areEqual(1, myProxy.timesCalledAuth, 'Success');
    }
}
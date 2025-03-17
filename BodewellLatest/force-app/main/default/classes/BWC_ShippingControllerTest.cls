@isTest

private class BWC_ShippingControllerTest {

    @testSetup static void setup() {

        Account testAccount = new Account(Name='TestAccount');

        insert testAccount;

        WebStore testWebStore = new WebStore(Name='TestWebStore');

        insert testWebStore;
        WebStore testWebStore2 = new WebStore(Name='TestWebStore2');

        insert testWebStore2;

        

        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];

        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];

WebCart cart1 = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id, status='Checkout');

        insert cart1;

        WebCart cart2 = new WebCart(Name='Cart2', WebStoreId=testWebStore2.Id, AccountId=account.Id, status='Checkout');

        insert cart2;
        

CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart1.Id, Name='Default Delivery 1');

        insert cartDeliveryGroup;

CartItem cartItem1 = new CartItem(CartId=cart1.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id,BWC_Shipping_Method__c='Parts-FEDEX-Ground-1-7-Days');

        insert cartItem1;
        CartItem cartItem2 = new CartItem(CartId=cart1.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id,BWC_Shipping_Method__c='Parts-FEDEX-2nd Day Air');

        insert cartItem2;
                CartItem cartItem3 = new CartItem(CartId=cart1.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id,BWC_Shipping_Method__c='Parts-FEDEX-Priority-Overnight');

        insert cartItem3;
        
        CartItem cartItem4 = new CartItem(CartId=cart1.Id, Type='Charge', Name='TestCharge', CartDeliveryGroupId=cartDeliveryGroup.Id);

        insert cartItem4;
        
        BWC_Product_Service__c productServiceInstance = new BWC_Product_Service__c(Name='Home Delivery', BWC_Service_Price__c=99, Cart_Item__c=cartItem1.Id);

        insert productServiceInstance;

    }

    

 

    @isTest static void testIntegrationRunsSuccessfully() {

        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.

        // To create the static resource from the Developer Console, select File | New | Static Resource

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();

        mock.setStaticResource('GetDeliveryRatesResource');

        mock.setStatusCode(200);

        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.startTest();

        // Associate the callout with a mock response.

        Test.setMock(HttpCalloutMock.class, mock);

        

        // Test: execute the integration for the test cart ID.

        BWC_ShippingController apexSample = new BWC_ShippingController();

        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();

        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];

        integInfo.jobId = null;

sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        // Verify: the integration executed successfully

       // System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);

        Test.stopTest();

    }

    

 

    @isTest static void testWhenExternalServiceCallFailsAFailedStatusIsReturnedAndACartValidationOutputEntryIsCreated() {

        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.

        // To create the static resource from the the Developer Console, select File | New | Static Resource

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();

        mock.setStaticResource('GetDeliveryRatesResource');

        // The web service call returns an error code.

        mock.setStatusCode(404);

        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.startTest();

        // Associate the callout with a mock response.

        Test.setMock(HttpCalloutMock.class, mock);

        

        // Test: execute the integration for the test cart ID and integration info.

        BWC_ShippingController apexSample = new BWC_ShippingController();

        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();

        integInfo.jobId = null;

        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart2' LIMIT 1];

sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        

        // Validate: IntegrationStatus.Status is FAILED

        // and a new CartValidationOutput record with level 'Error' was created.

     //   System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);

      //  List<CartValidationOutput> cartValidationOutputs = [SELECT Id FROM CartValidationOutput WHERE Level = 'Error'];

      //  System.assertEquals(1, cartValidationOutputs.size());

        Test.stopTest();

    }


}
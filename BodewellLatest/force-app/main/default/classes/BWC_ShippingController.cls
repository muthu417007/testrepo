// This must implement the sfdc_checkout.CartShippingCharges interface
// in order to be processed by the checkout flow for the "Shipping" integration
global with sharing class BWC_ShippingController implements sfdc_checkout.CartShippingCharges {
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        
        try {
            // We need to get the ID of the cart delivery group in order to create the order delivery groups.
            Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId WITH SECURITY_ENFORCED][0].Id;
            
            // Used to increase the cost by a multiple of the number of items in the cart (useful for testing but should not be done in the final code)
            Integer numberOfUniqueItems = [SELECT count() from cartItem WHERE CartId = :cartId WITH SECURITY_ENFORCED];
            
            // Get shipping options, including aspects like rates and carriers, from the external service. 
            ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService = getShippingOptionsAndRatesFromExternalService(numberOfUniqueItems);
            
            // On re-entry of the checkout flow delete all previous CartDeliveryGroupMethods for the given cartDeliveryGroupId
            delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId WITH SECURITY_ENFORCED];
            
            // Create orderDeliveryMethods given your shipping options or fetch existing ones. 2 should be returned.
            List<Id> orderDeliveryMethodIds = getOrderDeliveryMethods(shippingOptionsAndRatesFromExternalService);
            
            // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
            Integer i = 0;
            OrderDeliveryMethod omdd = [SELECT Id,ProductId FROM OrderDeliveryMethod WHERE Id = :orderDeliveryMethodIds[0]];
            System.debug('omdd-->'+omdd.ProductId);
            for (Id orderDeliveryMethodId: orderDeliveryMethodIds) {
                populateCartDeliveryGroupMethodWithShippingOptions(shippingOptionsAndRatesFromExternalService[i],
                                                                   cartDeliveryGroupId,
                                                                   orderDeliveryMethodId,
                                                                   cartId);
                i+=1;
            }
            System.debug('loop count-->'+i);
            // If everything works well, the charge is added to the cart and our integration has been successfully completed.
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
            
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
        } catch (DmlException de) {
            // Catch any exceptions thrown when trying to insert the shipping charge to the CartItems
            Integer numErrors = de.getNumDml();
            String errorMessage = 'There were ' + numErrors + ' errors when trying to insert the charge in the CartItem: ';
            for(Integer errorIdx = 0; errorIdx < numErrors; errorIdx++) {
                errorMessage += 'Field Names = ' + de.getDmlFieldNames(errorIdx);
                errorMessage += 'Message = ' + de.getDmlMessage(errorIdx);
                errorMessage += ' , ';
            }
            
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                errorMessage,
                jobInfo,
                cartId
            );
        } catch(Exception e) {
            System.debug('Exception message-->'+e.getMessage());
            System.debug('Exception line-->'+e.getLineNumber());
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        return integStatus;
    }
    
    private ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromExternalService (Integer numberOfUniqueItems) {
        
        /*  //shipping method
String jsonString = '{"zipcode": "58801","state":"ND"}';
String responseBody = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_DEV_Token','Sandbox_CommerceCloudWarehouse_DEV',null,'POST',jsonString);
BWC_ShippingResponseWrapper responseWrapper = (BWC_ShippingResponseWrapper) JSON.deserialize(responseBody, BWC_ShippingResponseWrapper.class);
// Access deserialized data
List<BWC_ShippingResponseWrapper.AgentClass> agents = responseWrapper.agents;



// Debug the agents
System.debug(agents);
ShippingOptionsAndRatesFromExternalService[] shippingOptions1 = new List<ShippingOptionsAndRatesFromExternalService>();
/*shippingOptions1.name = 'test';
shippingOptions1.provider = 'test';
shippingOptions1.rate = 1;
shippingOptions1.otherCost = 2;
shippingOptions1.serviceName = 'test';



for (Integer count = 0 ;count < responseWrapper.agents.size() ; count++) { 
String deliverMethodName;
if(responseWrapper.agents[count].method == ''){
deliverMethodName = 'Delivey';
}
else{
deliverMethodName = responseWrapper.agents[count].method;
}
shippingOptions1.add( new ShippingOptionsAndRatesFromExternalService(deliverMethodName,
responseWrapper.agents[count].agent_id,
10,
25,
responseWrapper.agents[count].name));
}
return shippingOptions1;*/
        //shipping method
        
        
        final Integer SuccessfulHttpRequest = 200;
        final String groundOneToSevenDays = 'Parts-FEDEX-Ground-1-7-Days';
        final String fedexSecondDayAir = 'Parts-FEDEX-2nd Day Air';
        final String fedexPriorityOvernight ='Parts-FEDEX-Priority-Overnight';
        
        ShippingOptionsAndRatesFromExternalService[] shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();
        
        /*Http http = new Http();
HttpRequest request = new HttpRequest();
// To access the service below, you may need to add endpoint = https://b2b-commerce-test.herokuapp.com in Setup | Security | Remote site settings.
request.setEndpoint('https://b2b-commerce-test.herokuapp.com/calculate-shipping-rates-winter-21');
request.setMethod('GET');
HttpResponse response = http.send(request);*/
        
        // If the request is successful, parse the JSON response.
        // The response looks like this:
        // [{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},
        // {"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]
      /*  for(BWC_Product_Service__c productServiceInstance : [SELECT BWC_Service_Price__c 
                                                             FROM BWC_Product_Service__c
                                                             WHERE BWC_Service_Price__c != Null AND Cart_Item__c IN : [SELECT Id 
                                                                                                                       FROM Cartitem 
                                                                                                                       WHERE cart.status = 'Active' 
                                                                                                                       OR cart.status = 'Checkout']]){
                                                                                                                           System.debug('productServiceInstance-->'+productServiceInstance);
                                                                                                                           costPrice +=  productServiceInstance.BWC_Service_Price__c;   
                                                                                                                       }
        // Shipping Fedex Method Price Addition
        for(CartItem cartItemRecord : [SELECT Id,
                                       BWC_Shipping_Method__c
                                       FROM CartItem
                                       WHERE Cart.status = 'Checkout'
                                      AND Product2.BWC_Delivery_Type__c = 'sps fee']){
                                          if(cartItemRecord.BWC_Shipping_Method__c == groundOneToSevenDays){
                                              costPrice += 7.95;
                                          }
                                          else if(cartItemRecord.BWC_Shipping_Method__c == fedexSecondDayAir){
                                              costPrice += 17.95;
                                          }
                                          else if(cartItemRecord.BWC_Shipping_Method__c == fedexPriorityOvernight){
                                              costPrice += 19.95;
                                          }
                                       }*/
        // Shipping Fedex Method Price Addition
        String fakeResponse = '[{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":'+0+',"otherCost":0.00}}]';
        List<Object> results = (List<Object>) JSON.deserializeUntyped(fakeResponse);
        for (Object result: results) {
            Map<String, Object> subresult = (Map<String, Object>) result;
            Map<String, Object> providerAndRate = (Map<String, Object>) subresult.get('rate');
            shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
                (String) providerAndRate.get('name'),
                (String) providerAndRate.get('serviceCode'),
                //(Decimal) providerAndRate.get('shipmentCost') * numberOfUniqueItems, // Multiply so shipping costs can change; remove when using a real shipping provider
                (Decimal) providerAndRate.get('shipmentCost'),                    
                (Decimal) providerAndRate.get('otherCost'),
                (String) providerAndRate.get('serviceName')
            ));
        }
        return shippingOptions;
    }
    
    // Structure to store the shipping options retrieved from external service.
    Class ShippingOptionsAndRatesFromExternalService {
        private String name;
        private String provider;
        private Decimal rate;
        private Decimal otherCost;
        private String serviceName;
        
        public ShippingOptionsAndRatesFromExternalService(String someName, String someProvider, Decimal someRate, Decimal someOtherCost, String someServiceName) {
            name = someName;
            provider = someProvider;
            rate = someRate;
            otherCost = someOtherCost;
            serviceName = someServiceName;
        }
        
        public String getProvider() {
            return provider;
        }
        
        public Decimal getRate() {
            return rate;
        }
        
        public Decimal getOtherCost() {
            return otherCost;
        }
        
        public String getServiceName() {
            return serviceName;
        }
        
        public String getName() {
            return name;
        }
    }
    
    // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
    private void populateCartDeliveryGroupMethodWithShippingOptions(ShippingOptionsAndRatesFromExternalService shippingOption,
                                                                    Id cartDeliveryGroupId,
                                                                    Id deliveryMethodId,
                                                                    Id webCartId){
                                                                        // When inserting a new CartDeliveryGroupMethod, the following fields have to be populated:
                                                                        // CartDeliveryGroupId: Id of the delivery group of this shipping option
                                                                        // DeliveryMethodId: Id of the delivery method for this shipping option
                                                                        // ExternalProvider: Unique identifier of shipping provider
                                                                        // Name: Name of the CartDeliveryGroupMethod record
                                                                        // ShippingFee: The cost of shipping for the delivery group
                                                                        // WebCartId: Id if the cart that the delivery group belongs to
                                                                        CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
                                                                            CartDeliveryGroupId = cartDeliveryGroupId,
                                                                            DeliveryMethodId = deliveryMethodId,
                                                                            ExternalProvider = shippingOption.getProvider(),
                                                                            Name = shippingOption.getName(),
                                                                            ShippingFee = shippingOption.getRate(),
                                                                            WebCartId = webCartId
                                                                        );
                                                                        
                                                                        
                                                                        insert(cartDeliveryGroupMethod);
                                                                        
                                                                        // For continuous shipping calculation
                                                                        List<CartItem> cartItemList = [SELECT Id,
                                                                                            TotalPrice,
                                                                                            ListPrice,
                                                                                            TotalLineAmount 
                                                                                            FROM CartItem 
                                                                                            WHERE CartId = :webCartId 
                                                                                            AND Type = 'Charge' 
                                                                                            LIMIT 1];
                                                                        if(!cartItemList.isEmpty()){
                                                                            cartItemList[0].TotalPrice = shippingOption.getRate();
                                                                            cartItemList[0].ListPrice = shippingOption.getRate();
                                                                            cartItemList[0].TotalLineAmount = shippingOption.getRate();
                                                                            update cartItemList;
                                                                        }
                                                                        // For continuous shipping calculation
                                                                        //new change
                                                                        /*System.debug('before cartitem insert');
List<CartItem> cartItemList = [SELECT Id FROM CartItem WHERE Name = 'ship pro'];
//if(cartItemList.IsEmpty()){
CartItem cartItemInstance = new CartItem();
cartItemInstance.Name = 'ship pro';
cartItemInstance.Product2Id = [SELECT Id FROM Product2 LIMIT 1][0].Id;
cartItemInstance.CartId = webCartId;
cartItemInstance.CartDeliveryGroupId = cartDeliveryGroupId;
cartItemInstance.SalesPrice = 1;
cartItemInstance.ListPrice = 1;
cartItemInstance.UnitAdjustedPrice = 1;
cartItemInstance.TotalPrice = 1;
cartItemInstance.Quantity = 1;
cartItemInstance.Type = 'Charge';
cartItemInstance.Sku = 'ship pro';
insert cartItemInstance;
System.debug('after cartitem insert-->'+cartItemInstance);
// }

//new change*/
                                                                    }
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
            // In order for the error to be propagated to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displayed to the user
            // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Shipping'
            );
            insert(cartValidationError);
            return integrationStatus;
        }
    @testVisible
    private Id getShippingChargeProduct2Id(Id orderDeliveryMethodId) {
        // The Order Delivery Method should have a Product2 associated with it, because we added that in getDefaultOrderDeliveryMethod if it didn't exist.
        List<OrderDeliveryMethod> orderDeliveryMethods = [SELECT ProductId FROM OrderDeliveryMethod WHERE Id = :orderDeliveryMethodId WITH SECURITY_ENFORCED];
        return orderDeliveryMethods[0].ProductId;
    }
    
    private List<Id> getOrderDeliveryMethods(List<ShippingOptionsAndRatesFromExternalService> shippingOptions) {
        String defaultDeliveryMethodName = 'Order Delivery Method';
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();
        
        // Check to see if a default OrderDeliveryMethod already exists.
        // If it doesn't exist, create one.
        List<Id> orderDeliveryMethodIds = new List<Id>();
        List<OrderDeliveryMethod> orderDeliveryMethods = new List<OrderDeliveryMethod>();
        Integer i = 1;
        for (ShippingOptionsAndRatesFromExternalService shippingOption: shippingOptions) {
            String shippingOptionNumber = String.valueOf(i);
            String name = defaultDeliveryMethodName + shippingOptionNumber;
            List<OrderDeliveryMethod> odms = [SELECT Id, ProductId, Carrier, ClassOfService FROM OrderDeliveryMethod WHERE Name = :name WITH SECURITY_ENFORCED];
            // This is the case in which an Order Delivery method does not exist.
            if (odms.isEmpty()) {
                System.debug('Inside odms empty if');
                OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = name,
                    Carrier = shippingOption.serviceName,
                    isActive = true,
                    ProductId = product2IdForThisDeliveryMethod,
                    ClassOfService = shippingOption.provider
                );
                insert(defaultOrderDeliveryMethod);
                orderDeliveryMethodIds.add(defaultOrderDeliveryMethod.Id);
            }
            else {
                System.debug('Inside odms else if');
                // This is the case in which an Order Delivery method exists.
                // If the OrderDeliveryMethod doesn't have a Product2 associated with it, assign one
                // We can always pick the 0th orderDeliveryMethod since we queried based off the name.
                OrderDeliveryMethod existingodm = odms[0];
                System.debug('existingodm.ProductId-->'+existingodm.ProductId);
                // This is for reference implementation purposes only.
                // This is the if statement that checks to make sure that there is a product carrier and class of service
                // associated to the order delivery method.
                if (existingodm.ProductId == null || existingodm.Carrier == null || existingodm.ClassOfService == null) {
                    System.debug('inside else inside if');
                    existingodm.ProductId = product2IdForThisDeliveryMethod;
                    existingodm.Carrier = shippingOption.serviceName;
                    existingodm.ClassOfService = shippingOption.provider;
                    update(existingodm);
                }
                orderDeliveryMethodIds.add(existingodm.Id);
            }
            i+=1;
        }
        return orderDeliveryMethodIds;
    }
    
    private Id getDefaultShippingChargeProduct2Id() {
        // In this example we will name the product representing shipping charges 'Shipping Charge for this delivery method'.
        // Check to see if a Product2 with that name already exists.
        // If it doesn't exist, create one.
        String shippingChargeProduct2Name = 'Shipping Charge for this delivery method';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name WITH SECURITY_ENFORCED];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                isActive = true,
                Name = shippingChargeProduct2Name,
                Item_Number__c='123456'
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        }
        else {
            return shippingChargeProducts[0].Id;
        }
    }
}
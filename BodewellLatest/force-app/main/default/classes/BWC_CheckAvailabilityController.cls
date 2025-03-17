// This must implement the sfdc_checkout.CartInventoryValidation interface
// in order to be processed by the checkout flow and used for your Check Inventory integration.
global with sharing class BWC_CheckAvailabilityController implements sfdc_checkout.CartInventoryValidation {
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, ID cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            if(true){
                integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
                return integStatus;
            }
            //Check consumer in oracle DB
            /*List<User> userInstance = [SELECT AccountId,
Account.EBS_X_ACCOUNT_NUMBER__pc
FROM User 
WHERE Id =: UserInfo.getUserId() 
LIMIT 1];
System.debug('userInstance[0].Account.EBS_X_ACCOUNT_NUMBER__pc-->'+userInstance[0].Account.EBS_X_ACCOUNT_NUMBER__pc);*/
            // if(userInstance[0].Account.EBS_X_ACCOUNT_NUMBER__pc == null){
            //     userInstance[0].Account.EBS_X_ACCOUNT_NUMBER__pc = '';
            // }
            // GEA_AccountContactRelation__c accConRelationInstance=[Select Id,
            //                                                       Name,
            //                                                       EBS_X_BILL_TO_ORG_ID__c,
            //                                                       Contact__c,
            //                                                       EBS_X_SHIP_TO_ORG_ID__c 
            //                                                       from GEA_AccountContactRelation__c 
            //                                                       where Account__c=:userInstance[0].AccountId 
            //                                                       limit 1];
            // BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper searchAndConsumerPayloadInstance=new BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper();
            // searchAndConsumerPayloadInstance = BWC_SearchConsumerPayloadWrapper.getConsumerDetail(userInstance[0].Account.EBS_X_ACCOUNT_NUMBER__pc,accConRelationInstance);
            
            
            //Check consumer in oracle DB
            
            
            // Get all SKUs and their quantities from cart items.
            Map<String, Decimal> quantitiesFromSalesforce = new Map<String, Decimal>();
            for (CartItem cartItem : [SELECT Sku, Quantity FROM CartItem WHERE CartId = :cartId AND Type = 'Product' AND Product2.StockKeepingUnit != :label.BWC_BodewellMemberSKU WITH SECURITY_ENFORCED]) {
                if (String.isBlank(cartItem.Sku)) {
                    String errorMessage = 'The SKUs for all products in your cart must be defined.';
                    return integrationStatusFailedWithCartValidationOutputError(
                        integStatus,
                        errorMessage,
                        jobInfo,
                        cartId
                    );
                }
                quantitiesFromSalesforce.put(cartItem.Sku, cartItem.Quantity);
            }
            
            // Stop checkout if there are no items in the cart
            if (quantitiesFromSalesforce.isEmpty()) {
                String errorMessage = 'Looks like your cart is empty.';
                return integrationStatusFailedWithCartValidationOutputError(
                    integStatus,
                    errorMessage,
                    jobInfo,
                    cartId
                );
            }
            
            // Get all available quantities for products in the cart (cart items) from an external service.
            // Map<String, Object> quantitiesFromExternalService = getQuantitiesFromExternalService(quantitiesFromSalesforce.keySet(),searchAndConsumerPayloadInstance);       
            Map<String, Object> quantitiesFromExternalService = getQuantitiesFromExternalService(quantitiesFromSalesforce.keySet());      
            
            // For each cart item SKU, check that the quantity from the external service
            // is greater or equal to the quantity in the cart.
            // If that is not true, set the integration status to "Failed".
            for (String sku : quantitiesFromSalesforce.keySet()) {
                Decimal quantityFromSalesforce = quantitiesFromSalesforce.get(sku);
                Decimal quantityFromExternalService = (Decimal)quantitiesFromExternalService.get(sku);
                if (quantityFromExternalService == null){
                    String errorMessage = 'The product with sku ' + sku + ' could not be found in the external system';
                    return integrationStatusFailedWithCartValidationOutputError(
                        integStatus,
                        errorMessage,
                        jobInfo,
                        cartId
                    );
                } 
                else if (quantityFromExternalService < quantityFromSalesforce){
                    String errorMessage = 'Insufficient quantity for the product with sku ' + sku + ': ' 
                        + quantityFromSalesforce + ' needed, but only '
                        + quantityFromExternalService + ' available.';
                    return integrationStatusFailedWithCartValidationOutputError(
                        integStatus,
                        errorMessage,
                        jobInfo,
                        cartId
                    );
                }
                else {
                    // If the product exists and the available quantity is enough, set status as SUCCESS
                    integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
                }
            }
        } catch(Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        return integStatus;
    }
    //BDC-696 hit muleapi for check availability in oracle database.
    
    // private Map<String, Object> getQuantitiesFromExternalService (Set<String> skus,BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper responseWrapper) {
    private Map<String, Object> getQuantitiesFromExternalService (Set<String> skus){
        try{
            Map<String,Decimal> skuVsQuantityMap = new Map<String,Decimal>();
            Map<String, Object> quantitiesFromExternalService = new Map<String, Object>();
            List<CartItem> cartItemList = [SELECT Id,
                                           Name,
                                           Quantity,
                                           Cart.Status,
                                           sku,
                                           Product2.Item_Type__c,
                                           Product2.BWC_Is_Part__c
                                           FROM CartItem 
                                           WHERE SKU IN : skus 
                                           AND Cart.Status = 'Checkout'
                                          AND Product2.StockKeepingUnit != :label.BWC_BodewellMemberSKU];
            
            String jsonString = BWC_CheckAvailabilityPayloadCreator.getAvailabilityPayload(cartItemList,UserInfo.getUserId());
            System.debug('jsonString-->'+jsonString);
            String responseBody;
            if(!test.isRunningTest()){
                responseBody = utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudCheckAvailability_QA',null,'POST',jsonString) : RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudCheckAvailability',null,'POST',jsonString);

             /*   if(utility.isSandbox){
                    responseBody = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudCheckAvailability_QA',null,'POST',jsonString);
                }
                else{
                    responseBody = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudCheckAvailability',null,'POST',jsonString);
                }*/
            }
            else {
                responseBody = '{"availabilityDetails": [{ "inventoryItemName": "Item 1", "quantityOrdered": 10.0, "availableQuantity": 5.0, "sourceOrganizationID": 1    },    {      "inventoryItemName": "Item 2","quantityOrdered": 20.0, "availableQuantity": 15.0, "sourceOrganizationID": 2},{ "inventoryItemName": '+null+', "quantityOrdered": 10.0, "availableQuantity":5.0, "sourceOrganizationID": 1    }]}';
            }
            //String responseBody = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudCheckAvailability_QA',null,'POST',jsonString);
            
            System.debug(LoggingLevel.INFO,'responseBody-->'+responseBody);
            ResponseBodyWrapper jsonData = (ResponseBodyWrapper)JSON.deserialize(responseBody, ResponseBodyWrapper.class);
            for(Integer var = 0 ; var < jsonData.AvailabilityDetails.size() ; var++){
                skuVsQuantityMap.put(jsonData.AvailabilityDetails[var].inventoryItemName,jsonData.AvailabilityDetails[var].availableQuantity);
                
                //skuVsQuantityMap.put(jsonData.AvailabilityDetails[var].inventoryItemName,1);
            }
            System.debug('skuVsQuantityMap>>'+skuVsQuantityMap);
            List<CartItem> deleteCartItemList = new List<CartItem>();
            for(CartItem cartItemInstance : cartItemList){
                quantitiesFromExternalService.put(cartItemInstance.sku,skuVsQuantityMap.get(cartItemInstance.sku));
                //new changes for deleting cartitems
                if(cartItemInstance.Quantity > skuVsQuantityMap.get(cartItemInstance.sku)){
                    deleteCartItemList.add(cartItemInstance);
                }
                //new changes for deleting cartitems
            }
            System.debug('deleteCartItemList-->'+deleteCartItemList);
            delete deleteCartItemList;
            System.debug(LoggingLevel.INFO,'quantitiesFromExternalService-->'+quantitiesFromExternalService);
            // if(responseWrapper.isNull==false){
            //     User userInstance = [SELECT Id,
            //                          ContactId,
            //                          AccountId,
            //                          Account.EBS_X_ACCOUNT_NUMBER__pc,
            //                          Account.Name,
            //                          Account.BWC_Invoice_to_org_id__pc,
            //                          Account.BWC_Original_Inventory_Item_Id__pc,
            //                          Account.BWC_Ship_from_Org_Id__pc,
            //                          Account.BWC_Ship_to_Org_Id__pc 
            //                          FROM User 
            //                          WHERE Id =: UserInfo.getUserId()
            //                          LIMIT 1];
            
            //     Map<String, Object> userDetailMap = (Map<String, Object>) JSON.deserializeUntyped(responseWrapper.responseData);
            //     Account accInstance = new Account();
            //     accInstance.Id = userInstance.AccountId;
            //     accInstance.EBS_X_ACCOUNT_NUMBER__pc = (String)userDetailMap.get('X_ACCOUNT_NUMBER');
            //     // (String)userDetailMap.get('X_BILL_TO_ORG_ID') = (String)userDetailMap.get('X_BILL_TO_ORG_ID');
            //     // //accInstance.BWC_Original_Inventory_Item_Id__pc = '3851466';//not required and should come from user selection product sku
            //     // accInstance.BWC_Ship_from_Org_Id__pc = '202';//coming from ADC, this will not at consumer level
            //     // (String)userDetailMap.get('X_SHIP_TO_ORG_ID') = (String)userDetailMap.get('X_SHIP_TO_ORG_ID');
            //     update accInstance;
            
            //     List<GEA_AccountContactRelation__c> accConRelationList=[Select Id,
            //                                                             Name,
            //                                                             EBS_X_BILL_TO_ORG_ID__c,
            //                                                             Contact__c,EBS_X_SHIP_TO_ORG_ID__c 
            //                                                             from GEA_AccountContactRelation__c 
            //                                                             where Account__c=:userInstance.AccountId 
            //                                                             limit 1];
            //     if(!accConRelationList.isEmpty()){
            //         accConRelationList[0].Name=userInstance.Account.Name+' Location';
            //         accConRelationList[0].EBS_X_BILL_TO_ORG_ID__c=(String)userDetailMap.get('X_BILL_TO_ORG_ID');
            //         // accConRelationList[0].Contact__c=userInstance.ContactId;
            //         accConRelationList[0].EBS_X_SHIP_TO_ORG_ID__c=(String)userDetailMap.get('X_SHIP_TO_ORG_ID');
            //         update accConRelationList;
            //     }
            //     else{
            //         GEA_AccountContactRelation__c accConRelationRecord=new GEA_AccountContactRelation__c();
            //         accConRelationRecord.Name=userInstance.Account.Name+' Location';
            //         accConRelationRecord.Account__c=userInstance.AccountId;
            //         accConRelationRecord.EBS_X_BILL_TO_ORG_ID__c=(String)userDetailMap.get('X_BILL_TO_ORG_ID');
            //         accConRelationRecord.EBS_X_SHIP_TO_ORG_ID__c=(String)userDetailMap.get('X_SHIP_TO_ORG_ID');
            //         accConRelationRecord.Contact__c=userInstance.ContactId;
            //         insert accConRelationRecord;
            //     }
            
            //     // Debugging information
            //     System.debug('accInstance-->'+accInstance);
            // }            
            return quantitiesFromExternalService; 
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Exception-->'+e.getMessage());
            System.debug(LoggingLevel.ERROR,'Exception line number-->'+e.getLineNumber());
            throw new CalloutException ('There was a problem with the request');
        }
        
        
        /* Http http = new Http();
HttpRequest request = new HttpRequest();
Integer SuccessfulHttpRequest = 200;

// Encode the product SKUs to avoid any invalid characters in the request URL.
Set<String> encodedSkus = new Set<String>();
for (String sku : skus) {
encodedSkus.add(EncodingUtil.urlEncode(sku, 'UTF-8'));
}

// To access the service below, add endpoint = https://b2b-commerce-test.herokuapp.com in Setup | Security | Remote site settings.
request.setEndpoint('https://b2b-commerce-test.herokuapp.com/get-inventory?skus=' + JSON.serialize(encodedSkus));
request.setMethod('POST');
HttpResponse response = http.send(request);
// If the request is successful, parse the JSON response.
// The response includes the available quantity for each SKU and uses the following format:
// {"SKU-25-10028":9999.00, "SKU-25-10030":9999.00}
// Because this is a sample, and we want this integration to return success.
// The external service returns the exact list of SKUs it receives
// and an available quantity of 9999 for each SKU.
// If the cart has an item with a quantity higher than 9999, the integration returns an error.
if (response.getStatusCode() == SuccessfulHttpRequest) {
Map<String, Object> quantitiesFromExternalService = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
return quantitiesFromExternalService;
}
else {
throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
} */
    }  
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
            // To propagate the error to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displyed to the user
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
                Type = 'Inventory'
            );
            insert(cartValidationError);
            return integrationStatus;
        }
    public class ResponseBodyWrapper{
        public List<AvailabilityDetails> availabilityDetails = new List<AvailabilityDetails>();
    }
    public class AvailabilityDetails{
        public String inventoryItemName;
        public Decimal quantityOrdered;
        public Decimal availableQuantity;
        public Integer sourceOrganizationID;
    }
}
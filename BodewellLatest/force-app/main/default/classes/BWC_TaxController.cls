// This must implement the sfdc_checkout.CartTaxCalculations interface
// in order to be processed by the checkout flow and used for your Taxes integration.
global without sharing class BWC_TaxController implements sfdc_checkout.CartTaxCalculations {
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            // In the Spring '20 release, there should be one delivery group per cart.
            // In the future, when multiple delivery groups can be created,
            // this sample should be updated to loop through all delivery groups.
            
            // We need to get the ID of the delivery group in order to get the DeliverTo info.
            Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId][0].CartDeliveryGroupId;
            CartDeliveryGroup deliveryGroup = [SELECT DeliverToState, DeliverToCountry FROM CartDeliveryGroup WHERE Id = :cartDeliveryGroupId][0];
            
            // Get all SKUs, the cart item IDs, and the total prices from the cart items.
            Map<String, Id> cartItemIdsBySKU = new Map<String, Id>();
            Map<String, Decimal> cartItemTotalPriceBySKU = new Map<String, Decimal>();
            for (CartItem cartItem : [SELECT Sku, TotalPrice, Type FROM CartItem WHERE CartId = :cartId]) {
                String cartItemSKU = '';
                if (cartItem.Type == 'Product') {
                    if (String.isBlank(cartItem.Sku)) {
                        System.debug('inside if cart sku empty');
                        String errorMessage = 'The SKUs for all products in your cart must be defined.';
                        return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            errorMessage,
                            jobInfo,
                            cartId
                        );
                    }
                    cartItemSKU = cartItem.Sku;
                }
                else if (cartItem.Type == 'Charge') {
                    // This is an example for a Cart Item of type shipping charge.
                    // For simplicity and testing purposes, we just assign some SKU to this charge so that the taxation external service returns some value.
                    cartItemSKU = 'ChargeSKU';
                }
                cartItemIdsBySKU.put(cartItemSKU, cartItem.Id);
                cartItemTotalPriceBySKU.put(cartItemSKU, cartItem.TotalPrice);
            }      
            
            // new changes start at 03/10/2023
            
            
            BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper searchAndConsumerPayloadInstance = new BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper();
            searchAndConsumerPayloadInstance = BWC_SearchConsumerPayloadWrapper.getConsumerDetail('Shipping','SHIP_TO');
            
            // new changes end at 03/10/2023
            
            
            // Get the tax rates and tax amounts from an external service
            // Other parameters will be passed here, like ship_from, bill_to, more details about the ship_to, etc.
            Map<String, TaxDataFromExternalService> rateAndAmountFromExternalServicePerSku = getTaxRatesAndAmountsFromExternalService(
                cartItemTotalPriceBySKU, deliveryGroup.DeliverToState, deliveryGroup.DeliverToCountry, searchAndConsumerPayloadInstance
            );
            
            // If there are taxes from a previously cancelled checkout, delete them.
            List<Id> cartItemIds = cartItemIdsBySKU.values();
            List<CartTax> cartTaxList = [SELECT Id FROM CartTax WHERE CartItemId IN :cartItemIds];
            if(!cartTaxList.isEmpty()){
                delete cartTaxList;
            }
             
            Double totalServiceTaxAmount = 0;
            for(String sku :rateAndAmountFromExternalServicePerSku.keySet()){
                TaxDataFromExternalService rateAndAmountFromExternalService = rateAndAmountFromExternalServicePerSku.get(sku);
                if(!cartItemIdsBySKU.containsKey(sku)){
                    totalServiceTaxAmount = totalServiceTaxAmount + rateAndAmountFromExternalService.getAmount();
                }
            }
            
            // For each cart item, insert a new tax line in the CartTax entity.
            // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
            CartTax[] cartTaxestoInsert = new CartTax[]{};
            Boolean isCalculatedChargeTax = false;
            for (String sku : cartItemIdsBySKU.keySet()) {
                TaxDataFromExternalService rateAndAmountFromExternalService = rateAndAmountFromExternalServicePerSku.get(sku);
           /*     if (rateAndAmountFromExternalService == null){
                    System.debug('inside if null sku');
                    return integrationStatusFailedWithCartValidationOutputError(
                        integStatus,
                        'The product with sku ' + sku + ' could not be found in the external system',
                        jobInfo,
                        cartId
                    );
                }*/
                // If the sku was found in the external system, add a new CartTax line for that sku
                // The following fields from CartTax can be filled in:
                // Amount (required): Calculated tax amount.
                // CartItemId (required): ID of the cart item.
                // Description (optional): Description of CartTax.
                // Name (required): Name of the tax.
                // TaxCalculationDate (required): Calculation date for this tax line.
                // TaxRate (optional): The percentage value of the tax. Null if the tax is a flat amount.
                // TaxType (required): The type of tax, e.g. Actual or Estimated.

                CartTax tax = new CartTax();
                if(!rateAndAmountFromExternalServicePerSku.containsKey(sku) && !isCalculatedChargeTax){
                    //totalServiceTaxAmount = rateAndAmountFromExternalService.getAmount() + totalServiceTaxAmount;
                    tax.Amount = totalServiceTaxAmount;
                    tax.CartItemId = cartItemIdsBySKU.get('ChargeSKU');
                    tax.Name = 'ChargeSKU';
                    tax.TaxRate = 0;
                    isCalculatedChargeTax = true;
                }
                else{
                    tax.CartItemId = cartItemIdsBySKU.get(sku);
                    if(!isCalculatedChargeTax){
                    tax.Amount = rateAndAmountFromExternalService.getAmount() + totalServiceTaxAmount;
                        isCalculatedChargeTax = true;
                    }
                    else{
                        tax.Amount = rateAndAmountFromExternalService.getAmount();
                    }
                    tax.Name = rateAndAmountFromExternalService.getTaxName();
                    tax.TaxRate = rateAndAmountFromExternalService.getRate();
                }
                
                tax.TaxCalculationDate = Date.today();
                
                tax.TaxType = 'Actual';
                    cartTaxestoInsert.add(tax);
            }
            insert(cartTaxestoInsert);
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
        } catch(Exception e) {
            System.debug('exception message-->'+e.getMessage());
            System.debug('exception line number-->'+e.getLineNumber());
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
        System.debug('integStatus.status-->'+integStatus.status);
        return integStatus;
    }
    
    private Map<String, TaxDataFromExternalService> getTaxRatesAndAmountsFromExternalService (
        Map<String, Decimal> cartItemTotalAmountBySKU, String state, String country, BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper responseWrapper) {
            
            List<Account> accountList = new List<Account>();
            String jsonString;
            String responseBody;
            List<CartItem> cartItemList = [SELECT Id,
                                           CartId,
                                           Name,
                                           Quantity,
                                           Cart.Status,
                                           sku,
                                           TotalAmount,
                                           TotalPriceAfterAllAdjustments,
                                           Product2.Item_Type__c,
                                           Product2.ProductCode,
                                           Product2.BWC_Delivery_Type__c,
                                           TotalListPrice,
                                           Type
                                           FROM CartItem 
                                           WHERE Cart.Status = 'Checkout'
                                           AND Cart.IsSecondary = false
                                           AND Cart.CreatedById = :UserInfo.getUserId() 
                                           AND Type != 'Charge'];
            
            jsonString = BWC_InvoiceTaxPayloadCreator.getInvoiceTaxPayload(cartItemList,responseWrapper);
            System.debug('jsonString-->'+jsonString);
            
            if(!test.isRunningTest()){
                if(utility.isSandbox){
                    responseBody = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloud_Invoicetax',null,'POST',jsonString);
                }
                else{
                    responseBody = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloud_Invoicetax',null,'POST',jsonString);
                }
            }
            else{
                responseBody = '{"value": {"invoice": {"line": [{"totaltaxamount": 10.5,"taxsummary": {"taxrate": 0.08},"partnumber": "Part123"}]}}}';
            }
            
            WrapperClass jsonData = (WrapperClass)JSON.deserialize(responseBody, WrapperClass.class);
            System.debug('responseBody-->'+jsonData);
            if(jsonData.value.invoice.line[0].totaltaxamount != null && jsonData.value.invoice.line[0].taxsummary != null){
                Decimal totalTaxAmountInstance = jsonData.value.invoice.line[0].totaltaxamount;
                Decimal taxRateInstance = jsonData.value.invoice.line[0].taxsummary.taxrate;
            }
            Map<String, TaxDataFromExternalService> taxDataFromMuleServiceBySKU = new Map<String, TaxDataFromExternalService>();
            for(Line lineInstance : jsonData.value.invoice.line){
                System.debug('Line-->'+lineInstance);
                if(taxDataFromMuleServiceBySKU.containsKey(lineInstance.partnumber)){
                    if(lineInstance.taxsummary != null && lineInstance.totaltaxamount != null){
                        TaxDataFromExternalService taxExternalDataInstance = taxDataFromMuleServiceBySKU.get(lineInstance.partnumber);
                        taxExternalDataInstance.amount += lineInstance.totaltaxamount;
                        taxDataFromMuleServiceBySKU.put(lineInstance.partnumber,taxExternalDataInstance);
                    }
                }
                else{
                    TaxDataFromExternalService taxExternalDataInstance = new TaxDataFromExternalService();
                    if(lineInstance.taxsummary != null && lineInstance.totaltaxamount != null){
                        taxExternalDataInstance.rate = lineInstance.taxsummary.taxrate;
                        taxExternalDataInstance.amount = lineInstance.totaltaxamount;
                        taxExternalDataInstance.taxName = lineInstance.partnumber;
                    }
                    else{
                        taxExternalDataInstance.rate = 0;
                        taxExternalDataInstance.amount = 0;
                        taxExternalDataInstance.taxName = lineInstance.partnumber;
                    }
                    taxDataFromMuleServiceBySKU.put(lineInstance.partnumber,taxExternalDataInstance);
                }
            }
            System.debug('taxDataFromMuleServiceBySKU-->'+taxDataFromMuleServiceBySKU);
            
            accountList = [SELECT Id,
                               EBS_X_PARTY_ID__pc,
                               EBS_X_CUST_ACCOUNT_ID__pc,
                               BWC_Consumer_Number__c
                               FROM Account 
                               WHERE Id=: [SELECT AccountId
                                           FROM User
                                           WHERE Id =:UserInfo.getUserId() 
                                           LIMIT 1].AccountId
                              LIMIT 1];
            
            List<ContactPointAddress> conPointAddressList=[SELECT Id,
                                                               BWC_Account_Number__c,
                                                               BWC_Ship_To_Org_Id__c,
                                                               BWC_Bill_To_Org_Id__c 
                                                               FROM ContactPointAddress 
                                                               WHERE IsDefault=true 
                                                               AND AddressType = 'Shipping' 
                                                               AND ParentId =: [SELECT AccountId 
                                                                                  FROM User 
                                                                                  WHERE Id =:UserInfo.getUserId() 
                                                                                  LIMIT 1].AccountId
                                                               LIMIT 1];
            
            if(responseWrapper.isNull){
                Map<String, Object> userDetailMap = (Map<String, Object>) JSON.deserializeUntyped(responseWrapper.responseData);
                
                System.debug('conPointAddressListInTax??'+conPointAddressList);
                
                if(!conPointAddressList.isEmpty() && !accountList.isEmpty()){
                    conPointAddressList[0].BWC_Ship_To_Org_Id__c = (String)userDetailMap.get('X_SHIP_TO_ORG_ID');
                    //conPointAddressList[0].BWC_Bill_To_Org_Id__c = (String)userDetailMap.get('X_BILL_TO_ORG_ID');
                    
                    accountList[0].EBS_X_PARTY_ID__pc = (String)userDetailMap.get('X_PARTY_ID');
                    accountList[0].EBS_X_CUST_ACCOUNT_ID__pc = (String)userDetailMap.get('X_CUST_ACCOUNT_ID');
                    accountList[0].BWC_Consumer_Number__c = (String)userDetailMap.get('X_ACCOUNT_NUMBER');
                    
                    update accountList;
                    update conPointAddressList;
                    
                } 
                System.debug('conPointAddressListInTax22??'+conPointAddressList);
            }  
            else{
                if(!conPointAddressList.isEmpty() && !accountList.isEmpty()){ 
                    conPointAddressList[0].BWC_Ship_To_Org_Id__c = responseWrapper.shipToOrgId;
                    //conPointAddressList[0].BWC_Bill_To_Org_Id__c = responseWrapper.billToOrgId;
                    update conPointAddressList;
                    
                } 
            }
            return taxDataFromMuleServiceBySKU;
        }
    
    Class TaxDataFromExternalService {
        private Decimal rate;
        private Decimal amount;
        private String taxName;
        
        public TaxDataFromExternalService () {
            rate = 0.0;
            amount = 0.0;
            taxName = '';
        }
        
        public TaxDataFromExternalService (Decimal someRate, Decimal someAmount, String someTaxName) {
            rate = someRate;
            amount = someAmount;
            taxName = someTaxName;
        }
        
        public Decimal getRate() {
            return rate;
        }
        
        public Decimal getAmount() {
            return amount;
        }
        
        public String getTaxName() {
            return taxName;
        }
    }
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;

            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Taxes'
            );
            insert(cartValidationError);
            return integrationStatus;
        }
    

    public class WrapperClass {
        public  Value value;
    }
    
    public  class Value {
        public Invoice invoice;
    }
    
    public  class Invoice {
        public List<Line> line = new List<Line>();
    }
    
    public  class Line {
        public Double totaltaxamount;
        public Taxsummary taxsummary;
        public String partnumber;
    }
    
    public class Taxsummary{
        public Double taxrate;
    }
}
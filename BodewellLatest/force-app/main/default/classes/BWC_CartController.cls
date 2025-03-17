public without sharing class BWC_CartController {
    
    @AuraEnabled
    public static List<CartTax> getTaxAmount(String cartId){
    List<CartTax> taxAmount = new List<CartTax>();
    try {
        taxAmount = [SELECT id, amount FROM CartTax WHERE cartid = :cartId];
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }

    return taxAmount.size() > 0 ? taxAmount : new List<CartTax>();
}

    @AuraEnabled(cacheable=true)
    public static List<BuyerGroupMember> getBuyerGroup(String acctId){
        List<BuyerGroupMember> buyerGrp= [SELECT Id, Name, BuyerId,Buyer.Name, BuyerGroupId, BuyerGroup.Name FROM BuyerGroupMember where BuyerId=: acctId];
        // System.debug('buyerGrp from getBuyerGroup===>' + buyerGrp);
        return buyerGrp;
    }
    
    @AuraEnabled
    public static Map<String, Object> fetchPrices(List<String> productIds, List<Integer>quantities) 
    {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Map<String, String> priceBookNameMap = new Map<String, String>();
            
            for (BWC_Price_Book_Configuration__mdt config : [SELECT DeveloperName, PriceBookName__c FROM BWC_Price_Book_Configuration__mdt]) {
                priceBookNameMap.put(config.DeveloperName, config.PriceBookName__c);
                System.debug('priceBookNameMap: ' + priceBookNameMap );
            }
            
            Map<Id, PricebookEntry> basePricebookEntriesMap = new Map<Id, PricebookEntry>();    
            for(PricebookEntry pb: [ SELECT BWC_Product_MSRP__c, UnitPrice, Product2Id
                                    FROM PricebookEntry
                                    WHERE Product2Id IN :productIds
                                    AND Pricebook2.Name = :priceBookNameMap.get('BasePriceBook')])
            {
                basePricebookEntriesMap.put(pb.Product2Id,pb);
            }
            
            System.debug('basePricebookEntriesMap: ' + basePricebookEntriesMap );
            System.debug('basePricebookEntriesMap: ' + basePricebookEntriesMap.keySet());
            
            Map<Id, PricebookEntry> memberPricebookEntriesMap = new Map<Id, PricebookEntry>();
            for(PricebookEntry mpb:[SELECT BWC_Product_MSRP__c, UnitPrice, Product2Id
                                    FROM PricebookEntry
                                    WHERE Product2Id IN :productIds
                                    AND Pricebook2.Name = :priceBookNameMap.get('Member_Price_Book')])
            {
                memberPricebookEntriesMap.put(mpb.Product2Id,mpb);
            }
            
            System.debug('memberPricebookEntriesMap: ' + memberPricebookEntriesMap );


            // Base and Member Price Books for Parts
            Map<Id, PricebookEntry> basePartsPricebookEntriesMap = new Map<Id, PricebookEntry>();    
            for(PricebookEntry pb: [ SELECT BWC_Product_MSRP__c, UnitPrice, Product2Id
                                    FROM PricebookEntry
                                    WHERE Product2Id IN :productIds
                                    AND Pricebook2.Name = :priceBookNameMap.get('PartsBasePriceBook')])
            {
                basePartsPricebookEntriesMap.put(pb.Product2Id,pb);
            }
            
            System.debug('basePartsPricebookEntriesMap: ' + basePartsPricebookEntriesMap );
            System.debug('basePartsPricebookEntriesMap: ' + basePartsPricebookEntriesMap.keySet());

            Map<Id, PricebookEntry> memberPartsPricebookEntriesMap = new Map<Id, PricebookEntry>();
            for(PricebookEntry mpb:[SELECT BWC_Product_MSRP__c, UnitPrice, Product2Id
                                    FROM PricebookEntry
                                    WHERE Product2Id IN :productIds
                                    AND Pricebook2.Name = :priceBookNameMap.get('Member_Parts_Price_Book')])
            {
                memberPartsPricebookEntriesMap.put(mpb.Product2Id,mpb);
            }
            
            System.debug('memberPartsPricebookEntriesMap: ' + memberPartsPricebookEntriesMap );
            
            Decimal totalDifference = 0.0;  
            Decimal promotionalSavings = 0.0;  
            Decimal basePriceBookListPrice=0.0;
            //2/21
            Decimal basePartsPriceBookListPrice=0.0;
            Decimal memberDiscount=0.0;
            Decimal memberPriceBookListPrice=0.0;

            Map<String, Decimal> promotionalSavingsMap = new Map<String, Decimal>();
            Map<String, Decimal> memberDiscountMap = new Map<String, Decimal>();
            Map<String, Decimal> basePriceBookListPriceMap = new Map<String, Decimal>();
            Map<String, Decimal> memberPriceBookListPriceMap = new Map<String, Decimal>();
            //2/21
            /*
            Map<String, Decimal> basePartsPriceBookListPriceMap = new Map<String, Decimal>();
            Map<String, Decimal> memberPartsPriceBookListPriceMap = new Map<String, Decimal>();
            */
            for (Integer i = 0; i < productIds.size(); i++) {
                String itemId = productIds[i];
                Integer quantity = quantities[i];
                System.debug('basePricebookEntry ItemId' + itemId);
                PricebookEntry basePricebookEntry = basePricebookEntriesMap.get(itemId);
                PricebookEntry memberPricebookEntry = memberPricebookEntriesMap.get(itemId);
                System.debug('basePricebookEntry: ' + basePricebookEntry + ', memberPricebookEntry: ' + memberPricebookEntry);
                //2/21
                PricebookEntry basePartsPricebookEntry = basePartsPricebookEntriesMap.get(itemId);
                PricebookEntry memberPartsPricebookEntry = memberPartsPricebookEntriesMap.get(itemId);
                System.debug('basePartsPricebookEntry: ' + basePartsPricebookEntry + ', memberPartsPricebookEntry: ' + memberPartsPricebookEntry);
                
                if ((basePricebookEntry != null) && (memberPricebookEntry != null)) {
                    System.debug('Item: ' + itemId + ', basePricebookEntry.UnitPrice: ' + basePricebookEntry.UnitPrice + ', memberPricebookEntry.UnitPrice: ' + memberPricebookEntry.UnitPrice + ', basePricebookEntry.BWC_Product_MSRP__c: ' + basePricebookEntry.BWC_Product_MSRP__c);
                    if (basePricebookEntry.BWC_Product_MSRP__c == null || basePricebookEntry.BWC_Product_MSRP__c == 0) {
                        promotionalSavings = 0;
                        basePriceBookListPrice=basePricebookEntry.UnitPrice * quantity;
                    } else {
                        promotionalSavings = (basePricebookEntry.BWC_Product_MSRP__c - basePricebookEntry.UnitPrice) * quantity;
                    }
                     memberDiscount = (basePricebookEntry.UnitPrice - memberPricebookEntry.UnitPrice) * quantity;
                     memberPriceBookListPrice = memberPricebookEntry.UnitPrice * quantity;
                    System.debug('promotionalSavings: ' + promotionalSavings + ', memberDiscount: ' + memberDiscount + ', memberPriceBookListPrice: ' + memberPriceBookListPrice);
                    
                    
                    promotionalSavingsMap.put(itemId, promotionalSavings);
                    memberDiscountMap.put(itemId, memberDiscount);
                    basePriceBookListPriceMap.put(itemId, basePriceBookListPrice);
                    memberPriceBookListPriceMap.put(itemId, memberPriceBookListPrice);
                    
                    //totalDifference += (promotionalSavings + memberDiscount);
                    totalDifference+= memberDiscount;
                    System.debug('totalDifference: ' + totalDifference);
                }
                
                //2/21
                if (basePartsPricebookEntry != null && memberPartsPricebookEntry != null) {
                    System.debug('Parts:: Item: ' + itemId + ', basePartsPricebookEntry.UnitPrice: ' + basePartsPricebookEntry.UnitPrice + ', memberPartsPricebookEntry.UnitPrice: ' + memberPartsPricebookEntry.UnitPrice + ', basePartsPricebookEntry.BWC_Product_MSRP__c: ' + basePartsPricebookEntry.BWC_Product_MSRP__c);
                    if (basePartsPricebookEntry.BWC_Product_MSRP__c == null || basePartsPricebookEntry.BWC_Product_MSRP__c == 0) {
                        promotionalSavings = 0;
                        basePartsPriceBookListPrice=basePartsPricebookEntry.UnitPrice * quantity;
                    } else {
                        promotionalSavings = (basePartsPricebookEntry.BWC_Product_MSRP__c - basePartsPricebookEntry.UnitPrice) * quantity;
                    }
                     memberDiscount = (basePartsPricebookEntry.UnitPrice - memberPartsPricebookEntry.UnitPrice) * quantity;
                     memberPriceBookListPrice = memberPartsPricebookEntry.UnitPrice * quantity;
                    System.debug('promotionalSavings Parts: ' + promotionalSavings + ', memberDiscount Parts: ' + memberDiscount + ', memberPriceBookListPrice Parts: ' + memberPriceBookListPrice);
                   
                    
                    promotionalSavingsMap.put(itemId, promotionalSavings);
                    memberDiscountMap.put(itemId, memberDiscount);
                    basePriceBookListPriceMap.put(itemId, basePartsPriceBookListPrice);
                    memberPriceBookListPriceMap.put(itemId, memberPriceBookListPrice);
                    
                   // totalDifference += (promotionalSavings + memberDiscount);
                   totalDifference+= memberDiscount;
                    System.debug('Parts::totalDifference: ' + totalDifference);
                } 
            }
            
            result.put('promotionalSavings', promotionalSavingsMap);
            result.put('basePriceBookListPrice',basePriceBookListPriceMap);
            result.put('memberDiscount', memberDiscountMap);
            result.put('totalDifference', totalDifference);
            result.put('memberPriceBookListPriceMap', memberPriceBookListPriceMap);
            
        } catch (Exception e) {
            result.put('error', e.getMessage());
        }
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static ContactPointAddress getConsumerZipcode(
        String accountId
    ) {
        ContactPointAddress zipCodeInstance;
        if(accountId!=null) {
            List<ContactPointAddress> contactPointAddressInstance = [SELECT 
                                                                     PostalCode, State 
                                                                     FROM ContactPointAddress 
                                                                     WHERE ParentId =:accountId and IsDefault = true and addressType='Shipping'
                                                                     LIMIT 1];
            if(!contactPointAddressInstance.isEmpty()){
                zipCodeInstance = contactPointAddressInstance[0]; //'{"zipcode":"'+contactPointAddressInstance[0].PostalCode+'","state":"'+contactPointAddressInstance[0].State+'"}';
            }
            
        }
        return zipCodeInstance;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static String getZipcodeServiceInfo2(
        String zipCode
    ) {
        String payload = '{"zipcode": "'+zipCode+'"}';
        String res;
        if(utility.isSandbox)
            //res='{"zipcode":"40222","has_home_delivery":true,"has_small_package":true,"has_sds_delivery":true,"is_will_call":false,"has_will_call":true,"sds_ap_zone":"ZONE1","hd_ap_zone":"HOME","mt_ap_zone":"ZONE1","agents":[{"zipcode":"40225","address":"BLDG 10-APPLIANCE WHSE ","method":"Small Package Delivery","agent_id":"LOU","phone":"5024524311","city":"Louisville","name":"GE Appliance Park","state":"KY","display_name":"SPS","v_code":"LM","loc_type":"adc_loc"},{"zipcode":"63042","address":"306 HAZELWOOD LOGISTIC CENTER DR Suite 500 ","method":"Home Delivery","agent_id":"6LM","phone":"800-856-6508","city":"HAZELWOOD","name":"FORWARD AIR FINAL MILE LLC","state":"MO","display_name":"HD","v_code":"LM","loc_type":"hd_loc"},{"zipcode":"63042","address":"306 HAZELWOOD LOGISTIC CENTER DR Suite 500 ","method":"Delivery","agent_id":"6LM","phone":"800-856-6508","city":"HAZELWOOD","name":"FORWARD AIR FINAL MILE LLC","state":"MO","display_name":"SDS","v_code":"LM","loc_type":"sds_loc"},{"zipcode":"63042","address":"306 HAZELWOOD LOGISTIC CENTER DR Suite 500 ","method":"Will Call","agent_id":"6LM","phone":"800-856-6508","city":"HAZELWOOD","name":"FORWARD AIR FINAL MILE LLC","state":"MO","display_name":"Will Call","v_code":"LM","loc_type":"sds_will_call_loc"},{"zipcode":"63042","address":"306 HAZELWOOD LOGISTIC CENTER DR Suite 500 ","method":"","agent_id":"6LM","phone":"800-856-6508","city":"HAZELWOOD","name":"FORWARD AIR FINAL MILE LLC","state":"MO","display_name":"","v_code":"LM","loc_type":"return_loc"},{"zipcode":"63042","address":"306 HAZELWOOD LOGISTIC CENTER DR Suite 500 ","method":"","agent_id":"6LM","phone":"800-856-6508","city":"HAZELWOOD","name":"FORWARD AIR FINAL MILE LLC","state":"MO","display_name":"","v_code":"LM","loc_type":"mt_loc"}]}';
            res= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Bwc_ZipServiceAPI',null,'POST',payload);
        else 
            res= RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_ZipServiceAPI',null,'POST',payload);
        
        
        return res;
        
    }
    
    @AuraEnabled
    public static String getDeliveryDates(
        String zipCode, String state,
        String deliveryType, List<String> skuList
    ) {
        
        /*BWC_AvailabilityCacheWrapper cacheResponse = new BWC_AvailabilityCacheWrapper();
cacheResponse = BWC_ADC.getADC_Details(skuList,zipCode);
List<BWC_AvailabilityCacheWrapper.availabilityDetails> availabilityDetailsList = cacheResponse.availabilityDetails;
System.debug('availabilityDetailsList>'+availabilityDetailsList);
System.debug('cacheResponse-->'+cacheResponse);*/
        Date maxDate = Date.newInstance(1960, 1, 1);
        String startDate;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(String sku:skuList){
            gen.writeStartObject();
            gen.writeStringField('inventoryItemName', sku);
            gen.writeNumberField('quantityOrdered', 1);
            Datetime GMTDate = DateTime.now();
            String strConvertedDate = GMTDate.format('yyyy-MM-dd');
            gen.writeStringField('requestDate', strConvertedDate);
            System.debug('strConvertedDate>>>'+strConvertedDate);
            gen.writeStringField('quantityUOM', 'EA');
            gen.writeNumberField('orderLineIdentifier', 1);
            gen.writeStringField('zipCode',zipCode);
            gen.writeStringField('itemType', 'FG');
            gen.writeEndObject(); 
        }
        gen.writeEndArray();
        String jsonString = gen.getAsString();
        String responseBody;
        if(!test.isRunningTest()){
            responseBody = utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudCheckAvailability_QA',null,'POST',jsonString) : RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudCheckAvailability',null,'POST',jsonString);
        }
        else{
            responseBody = '{"availabilityDetails": [{ "inventoryItemName": "Item 1", "quantityOrdered": 10.0, "availableQuantity": 5.0, "sourceOrganizationID": 1, "shipDate": "2024-02-06T23:59:00-05:00"    },    {      "inventoryItemName": "Item 2","quantityOrdered": 20.0, "availableQuantity": 15.0, "sourceOrganizationID": 2,"shipDate": "2024-02-06T23:59:00-05:00"},{ "inventoryItemName": '+null+', "quantityOrdered": 10.0, "availableQuantity":5.0, "sourceOrganizationID": 1,"shipDate": "2024-02-03T23:59:00-05:00"    }]}';
        }
        ResponseBodyWrapper jsonData = (ResponseBodyWrapper)JSON.deserialize(responseBody, ResponseBodyWrapper.class);
        List<AvailabilityDetails> availabilityList = jsonData.availabilityDetails;
        for(AvailabilityDetails availabilityRecord:availabilityList){
            if(Date.ValueOf(availabilityRecord.shipDate) >= Date.ValueOf(maxDate)){
                System.debug('availabilityRecord>>'+Date.ValueOf(availabilityRecord.shipDate));
                maxDate = Date.ValueOf(availabilityRecord.shipDate);
            }
        }
        startDate = DateTime.newInstance(maxDate.year(),maxDate.month(),maxDate.day()).format('yyyy-MM-dd');
        System.debug('startDate-->'+startDate);
        String payload;
        payload = '{"zipcode" : "'+zipCode+'","state":"","mode" :"'+deliveryType+'","typeOfCall":"ALL DAYS","startDate":"'+startDate+'","noOfDays": 180}';
        System.debug('payload->'+payload);
        String res;
        if(utility.isSandbox)
            res= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Bwc_CalenderAPI',null,'POST',payload);
        else 
            res= RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CalenderAPI',null,'POST',payload);
        
        System.debug('response-->'+res);
        if(res.contains('500'))
            res = 'Delivery Not available';
        return res;
        
    }
    public class ResponseBodyWrapper{
        public List<AvailabilityDetails> availabilityDetails = new List<AvailabilityDetails>();
    }
    public class AvailabilityDetails{
        public String inventoryItemName;
        public Decimal quantityOrdered;
        public Decimal availableQuantity;
        public Integer sourceOrganizationID;
        public String shipDate;
    }
    
    @AuraEnabled(cacheable=true)  
    public static List < BWC_Product_Bundle_Services__mdt > getShipTypeFees() {  
        return [ SELECT Id, DeveloperName, MasterLabel,Price__c,Type__c,Product_SKU__c,Product_Sf_Id__c FROM BWC_Product_Bundle_Services__mdt where DeveloperName='HOME_DELIVERY' or DeveloperName='FREESTANDING_INSTALL_2STEP' or DeveloperName='SMALL_PACKAGE_DELIVERY' or DeveloperName='Standard_Shipping' or DeveloperName='Second_Day' or  DeveloperName='Next_Day' ];
        
    }
    
    
    
}
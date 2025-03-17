/**
* @author Abhishek Bisht
* @date 22/08/2023
* @description The purpose of this class is to get the adc orgId and Availabilty of the product
* */
public without sharing class BWC_ADC {
    /*
* @description The purpose of this method to get the Availabilty of the product with respect to sku of product and current zipcode which is selected by consumer
* @param postalCodeInstance - It contains the zip code is coming from selected zip from site 
* @param skuList - It contains the product StockKeepingUnit
* @return BWC_AvailabilityCacheWrapper
*/
    @AuraEnabled
    public static BWC_AvailabilityCacheWrapper getADC_Details(List<String> skuList, String postalCodeInstance){
        try{
            String adcOrgValue = '';
            String res = BWC_ADC_Controller.hitADC_Api(postalCodeInstance);
            System.debug('res>>>'+res);
            List<BWC_ADC_WrapperResponse> adc_WrapperResponseInstance = (List<BWC_ADC_WrapperResponse>) JSON.deserialize(res, List<BWC_ADC_WrapperResponse>.class);
            adcOrgValue = adc_WrapperResponseInstance[0].adcOrg;
            System.debug('adcOrgValue-->'+adcOrgValue);
            BWC_AvailabilityCacheWrapper availabiltyCacheWrapperInstance = BWC_AvailabilityCache.getcacheAvailabilty(skuList,adcOrgValue);
            return availabiltyCacheWrapperInstance;
        }
        Catch(Exception e){
            System.debug('Exception ADC message-->'+e.getMessage());
            System.debug('Exception ADC Line number-->'+e.getLineNumber());
            return null;
        }  
    }
    /*
* @description The purpose of this method to get the product details from product soql regarding put various condition in lwc component
* @param productId - It contains product Id
* @return ProductValuesResponse
*/
    @AuraEnabled(cacheable=true)
    public static ProductValuesResponse getProductValues(String productId){
        try{
            ProductValuesResponse productValueResponse = new ProductValuesResponse();
            productValueResponse.productRecord  = [SELECT Id,
                                                   BWC_PARTSTAT__c,
                                                   Restrictions__c,
                                                   BWC_Delivery_Type__c,
                                                   BWC_Material_Stock_Indicator__c,
                                                   BWC_Brand__c,
                                                   StockKeepingUnit,
                                                   BWC_SUPERCEDE_COUNT__c,
                                                   BWC_Derivative__c,
                                                   Item_Lifecycle_Phase__c,
                                                   Is_Accessory__c,
                                                   Is_Finished_Good__c,
                                                   ProductClass,
                                                   BWC_Exploded_Diagram_Parts__c,
                                                   BWC_IsPurchasable__c,
                                                   BWC_PLPIsVisible__c,
                                                   Status__c,
                                                   BWC_Is_Part__c
                                                   FROM Product2 
                                                   WHERE Id = :productId 
                                                   LIMIT 1];
            
            List<Related_Items__c> relatedItemList = [ SELECT Product__c, 
                                                      Related_Product__r.Id, 
                                                      Related_Product__r.StockKeepingUnit, 
                                                      Related_Product__r.Description 
                                                      FROM Related_Items__c 
                                                      WHERE Product__c =:productId 
                                                      AND Sales_Relationship_Type__c = 'Superseded' 
                                                      ORDER BY Start_Date__c 
                                                      DESC NULLS LAST];
            productValueResponse.relatedItemsList = relatedItemList;
            return productValueResponse;
        }
        catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
        
    }
    
    public class ProductValuesResponse {
        @AuraEnabled 
        public Product2 productRecord;
        @AuraEnabled 
        public List<Related_Items__c> relatedItemsList;
    }
}
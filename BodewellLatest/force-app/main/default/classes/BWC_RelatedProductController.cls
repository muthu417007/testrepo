/**
* @author Abhishek Bisht
* @date 15/02/2024
* @description The purpose of this class is to get the fetch product data of related products
* */
public without sharing class BWC_RelatedProductController {
    /*
* @description The purpose of this method to get the product Ids of related product on PDP.
* @param skuList - It contains the product StockKeepingUnit
* @return List<Product2>
*/
    @AuraEnabled(cacheable = true)
    public static List<Product2> productDetails(Id productId, String zipCode){
        try{
            
            List<String> skuList = new List<String>();
            List<String> availableSkuList = new List<String>();
            Date todayDate = Date.Today();
            BWC_AvailabilityCacheWrapper availableData = new BWC_AvailabilityCacheWrapper();
            
            Product2 productInstance = [SELECT Id,
                                        BWC_Pairing_Models__c,
                                        BWC_Optional_Charge__c,
                                        BWC_Accessories__c
                                        FROM Product2
                                        WHERE Id = :productId];
            
            if(!String.isBlank(productInstance.BWC_Accessories__c)){
                skuList.addAll(productInstance.BWC_Accessories__c.split('~'));
            }
            if(!String.isBlank(productInstance.BWC_Pairing_Models__c)){
                skuList.addAll(productInstance.BWC_Pairing_Models__c.split('~'));
            }
            if(!String.isBlank(productInstance.BWC_Optional_Charge__c)){
                skuList.addAll(productInstance.BWC_Optional_Charge__c.split('~'));
            }
            System.debug('skuList->'+skuList);
            
            if(!skuList.isEmpty()){
                availableData = BWC_ADC.getADC_Details(skuList,zipCode);
            }
            
            for(BWC_AvailabilityCacheWrapper.availabilityDetails availablityData : availableData.availabilityDetails){
                System.debug('availablityData->'+availablityData);
                if(availablityData.availableQuantity > 0 && Date.valueOf(availablityData.shipDate) >= todayDate){
                    availableSkuList.add(availablityData.inventoryItemName);
                }
            }
            
            List<Product2> productList = [SELECT Id
                                          FROM Product2
                                          WHERE StockKeepingUnit IN :availableSkuList
                                          LIMIT 20];
            System.debug('productList-->'+productList);
            
            return productList; 
        }
        catch(Exception e){
            System.debug('Exception error occur was ->'+e.getMessage()+'at line->'+e.getLineNumber());
            return null;
        }
        
    }
}
/**
* @author Abhishek Bisht
* @date 22/08/2023
* @description The purpose of this class is to get the Availabilty of the product
* */
public class BWC_AvailabilityCache {
     /*
* @description The purpose of this method to get the Availabilty of the product with respect to sku of product and current zipcode which is selected by consumer
* @param postalCodeInstance - It contains the adc api org code
* @param skuList - It contains the product StockKeepingUnit
* @return BWC_AvailabilityCacheWrapper
*/
    @AuraEnabled
    public static BWC_AvailabilityCacheWrapper getcacheAvailabilty(List<String> skuList, String postalCodeInstance){
        try{
            /*
        This is dynamic payload for cache avaliabilty
        */
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('inventoryItemName', skuList); 
        gen.writeStringField('orgCode', postalCodeInstance);
        
        gen.writeEndObject();
        gen.writeEndArray();
        String jsonString = gen.getAsString();
        String res;
        if(!test.isRunningTest()){
            //hitting cache availabilty api
            if(utility.isSandbox){
                res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudCacheAvailability_QA',null,'POST',jsonString);
            }
            else{
                res=RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudCacheAvailability',null,'POST',jsonString);
            }
        }
        else{
            res='{  "errorStatus": "Success",  "errorMessage": "",  "availabilityDetails": [    {      "requestedDateQuantity": 10,      "shipDate": "2023-09-30",      "availableQuantity": 8.5,      "requestedShipDate": "2023-10-05",      "errorCode": null,      "quantityOrdered": 5,      "message": "",      "inventoryItemName": "ItemA"    },    {      "requestedDateQuantity": 5,      "shipDate": "2023-10-10",      "availableQuantity": 4.0,      "requestedShipDate": "2023-10-15",      "errorCode": null,      "quantityOrdered": 2,      "message": "",      "inventoryItemName": "ItemB"    }  ]}';
        }
        System.debug('res=='+res);
        BWC_AvailabilityCacheWrapper resultList=BWC_AvailabilityCacheWrapper.parse(res);
        System.debug('res=='+resultList);
        return resultList;  
        }
        catch(Exception e) {
            System.debug('exception message-->'+e.getMessage());
            System.debug('exception line number-->'+e.getLineNumber());
        return null;
    }
    }
}
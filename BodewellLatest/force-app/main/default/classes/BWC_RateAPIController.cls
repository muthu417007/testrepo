/**
* @author Abhishek Bisht
* @date 20/02/2024
* @description The purpose of this class is to hit rate api
* */
public class BWC_RateAPIController {
    /*
* @description This method is used to hit rate api and send the response
* @param orderIdInstance - This parameter is coming from ProcessOrder apex class
* @return JSONGenerator
*/
    public static ResponseWrapper hitRateApi(List<String> productSkuList, String zipcodeInstance) {
        try{
            String response;
            String testResponse = '[    {        "item": "GXSL55R",        "values": [            {                "shippingMethod": "Parts-FEDEX-Ground-1-7-Days",                "shippingRate": "7.95",                "shippingItem": "SMALL PACKAGE DELIVERY"            },            {                "shippingMethod": "Parts-FEDEX-2nd Day Air",                "shippingRate": "17.95",                "shippingItem": "SMALL PACKAGE DELIVERY"            },            {                "shippingMethod": "Parts-FEDEX-Priority-Overnight",                "shippingRate": "19.95",                "shippingItem": "SMALL PACKAGE DELIVERY"            }        ]    }]';
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeObjectField('items', productSkuList); 
            gen.writeStringField('postalCode', zipcodeInstance);
            gen.writeEndObject();
            String payload = gen.getAsString();
            System.debug('payload-->'+payload);
            
            if(!String.isBlank(payload)){
                response = test.isRunningTest() ? testResponse : utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudRateAPI',null,'POST',payload) : RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudRateAPI',null,'POST',payload);
            }
            System.debug('response-->'+response);
            ResponseWrapper responseWrapper = (ResponseWrapper) System.JSON.deserialize(response, ResponseWrapper.class);
            System.debug('responseWrapper-->'+responseWrapper);
            return responseWrapper;
        }catch(Exception e){
            System.debug('Exception occured:'+e.getMessage()+'at line->'+e.getLineNumber());
            return null;
        }
    }
    
    public class ResponseWrapper {
        public String status;
        public List<ItemWrapper> items;    
    }
    public class ItemWrapper {
        public String item;
        public List<ValueWrapper> values;
    }  
    public class ValueWrapper {
        public String shippingMethod;
        public String shippingRate;
        public String shippingItem;
    }  
}
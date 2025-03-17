/**
* @author Abhishek Bisht
* @date 05/03/2024
* @description The purpose of this class is to hit the Mule API for Delivery Service.
* */
public class BWC_DeliveryController {
    /*
* @description This method is used for create a paylaod and hit the mule api for Delivery Service.
* @param zipcode
* @param sku
* @param mode
* @return DeliveryResponseWrapper
*/
    public static DeliveryResponseWrapper getDeliveryService(String zipcode, String sku, String mode){
        try{
            String fakeResponse = '{  "sku": "ASD",  "zipcode": "12",  "mode": "SDS",  "services": [    {      "id": "M037",      "description": "",      "marketing_text": "a",      "required": "FALSE",      "dependent_service_ids": null    }  ]}';
            String payload = '{"zipcode":'+'"'+zipcode+'"'+',"sku":'+'"'+sku+'"'+',"mode":'+'"'+mode+'"'+'}';
            System.debug('payload-->'+payload);
            String response = test.isRunningTest() ? fakeResponse : Utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth', 'Sandbox_EBS_QA_Token', 'Sandbox_CommerceCloud_DeliveryQA', null, 'POST', payload) : RequestMuleAPIData.getMuleAPIData('Production_MuleAuth', 'PROD_EBS_Token', 'BWC_PROD_Delivery', null, 'POST', payload);
            DeliveryResponseWrapper responseWrapper = new DeliveryResponseWrapper();
            responseWrapper = (DeliveryResponseWrapper)JSON.deserialize(response, DeliveryResponseWrapper.class);
            System.debug('responseWrapper-->'+responseWrapper);
            return responseWrapper;
        }
        catch(Exception ex){
            System.debug('Message-->'+ex.getMessage()+'  Line Number-->'+ex.getLineNumber());
            return null;
        }
    }
    public class DeliveryResponseWrapper{
        public String sku;	//AZ91H12E3E
        public String zipcode;	//42223
        public String mode;	//SDS
        @auraEnabled
        public List<cls_services> services;
        
        
    }
  
    public class cls_dependent_service_ids {
    }
    public class cls_services {
        @auraEnabled
        public String id;	//M037
        @auraEnabled
        public String description;	//Delivery 4th floor and above
        @auraEnabled
        public String marketing_text;	
        //Delivery above the 3rd floor
        @auraEnabled
        public String required;	//FALSE
        @auraEnabled
        public cls_dependent_service_ids dependent_service_ids;
     @auraEnabled
        public String price;
    }
}
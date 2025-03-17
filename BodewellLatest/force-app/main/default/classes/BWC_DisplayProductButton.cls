/**
* @author Abhishek Bisht
* @date 22/08/2023
* @description The purpose of this class is to check the product quantity
* */
public without sharing class BWC_DisplayProductButton {
    /*
* @description The purpose of this method is to return boolean value to check the quantity is available or not.
* @param productId - It contains the productId coming from Lwc Component 
* @param postalCodeInstance - It contains the zip code coming from Lwc Component  
* @return Boolean	
*/
    @AuraEnabled
    public static Boolean bwc_Available(String productId,String postalCodeInstance){
        try{
            final String cacheTestResponse = '{    "availabilityDetails": [        {            "inventoryItemName": "SKU1",            "quantityOrdered": 1,            "requestedShipDate": "2024-01-10T00:00:00-05:00",            "shipDate": "2024-07-15T00:00:00-05:00",            "availableQuantity": 10000000000,            "requestedDateQuantity": 0,            "errorCode": 53,            "message": "Cannot meet request date or latest acceptable date"        },        {            "inventoryItemName": "SKU2",            "quantityOrdered": 1,            "requestedShipDate": "2024-01-10T00:00:00-05:00",            "shipDate": "2024-01-10T00:00:00-05:00",            "availableQuantity": 7,            "requestedDateQuantity": 7,            "errorCode": 0,            "message": null        }    ],    "errorStatus": null,    "errorMessage": null}';
            final String ZIP_SERVICE_API_RESPONSE = '{"has_home_delivery" : false , "is_will_call" : true}';
            Product2 productData=[SELECT Id,
                                  ProductClass,
                                  BWC_Is_Part__c,
                                  StockKeepingUnit,
                                  BWC_Exploded_Diagram_Parts__c,
                                  BWC_Delivery_Type__c,
                                  Is_Accessory__c,
                                  Is_Finished_Good__c,
                                  BWC_IsPurchasable__c
                                  FROM Product2
                                  WHERE Id=:productId 
                                  LIMIT 1];
            String sku;
            if(productData.ProductClass == 'VariationParent'){
                String inputString = productData.BWC_Exploded_Diagram_Parts__c;
                String innerObjectString = inputString.substringBetween('{', '}');
                List<String> keyValuePairs = innerObjectString.split(',');
                Map<String, String> keyValueMap = new Map<String, String>();
                for (String keyValuePair : keyValuePairs) {
                    List<String> parts = keyValuePair.split(':');
                    sku = parts[2].trim().replaceAll('["\']', '');
                }
            }
            else{
                sku = productData.StockKeepingUnit;
            }
            
            String deliveryType = productData.BWC_Delivery_Type__c;
            String agentPayload = '{"zipcode": "'+postalCodeInstance+'"}';
            String resp;
            if(!test.isRunningTest()){
                if(utility.isSandbox){
                    resp= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Bwc_ZipServiceAPI',null,'POST',agentPayload);
                }
                else{
                    resp= RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_ZipServiceAPI',null,'POST',agentPayload);
                    
                }
            }
            else{
                resp=ZIP_SERVICE_API_RESPONSE;
            }
            BWC_AvailabilityCacheWrapper availableData = new BWC_AvailabilityCacheWrapper();
            if((deliveryType == 'hd' || deliveryType == 'sds' || deliveryType == 'willcall')){
                availableData=BWC_ADC.getADC_Details(new List<String>{sku},postalCodeInstance);
                System.debug('availData>>>'+availableData);
                System.debug('availableQuantity-->'+availableData.availabilityDetails[0].availableQuantity);
                if(availableData.availabilityDetails[0].availableQuantity==null || availableData.availabilityDetails[0].availableQuantity==0 || availableData.availabilityDetails[0].shipDate == null){
                return false;
              }
            }
            
            
            BWC_AgentResponseWrapper agentWrapperResponse = (BWC_AgentResponseWrapper)JSON.deserialize(resp, BWC_AgentResponseWrapper.class);
            Date todaysDate = Date.Today();
            if(agentWrapperResponse.has_home_delivery == false && agentWrapperResponse.has_sds_delivery == false && agentWrapperResponse.has_will_call == true && Date.valueof(availableData.availabilityDetails[0].shipDate) >= todaysDate){
                return true;
            }
            else if(deliveryType == 'hd' || deliveryType == 'sds' || deliveryType == 'willcall'){
                Date shipmentDate = Date.valueOf(availableData.availabilityDetails[0].shipDate);
                String formattedDate = DateTime.newInstance(shipmentDate.year(),shipmentDate.month(),shipmentDate.day()).format('yyyy-MM-dd');
                String payload = '{"zipcode": "' + postalCodeInstance + '","mode": "' + deliveryType.toUpperCase() + '","typeOfCall": "FIRST DATE","startDate": "' + formattedDate + '","noOfDays": 180}';
                String calendarResponse = BWC_CalendarApi.getCalenderResponse(payload);
                calendarResponse = calendarResponse.replace('date', 'stdate');
                calendarResponse = calendarResponse.replace('calendar_stdates', 'calendar_dates');
                BWC_CalendarResponseWrapper calendarWrapperResponse=(BWC_CalendarResponseWrapper)JSON.deserialize(calendarResponse, BWC_CalendarResponseWrapper.class);
                String dateString = String.valueOf(calendarWrapperResponse.calendar_dates[0].stdate);
                List<String> dateParts = dateString.split('/');
                String rearrangedDate = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
                Date formatedDate = Date.valueOf(rearrangedDate);
                System.debug('formatedDate77--'+formatedDate);
                Date todayDate = Date.Today();
                Date dateAfterNintyDays = todayDate.addDays(90);
                if((String.valueOf(availableData.availabilityDetails[0].availableQuantity) != '1.0E10' && formatedDate >= todayDate) || (formatedDate<=dateAfterNintyDays && String.valueOf(availableData.availabilityDetails[0].availableQuantity) == '1.0E10' && formatedDate >= todayDate)){
                    return true;
                }
                else{
                    return false;
                }
            }
            else{
                String itemType = productData.BWC_Is_Part__c ? 'PARTS_ITEM' : 'FG';
                String responseBody = test.isRunningTest() ? cacheTestResponse : BWC_CalendarApi.getEstimatedDateForSmallAppliance(new List<String>{sku},postalCodeInstance,itemType);
                
                ResponseBodyWrapper jsonData = (ResponseBodyWrapper)JSON.deserialize(responseBody, ResponseBodyWrapper.class);
                System.debug('jsonData.availabilityDetails>'+jsonData.availabilityDetails);
                System.debug('jsonDataQuantity-->'+jsonData.availabilityDetails[0].availableQuantity);
                Date todayDate = Date.Today();
                Date dateAfterNintyDays = todayDate.addDays(90);
                if((String.valueOf(jsonData.availabilityDetails[0].availableQuantity) != '1.0E10' && Date.ValueOf(jsonData.availabilityDetails[0].shipDate) >= todayDate) || (Date.ValueOf(jsonData.availabilityDetails[0].shipDate)<=dateAfterNintyDays && String.valueOf(jsonData.availabilityDetails[0].availableQuantity) == '1.0E10' && Date.ValueOf(jsonData.availabilityDetails[0].shipDate) >= todayDate)){
                    return true;
                }
                else{
                    return false;
                }
            }
        }
        catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
        
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
}
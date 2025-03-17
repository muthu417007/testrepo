/**
* @author Abhishek Bisht
* @date 22/08/2023
* @description The purpose of this class is to get the Pickup date to show on the PLP.
* */
public without sharing class BWC_CalendarApi {
    /*
* @description The purpose of this method to get pickup date by hitting zipServiceApi.
* @param postalCodeInstance - It contains the zipCode
* @param productIdInstance - It contains the productId
* @return String
*/
    @AuraEnabled(cacheable=true)
    public static String BWC_CalendarApiMethod(String postalCodeInstance,String productIdInstance, String availabilityShipDate) {
        try{
            final String ZIP_SERVICE_API_RESPONSE = '{"has_home_delivery" : false ,"has_sds_delivery": false, "has_will_call" : true}';
            
            String payload = '{"zipcode": "'+postalCodeInstance+'"}';
            String resp = '';
            if(!test.isRunningTest()){
                if(utility.isSandbox){
                    resp = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Bwc_ZipServiceAPI',null,'POST',payload);
                }
                else{
                    resp = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_ZipServiceAPI',null,'POST',payload);
                }
            }
            else{
                resp=ZIP_SERVICE_API_RESPONSE;
            }
            
            BWC_AgentResponseWrapper agentWrapperResponse = (BWC_AgentResponseWrapper)JSON.deserialize(resp, BWC_AgentResponseWrapper.class);
            if(!agentWrapperResponse.has_home_delivery && !agentWrapperResponse.has_sds_delivery && agentWrapperResponse.has_will_call){
                Date GMTDate = Date.ValueOf(availabilityShipDate);
                String shipDate = DateTime.newInstance(GMTDate.year(),GMTDate.month(),GMTDate.day()).format('yyyy-MM-dd');
                String calendarPayload = '{"zipcode": "'+postalCodeInstance+'","mode": "WILLCALL","typeOfCall": "FIRST DATE", "startDate": "'+shipDate+'","noOfDays": 180}';
                System.debug('calendarPayload>>>'+calendarPayload);
                String calenderResponse = getCalenderResponse(calendarPayload);
                if(calenderResponse.contains('Error')){
                    return null;
                }
                else{
                    calenderResponse = calenderResponse.replace('date', 'stdate');
                    calenderResponse = calenderResponse.replace('calendar_stdates', 'calendar_dates');
                    BWC_CalendarResponseWrapper calendarWrapperResponse=(BWC_CalendarResponseWrapper)JSON.deserialize(calenderResponse, BWC_CalendarResponseWrapper.class);
                    System.debug('calendarWrapperResponse>>'+calendarWrapperResponse);
                    System.debug('calendarWrapperResponseDates>>>'+calendarWrapperResponse.calendar_dates);
                    return calendarWrapperResponse.calendar_dates[0].stdate;
                    /*System.debug('calendarWrapperResponseFirstIndex>>>'+calendarWrapperResponse.calendar_dates[calendarWrapperResponse.calendar_dates.size()-1].stdate);
                    for(Integer i = calendarWrapperResponse.calendar_dates.size()-1; i >= 0; i--){
                        if(calendarWrapperResponse.calendar_dates[i].available){
                            return calendarWrapperResponse.calendar_dates[i].stdate;
                        }
                    }*/
                }   
            }
            return '';
        }
        catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
        
    }
    /*
* @description The purpose of this method to show the dates in PDP and PLP page
* @param calendarPayload - It contains the calendar api payload
* @return String
*/
    @AuraEnabled
    public static String getCalenderResponse(String calendarPayload){
        final String CALENDAR_API_RESPONSE = '{"calendar_dates": [{"date": "03/19/2024","available": true}]}';
        String calenderResponse;
        if(!test.isRunningTest()){
            calenderResponse = utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Bwc_CalenderAPI',null,'POST',calendarPayload) : RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CalenderAPI',null,'POST',calendarPayload);
        }
        else{
            calenderResponse = CALENDAR_API_RESPONSE;
        }
        System.debug('response-->'+calenderResponse);
        return calenderResponse;
    }
    /*
* @description The purpose of this method to generate the payload and hit the cache avaliabilty api
* @param sku - It contains the sku of the product
* @param zipCode - It contains the zipCode of the login user
* @return String
*/
    @AuraEnabled
    public static String getEstimatedDateForSmallAppliance(List<String> skuList, String zipCode, String itemType){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(String sku:skuList){
            gen.writeStartObject();
            gen.writeStringField('inventoryItemName', sku);
            gen.writeNumberField('quantityOrdered', 1);
            Datetime GMTDate = DateTime.now() + 1;
            String strConvertedDate = GMTDate.format('yyyy-MM-dd');
            gen.writeStringField('requestDate', strConvertedDate);
            System.debug('strConvertedDate>>>'+strConvertedDate);
            gen.writeStringField('quantityUOM', 'EA');
            gen.writeNumberField('orderLineIdentifier', 1);
            gen.writeStringField('zipCode',zipCode);
            gen.writeStringField('itemType', itemType);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        String jsonString = gen.getAsString();
        String responseBody;
        if(!test.isRunningTest()){
            responseBody = utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudCheckAvailability_QA',null,'POST',jsonString) : RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudCheckAvailability',null,'POST',jsonString);
        }
        return responseBody;
    }
}
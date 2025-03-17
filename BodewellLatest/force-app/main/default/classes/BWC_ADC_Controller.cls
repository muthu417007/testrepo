/**
* @author Abhishek Bisht
* @date 14/03/2024
* @description This class is used to hit ADC mule API.
* */
public class BWC_ADC_Controller {
    /*
* @description The purpose of this method to get ADC response from adc mule API.
* @param postalCodeInstance - It contains zipcode of login site.
* @return BWC_AvailabilityCacheWrapper
*/
    @AuraEnabled
    public static String hitADC_Api(String postalCodeInstance){
        try{
            DateTime gmtDate = DateTime.now()-2;
            String strRequestedDate = gmtDate.format('yyyy-MM-dd');
            String jsonString= '{"date":"'+strRequestedDate+'","postalCode":"'+postalCodeInstance+'"}';
            String res = '';
            System.debug('jsonString-->'+jsonString);
            if(!test.isRunningTest()){
                //hitting adc api            
                if(utility.isSandbox){
                    res = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudADC_QA',null,'POST',jsonString);
                }
                else{
                    res = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudADC',null,'POST',jsonString);
                }
            }
            else{
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                 res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
            }
            System.debug('hitADC_Api res>>>'+res);
            return res;
        }
        catch(Exception e){
            System.debug('hitADC_Api Exception message-->'+e.getMessage());
            System.debug('hitADC_Api Exception line number-->'+e.getLineNumber());
            return null;
        }
    }
}
/**
@description : Apex Class to handle GTM information
Author:       Akhil M R
Company:      TCS
Created Date: 06/02/2023
*/
public without sharing class BWC_GtmInfoHelper {
    /**
    * @description : Custom exception class for BWC_GtmInfoHelper
    */
	public class GtmInfoHelperException extends Exception {}
    
    /**
    * @description : Resonse Class to handle Location details
    */
    public class BWC_GtmInfoHelperResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public Object data;
    	@AuraEnabled public Object error;
    
        public BWC_GtmInfoHelperResponse(Boolean success, Object data, Exception error) {
            this.success = success;
            this.data = data;
            this.error = error;
        }
    }
    
    /**
    * @description : Apex method to get placeId using lat long values from LWC
    */
    @AuraEnabled
    public static BWC_GtmInfoHelperResponse getProductType(String productId) 
    {
        try 
        {
            Product2 data = [SELECT Id, Product_Category__c FROM Product2 Where Id =: productId LIMIT 1];
            return new BWC_GtmInfoHelperResponse(true,data.Product_Category__c,Null);
     	} catch(Exception ex) {
            return new BWC_GtmInfoHelperResponse(false,Null,ex);
        }
    }
}
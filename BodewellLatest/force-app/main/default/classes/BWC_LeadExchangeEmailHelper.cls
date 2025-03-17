//******************************************************************************************
// Author:       Akhil M R
// Company:      TCS
// Created Date: 23/11/2023
//******************************************************************************************
//@description : Apex Class to handle email for lead management
public without sharing class BWC_LeadExchangeEmailHelper {
	//@description : Flow request modal to handle email for lead management
    public class CouponLinkFlowRequest
    {
        @InvocableVariable public Id RecordId;
    }    
    //@description : Flow response modal to handle email for lead management
    public class CouponLinkFlowResponse {
        @AuraEnabled @InvocableVariable public String CouponLink; 
        public CouponLinkFlowResponse(String couponLink) {
            this.CouponLink = couponLink;
        }
    }    
    //@description : Method to get coupon link
    @InvocableMethod(label='Get Coupon Link')    
    public static List<CouponLinkFlowResponse> getCouponLink(List<CouponLinkFlowRequest> requests) { 
        String recordId=requests[0].RecordId;
        List<CouponLinkFlowResponse> flowRes = new List<CouponLinkFlowResponse>();
        try {
            String link = BWC_LeadExchangeHelper.getEncrypetedText(recordId);
            Bodewell_Lead_Exchange__mdt metadata = BWC_LeadExchangeHelper.getBodewellLeadExchangeMetaData();
            String qrLink = metadata.Coupon_Code_Link__c + link;
            flowRes.add(new CouponLinkFlowResponse(qrLink));
        	return flowRes;
        } catch(Exception e) {  
           	return flowRes;
        } 
    }
    //@description : Response class to get coupon code
    public class BWC_LeadExchangeEmailHelperResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public Object data;
    	@AuraEnabled public Object error;
    
        public BWC_LeadExchangeEmailHelperResponse(Boolean success, Object data, Exception error) {
            this.success = success;
            this.data = data;
            this.error = error;
        }
    }
    //@description : Response class for coupon respone
    public class BWC_CouponResponse {
        @AuraEnabled public String coupon;
        @AuraEnabled public Object account;
    	@AuraEnabled public Object storeHours;
        @AuraEnabled public Object promotions;
    
        public BWC_CouponResponse(String coupon, Object account, Object storeHours, Object promotions) {
            this.coupon = coupon;
            this.account = account;
            this.storeHours = storeHours;
            this.promotions = promotions;
        }
    }
    //@description : Method to get coupon code
    @AuraEnabled
    public static BWC_LeadExchangeEmailHelperResponse getCouponCode(String key) 
    {
        try {
            String refId = BWC_LeadExchangeHelper.getDecrypetedText(key);
            Referral__c refObj = [SELECT Id, Coupon_Code__c,Partner_Account__c FROM Referral__c WHERE Id=:refId LIMIT 1];
            Account partnerAccount = [SELECT id, name,Party_Name__c,recordtypeid,ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, website,phone,ShippingLatitude, ShippingLongitude,  AcceptAppointment__c,Seller_Logo__c From Account WHERE Id =:refObj.Partner_Account__c ];
            List<Store_Hours__c> allStHours = [SELECT Id, Name,Account__c, Account__r.Name,  Type__c, DayOfWeek__c, Start_Time__c , End_Time__c FROM Store_Hours__c WHERE Account__c =: refObj.Partner_Account__c];
            List<BWC_LocationController.BWC_StoreHour> storeHours = new List<BWC_LocationController.BWC_StoreHour>();
            for(Store_Hours__c sth: allStHours) {
                String strStartTime;
                String strEndTime;
                if(sth.Start_Time__c != null) {
                    Integer startHour = sth.Start_Time__c.hour();
                	Integer startMin = sth.Start_Time__c.minute();
                	strStartTime = startHour + ':' + startMin;
                }
                if(sth.End_Time__c != null) {
                    Integer endHour = sth.End_Time__c.hour();
                    Integer endMin = sth.End_Time__c.minute();
                    strEndTime = endHour + ':' + endMin;
                }
                storeHours.add(new BWC_LocationController.BWC_StoreHour(sth.DayOfWeek__c, strStartTime, strEndTime,sth.Start_Time__c, sth.End_Time__c, sth.Type__c));
            }
            Dealer_Promotion__c dp = [SELECT Id, Name, Account__c, IsActive__c, Promotion__c, Promotion_Terms__c, PromotionExpirationDate__c, PromotionStartDate__c  FROM Dealer_Promotion__c WHERE IsActive__c = true AND Account__c =: refObj.Partner_Account__c LIMIT 1];
            BWC_LocationController.BWC_DealerPromotion dealerPromotion = new BWC_LocationController.BWC_DealerPromotion(dp.Name,dp.IsActive__c, dp.Promotion__c, dp.PromotionExpirationDate__c, dp.PromotionStartDate__c,dp.Promotion_Terms__c);
            return new BWC_LeadExchangeEmailHelperResponse(true,new BWC_CouponResponse(refObj.Coupon_Code__c, partnerAccount, storeHours, dealerPromotion),Null);
      	} catch(Exception ex) {
            return new BWC_LeadExchangeEmailHelperResponse(false,Null,ex);
        }
    }
}
/**
@description : Apex Class to handle Location details
Author:       Akhil M R
Company:      TCS
Created Date: 25/10/2023
*/
public without sharing class BWC_LocationController {
    
    public static HttpCalloutMock mock = null;
    
    /**
    * @description : Resonse Class to handle Location details
    */
    public class BWC_LocationControllerResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public Object data;
    	@AuraEnabled public Object error;
    
        public BWC_LocationControllerResponse(Boolean success, Object data, Exception error) {
            this.success = success;
            this.data = data;
            this.error = error;
        }
    }
    
    /**
    * @description : Response Class to handle Location details with related records
    */
    public class BWC_AccountWithLocation {
        @AuraEnabled public Object store;
        @AuraEnabled public Object storeHours;
        @AuraEnabled public Object storePromotion;
        @AuraEnabled public Object storeService;
    	@AuraEnabled public Decimal dist;
    
        public BWC_AccountWithLocation(Object store, Object storeHours, Object storePromotion, Object storeService, Decimal dist) {
            this.store = store;
            this.storeHours = storeHours;
            this.storePromotion = storePromotion;
            this.storeService = storeService;
            this.dist = dist;
        }
    }
    
    /**
    * @description : Response Class to handle Store Hour details
    */
    public class BWC_StoreHour {
        @AuraEnabled public String dayOfWeek;
        @AuraEnabled public String strStartTime;
    	@AuraEnabled public String strEndTime;
        @AuraEnabled public Time startTime;
    	@AuraEnabled public Time endTime;
        @AuraEnabled public String dayType;
    
        public BWC_StoreHour(String dayOfWeek, String strStartTime, String strEndTime, Time startTime, Time endTime, String dayType) {
            this.dayOfWeek = dayOfWeek;
            this.startTime = startTime;
            this.strStartTime = strStartTime;
            this.strEndTime = strEndTime;
            this.endTime = endTime;
            this.dayType = dayType;
        }
    }
    
    /**
    * @description : Response Class to handle Dealer Promotion details
    */
    public class BWC_DealerPromotion {
        @AuraEnabled public String promotionname;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public String promotiontext;
    	@AuraEnabled public Date promotionExpirationDate;
        @AuraEnabled public Date promotionStartDate;
        @AuraEnabled public String promotionTerms;
    
        public BWC_DealerPromotion(String promotionname, Boolean isActive,String promotiontext,Date promotionExpirationDate,Date promotionStartDate,String promotionTerms) {
            this.promotionname = promotionname;
            this.isActive = isActive;
            this.promotiontext = promotiontext;
            this.promotionExpirationDate = promotionExpirationDate;
            this.promotionStartDate = promotionStartDate;
            this.promotionTerms = promotionTerms;
        }
    }
    
    /**
    * @description : Response Class to handle Service Offered details
    */
	public class BWC_OfferedSevices {
        @AuraEnabled public String service ;
                
        public BWC_OfferedSevices(String service) {
            this.service = service;
        }
    }
    
    /**
    * @description : Apex method to get placeId using lat long values from LWC
    */
    @AuraEnabled
    public static BWC_LocationControllerResponse getPlaceId(String latlong) 
    {
        try 
        {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            // this will fail unless you set up https://maps.googleapis.com/ in your remote site settings
            req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?latlng='+ latlong +'&result_type=street_address&key='+Label.RG_GoogleMapsGeocodeApiKey);
            
            HttpResponse res = new HttpResponse();
            
            if (Test.isRunningTest() && (mock!=null)) {
                res = mock.respond(req);
            } else {
                res = h.send(req);
            }
            
            // you can either deserialize to a class type, or untyped, as I've done here. 
            Map<String,Object> gr = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            List<Object> results = (List<Object>)gr.get('results');
            Map<String,Object> firstResult = (Map<String,Object>)results[0]; // just taking the first one for this example              
            String placeId = String.valueOf(firstResult.get('place_id'));
            return new BWC_LocationControllerResponse(true,placeId,Null);
     	} catch(Exception ex) {
            return new BWC_LocationControllerResponse(false,Null,ex);
        }
    }
    
    /**
    * @description : Apex method to get place details using placeId values from LWC
    */
	@AuraEnabled
    public static BWC_LocationControllerResponse getPlaceDetails(String placeId) 
    {
        try 
        {
            String latLong = RG_SearchApiAddressController.getPlaceDetails(placeId);
            String[] latLongValues = latLong.split(',');
            double lat = decimal.valueOf(latLongValues[0]);
            double lon = decimal.valueOf(latLongValues[1]);
            List<BWC_AccountWithLocation> res = getStore(lat,lon);            
            return new BWC_LocationControllerResponse(true,res,Null);
        } catch(Exception ex) {
            return new BWC_LocationControllerResponse(false,Null,ex);
        }
    }
    
    /**
    * @description : Apex method to get place details using lat long values from LWC
    */
   	@AuraEnabled
    public static BWC_LocationControllerResponse getPlaceDetailsByLatLong(String latValue, String lonValue) 
    {
        try 
        {
            double lat = decimal.valueOf(latValue);
            double lon = decimal.valueOf(lonValue);
            List<BWC_AccountWithLocation> res = getStore(lat,lon);            
            return new BWC_LocationControllerResponse(true,res,Null);
        } catch(Exception ex) {
            return new BWC_LocationControllerResponse(false,Null,ex);
        }
    }
    
    /**
    * @description : Apex method to get store details using lat long values
    */
	public static List<BWC_AccountWithLocation> getStore(double lat, double lon) {
        try {
            Bodewell_Lead_Exchange__mdt bwcmdt = BWC_LeadExchangeHelper.getBodewellLeadExchangeMetaData();
            Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId();
            List<Account> data = [SELECT Id, Name, Doing_Business_As_DBA__c, Party_Name__c, RecordTypeId, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, Website, Phone, ShippingLatitude, ShippingLongitude, AcceptAppointment__c, Seller_Logo__c from account where recordtypeId = :retailRecordTypeId AND Bodewell_Preferred_Partner__c = true AND DISTANCE(ShippingAddress, GEOLOCATION(:lat,:lon), 'mi') < :bwcmdt.Store_Search_Distance__c];
            //List<Account> data = [SELECT id, name,recordtypeid,billingstreet,billingcity,billingstate, billingcountry,billingpostalcode,website,phone,billinglatitude,billinglongitude,AcceptAppointment__c,Seller_Logo__c from account where Status__c='A' AND parent.Status__c='A' AND Purpose__c LIKE '%WHERE TO BUY%' AND ShippingCountry='US' AND recordtypeId = :retailRecordTypeId AND DISTANCE(billingaddress, GEOLOCATION(:lat,:lon), 'mi') < :bwcmdt.Store_Search_Distance__c];
            List<Store_Hours__c> allStHours = [SELECT Id, Name,Account__c, Account__r.Name,  Type__c, DayOfWeek__c, Start_Time__c , End_Time__c FROM Store_Hours__c];
            List<Dealer_Promotion__c> allDealerPromotions = [SELECT Id, Name, Account__c, IsActive__c, Promotion__c, Promotion_Terms__c, PromotionExpirationDate__c, PromotionStartDate__c  FROM Dealer_Promotion__c WHERE IsActive__c = true];
            List<Service_Offered__c> allServiceOffered = [SELECT Id, Dealer_Account__c, Service__c FROM Service_Offered__c];
            Map<String, List<BWC_StoreHour>> mapStHours = getMappedStoreInfo(allStHours);
            Map<String, List<BWC_DealerPromotion>> mapDealerPromotions = getMappedDealerPromotionsInfo(allDealerPromotions);
            Map<String, List<BWC_OfferedSevices>> mapServiceOffered = getMappedServiceOfferedInfo(allServiceOffered);
            List<BWC_AccountWithLocation> res= new List<BWC_AccountWithLocation>();
            for(Account item: data) {
                List<BWC_StoreHour> stHours = mapStHours.get(item.Id + '$');
                List<BWC_DealerPromotion> dealerPromotions = mapDealerPromotions.get(item.Id + '$');
                List<BWC_OfferedSevices> serviceOffered = mapServiceOffered.get(item.Id + '$');
                res.add(new BWC_AccountWithLocation(item,stHours,dealerPromotions,serviceOffered,BWC_LeadExchangeHelper.calculateHaversineDistance(lat, lon, item.ShippingLatitude, item.ShippingLongitude)));
            }
            return res;
        } catch(Exception ex) {
            throw ex;
        }
    }
    
    /**
    * @description : Apex method to get mapped details of store info
    */
    public static Map<String, List<BWC_StoreHour>> getMappedStoreInfo(List<Store_Hours__c> allStHours) {
        	Map<String, List<BWC_StoreHour>> mapStHours = new Map<String, List<BWC_StoreHour>> ();
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
                
                if(!mapStHours.containsKey(sth.Account__c + '$')){
                    BWC_StoreHour updatehr = new BWC_StoreHour(sth.DayOfWeek__c, strStartTime, strEndTime,sth.Start_Time__c, sth.End_Time__c, sth.Type__c);
                    mapStHours.put(sth.Account__c + '$', new List<BWC_StoreHour> { updatehr });
                }
                else {
                    BWC_StoreHour createhr = new BWC_StoreHour(sth.DayOfWeek__c, strStartTime, strEndTime,sth.Start_Time__c, sth.End_Time__c, sth.Type__c);
                    mapStHours.get(sth.Account__c + '$').add(createhr);
                }
            }
        	return mapStHours;
    }
    
    /**
    * @description : Apex method to get mapped details of dealer promotion
    */
	public static Map<String, List<BWC_DealerPromotion>> getMappedDealerPromotionsInfo(List<Dealer_Promotion__c> allDealerPromotions) {
        	Map<String, List<BWC_DealerPromotion>> mapDealerPromotions = new Map<String, List<BWC_DealerPromotion>> ();
            for(Dealer_Promotion__c dp: allDealerPromotions) {                
                if(!mapDealerPromotions.containsKey(dp.Account__c + '$')){ 
                    BWC_DealerPromotion updatedp = new BWC_DealerPromotion(dp.Name,dp.IsActive__c, dp.Promotion__c, dp.PromotionExpirationDate__c, dp.PromotionStartDate__c,dp.Promotion_Terms__c);
                    mapDealerPromotions.put(dp.Account__c + '$', new List<BWC_DealerPromotion> { updatedp });
                }
                else {
                    BWC_DealerPromotion createhr = new BWC_DealerPromotion(dp.Name,dp.IsActive__c, dp.Promotion__c, dp.PromotionExpirationDate__c, dp.PromotionStartDate__c,dp.Promotion_Terms__c);
                    mapDealerPromotions.get(dp.Account__c + '$').add(createhr);
                }
            }
        	return mapDealerPromotions;
    }
    
    /**
    * @description : Apex method to get mapped details of service offered
    */
    public static Map<String, List<BWC_OfferedSevices>> getMappedServiceOfferedInfo(List<Service_Offered__c> allServiceOffered) {
        	Map<String, List<BWC_OfferedSevices>> mapServiceOffered = new Map<String, List<BWC_OfferedSevices>> ();
            for(Service_Offered__c so: allServiceOffered) {                
                if(!mapServiceOffered.containsKey(so.Dealer_Account__c + '$')){ 
                    BWC_OfferedSevices updateso = new BWC_OfferedSevices(so.Service__c);
                    mapServiceOffered.put(so.Dealer_Account__c + '$', new List<BWC_OfferedSevices> { updateso });
                }
                else {
                    BWC_OfferedSevices createso = new BWC_OfferedSevices(so.Service__c);
                    mapServiceOffered.get(so.Dealer_Account__c + '$').add(createso);
                }
            }
        	return mapServiceOffered;
    }
}
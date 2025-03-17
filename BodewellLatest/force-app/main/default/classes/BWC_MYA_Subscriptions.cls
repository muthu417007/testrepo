/**
@description : Apex Class to handle mya subscription details
Author:       Akhil M R
Created Date: 08/02/2023
*/
public without sharing class BWC_MYA_Subscriptions { 
    
    /**
* @description : Response Class for BWC_MYA_Subscriptions
*/
    public class BWC_MYA_SubscriptionsResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public Object data;
        @AuraEnabled public Object error;
        
        public BWC_MYA_SubscriptionsResponse(Boolean success, Object data, Exception error) {
            this.success = success;
            this.data = data;
            this.error = error;
        }
    }
    
    /**
* @description : Response Class for getProductProtectionSubscription
*/
    public class BWC_MYA_ProtectionPlanResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public Object data;
        @AuraEnabled public Object error;
        
        public BWC_MYA_ProtectionPlanResponse(Boolean success, Object data, Exception error) {
            this.success = success;
            this.data = data;
            this.error = error;
        }
    }
    
    /**
* @description : Response Class for SubscriptionsInfo
*/
    public class SubscriptionsInfo {
        @AuraEnabled public Object accountInfo;
        @AuraEnabled public Object accSubInfo;
        @AuraEnabled public Object cardInfo;
        
        public SubscriptionsInfo(Object aInfo, Object subInfo, Object cInfo) {
            this.accountInfo = aInfo;
            this.accSubInfo = subInfo;
            this.cardInfo = cInfo;
        }
    }
    
    /**
* @description : Response Class for ProtectionPlanInfo
*/
    public class ProtectionPlanInfo {
        @AuraEnabled public Object bwcServiceInfo;
        
        public ProtectionPlanInfo(Object bwcServiceInfo) {
            this.bwcServiceInfo = bwcServiceInfo;
        }
    }
    
    /**
* @description : Response Class for ProtectionPlanInfo
*/
    public class ProtectionPlanInfoWrapper {
        @AuraEnabled public Object accountInfo;
        @AuraEnabled public Object accSubInfo;        
        @AuraEnabled public Object planInfo;
        @AuraEnabled public Object oderSummarysInfo;
        @AuraEnabled public Object cardInfo;
        
        public ProtectionPlanInfoWrapper(Object aInfo, Object subInfo, Object pinfo,Object opsInfo, Object cInfo) {
            this.accountInfo = aInfo;
            this.accSubInfo = subInfo;
            this.planInfo = pinfo;
            this.oderSummarysInfo = opsInfo;
            this.cardInfo = cInfo;
        }
    }
    
    /**
* @description : Response Class for SubscriptionPaymentsInfo
*/
    public class PaymentsInfo {
        @AuraEnabled public Object accountInfo;
        @AuraEnabled public Object accSubInfo;
        @AuraEnabled public Object paymentSummaryInfo;
        @AuraEnabled public Object cardInfo;
        
        public PaymentsInfo(Object aInfo, Object subInfo, Object pInfo, Object cInfo) {
            this.accountInfo = aInfo;
            this.accSubInfo = subInfo;
            this.paymentSummaryInfo = pInfo;
            this.cardInfo = cInfo;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static BWC_MYA_SubscriptionsResponse getBodewellSubscription(String userId){
        try{
            User u = getUserInfo(userId);
            Contact con = getContactInfo(u.ContactId); 
            Account acc = getAccountInfo(con.AccountId);
            if(acc.Bodewell_Member__c == true) {
                List<Subscription__c> accSub = getBodewellSubscriptionInfo(con.AccountId);
                List<OrderPaymentSummary> ops = getOPSInfo(accSub);
                List<CardPaymentMethod> cpm = getCPMInfo(ops);
                SubscriptionsInfo info = new SubscriptionsInfo(acc,accSub[0],cpm[0]);
                return new BWC_MYA_SubscriptionsResponse(true,info,Null);
            } else {
                SubscriptionsInfo info = new SubscriptionsInfo(acc,Null,Null);
                return new BWC_MYA_SubscriptionsResponse(true,info,Null);
            }
            //return new BWC_MYA_SubscriptionsResponse(true,Null,Null);
        }
        catch(Exception ex){
            return new BWC_MYA_SubscriptionsResponse(false,Null,ex);
        }
        
    } 
    
    @AuraEnabled(cacheable=false)
    public static BWC_MYA_ProtectionPlanResponse getProductProtectionSubscription(String userId){
        try{
            User u = getUserInfo(userId);
            Contact con = getContactInfo(u.ContactId); 
            Account acc = getAccountInfo(con.AccountId);
            //if(acc.Bodewell_Member__c == true) {
            List<Subscription__c> accSub = getProtectionPlanSubscriptionInfo(con.AccountId);
            ProtectionPlanInfo planInfo = getProtectionPlanInfo(accSub);
            List<OrderPaymentSummary> ops = getOPSInfo(accSub);
            List<CardPaymentMethod> cpm = getCPMInfo(ops);
            ProtectionPlanInfoWrapper wrapper = new ProtectionPlanInfoWrapper(acc,accSub,planInfo,ops,cpm);
            return new BWC_MYA_ProtectionPlanResponse(true,wrapper,Null);
            // } else {
            //     SubscriptionsInfo info = new SubscriptionsInfo(acc,Null,Null);
            //     return new BWC_MYA_SubscriptionsResponse(true,info,Null);
            // }
            //return new BWC_MYA_ProtectionPlanResponse(true,Null,Null);
        }
        catch(Exception ex){
            return new BWC_MYA_ProtectionPlanResponse(false,Null,ex);
        }
        
    }
    
    @AuraEnabled(cacheable=false)
    public static BWC_MYA_SubscriptionsResponse getBodewellSubscriptionPayments(String userId){
        try{
            User u = getUserInfo(userId);
            Contact con = getContactInfo(u.ContactId); 
            Account acc = getAccountInfo(con.AccountId);
            if(acc.Bodewell_Member__c == true) {
                List<Subscription__c> accSub = getBodewellSubscriptionInfo(con.AccountId);
                List<OrderPaymentSummary> ops = getOPSInfo(accSub);
                List<CardPaymentMethod> cpm = getCPMInfo(ops);
                PaymentsInfo info = new PaymentsInfo(acc,accSub,ops,cpm);
                return new BWC_MYA_SubscriptionsResponse(true,info,Null);
            } else {
                PaymentsInfo info = new PaymentsInfo(acc,Null,Null,Null);
                return new BWC_MYA_SubscriptionsResponse(true,info,Null);
            }
            //return new BWC_MYA_SubscriptionsResponse(true,Null,Null);
        }
        catch(Exception ex){
            return new BWC_MYA_SubscriptionsResponse(false,Null,ex);
        }
        
    }     
    
    public static User getUserInfo(String userId) {
        User uInfo=[SELECT Id, ContactId from User WHERE id=:userId];
        return uInfo;
    }
    
    //Agent I
    @AuraEnabled(cacheable = true)
    public static User getUserInfoViaAccountId(String accountId){
        User uInfo=[SELECT Id,
                    ContactId
                    FROM User 
                    WHERE AccountId=:accountId];
        return uInfo;
    }
    
    public static Contact getContactInfo(String conId) {
        Contact cInfo=[SELECT Id, AccountId FROM Contact WHERE Id=:conId];
        return cInfo;
    }
    
    public static Account getAccountInfo(String accId) {
        Account accInfo = [SELECT id , Bodewell_Member_Start_Date__c, Bodewell_Member_Expiration_Date__c,Bodewell_Member__c , Name 
                           FROM Account 
                           WHERE Id=:accId];
        return accInfo;
    }
    
    public static List<Subscription__c> getBodewellSubscriptionInfo(String accId) {
        List<Subscription__c> accSubInfo = [SELECT Id, Order__c, Bodewell_Member_Exp_Date__c, Bodewell_Member_Start_Date__c, Order_Product__c, Order_Product__r.Product2.Name, Order_Product__r.Product2.BWC_Main_Image__c, Order_Product__r.UnitPrice
                                            FROM Subscription__c 
                                            WHERE Account__c=:accId AND Type__c = 'Membership'
                                            ORDER BY CreatedDate DESC];
        return accSubInfo;
        //return null;
    }
    
    public static List<Subscription__c> getProtectionPlanSubscriptionInfo(String accId) {
        List<Subscription__c> accSubInfo = [SELECT Id, Order__c, Order_Product__c, Order_Product__r.cart_Item_Id__c, Order_Product__r.Product2.Name, Order_Product__r.Product2.BWC_Main_Image__c, Order_Product__r.Product2.BWC_Product_Marketing_Description__c, Order_Product__r.Product2.StockKeepingUnit,Order_Product__r.UnitPrice, Order_Product__r.BWC_Start_Date__c 
                                            FROM Subscription__c 
                                            WHERE Account__c=:accId AND Type__c = 'Protection Plan'
                                            ORDER BY CreatedDate DESC];
        return accSubInfo;
        //return null;
    }    
    
    public static ProtectionPlanInfo getProtectionPlanInfo(List<Subscription__c> accSubInfo) {
        Set<String> cartIds = new Set<String>();
        for (Subscription__c accSub : accSubInfo) {
            if(accSub.Order_Product__r.cart_Item_Id__c != Null) {
                cartIds.add(accSub.Order_Product__r.cart_Item_Id__c);
            }
        }
        List<BWC_Product_Service__c> bwcService = [SELECT Id, Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c, BWC_Service_Type__c, BWC_SKU__c 
                                                   FROM BWC_Product_Service__c 
                                                   WHERE Cart_Item__c IN : cartIds
                                                   ORDER BY CreatedDate DESC];
        ProtectionPlanInfo planInfo = new ProtectionPlanInfo(bwcService);
        return planInfo;
        //return null;
    }      
    
    public static List<OrderPaymentSummary> getOPSInfo(List<Subscription__c> accSubs) {          
        Set<String> orders = new Set<String>();
        for (Subscription__c sub : accSubs) {
            orders.add(sub.Order__c);
        }
        List<OrderPaymentSummary> opsInfo = [SELECT Id, PaymentMethodId, OrderSummary.OriginalOrderId 
                                             FROM OrderPaymentSummary 
                                             WHERE OrderSummary.OriginalOrderId IN : orders];
        return opsInfo;
    }
    
    public static List<CardPaymentMethod> getCPMInfo(List<OrderPaymentSummary> ops) {          
        Set<String> paymentMethodIdIds = new Set<String>();
        for (OrderPaymentSummary opitem : ops) {
            paymentMethodIdIds.add(opitem.PaymentMethodId);
        }
        List<CardPaymentMethod> cpmInfo = [SELECT Id, CardCategory, CardType,  CardHolderName, DisplayCardNumber 
                                           FROM CardPaymentMethod 
                                           WHERE Id IN : paymentMethodIdIds];
        return cpmInfo;
    }
    
}
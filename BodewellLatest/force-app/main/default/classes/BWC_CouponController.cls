public with sharing class BWC_CouponController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> checkCouponExistance(String couponCode) {
        Map<String, Object> result = new Map<String, Object>();
        
        // Query the coupon record based on the coupon code
        Coupon coupon = [SELECT Id, Name, PromotionId, Status, StartDateTime, EndDateTime  FROM Coupon WHERE CouponCode = :couponCode LIMIT 1];
        
        if (coupon != null) {
            result.put('exists', true);
            result.put('couponName', coupon.Name);
            result.put('couponStatus', coupon.Status);
            result.put('couponStartDateTime', coupon.StartDateTime);
            result.put('couponEndDateTime', coupon.EndDateTime);
            
        } else {
            result.put('exists', false);
        }
        
        return result;
    }
    }
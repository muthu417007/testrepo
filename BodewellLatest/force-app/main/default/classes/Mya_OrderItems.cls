//******************************************************************************************
//Name : Mya_OrderItems
//Requirement : To display Orders data on My Orders 
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//  Version		Author			Date		        Detail
//  1.0			Yogesh Sharma		07/11/2022		Initial
//  2.0			Yogesh Sharma		17/01/2024		Updated.
//******************************************************************************************
//@description : Wrapper Class to handle Orders data 
public without sharing class Mya_OrderItems 
{
        @AuraEnabled Public String OrderNumber;
        @AuraEnabled Public String OrderRefNumber;
        @AuraEnabled Public Date OrderDate;
        @AuraEnabled Public Date RequestDate;
        @AuraEnabled Public Decimal OrderTotal = 0;
        @AuraEnabled Public String OrderTotalString;
        @AuraEnabled Public Decimal OrderDiscount = 0;
        @AuraEnabled Public String OrderDiscountString;
        @AuraEnabled Public Decimal OrderDeliveryCharge = 0.00;
        @AuraEnabled Public String OrderDeliveryChargeString;
        @AuraEnabled Public Decimal OrderShippingCharge = 0.00;
        @AuraEnabled Public String OrderShippingChargeString;
        @AuraEnabled Public Decimal OrderSubTotal = 0;
        @AuraEnabled Public String OrderSubTotalString;
        @AuraEnabled Public Decimal OrderTax = 0;
        @AuraEnabled Public String OrderTaxString;
        @AuraEnabled Public String OrderStatus;
        @AuraEnabled Public String CustName;
        @AuraEnabled Public String CustPhone;
        @AuraEnabled Public String CustEmail;
        @AuraEnabled Public String ShippingMethod;
        @AuraEnabled Public String ShipAddLine1; //Address1 + Address2 + Address3 + Address4
        @AuraEnabled Public String ShipAddLine2; //City + State + Country + Zip
        @AuraEnabled Public String BillAddLine1; //Address1 + Address2 + Address3 + Address4
        @AuraEnabled Public String BillAddLine2; //City + State + Country + Zip
        @AuraEnabled Public String ShipZip;
        @AuraEnabled Public String DeliveryInfoURL;
        @AuraEnabled Public String RescheduleURL;
        @AuraEnabled Public String TrackMyOrderURL;
        @AuraEnabled Public String PartsReturnURL;
        @AuraEnabled Public String PartsStatusURL;
        @AuraEnabled Public String OrderType;
        @AuraEnabled Public String OrderId;
        @AuraEnabled Public List<Mya_LineItems> LineItemList;
        @AuraEnabled Public Boolean ShipMetHomDelFlag;
        @AuraEnabled Public Boolean OrderStatusCompFlag;
        @AuraEnabled Public Boolean OrderStatusCancelFlag;
        @AuraEnabled Public Boolean OrderStatusPendFlag;
        @AuraEnabled Public Boolean ShowReschedule;
        @AuraEnabled Public Boolean ShowTrackMyOrder;
        @AuraEnabled Public Boolean ShowReturn;
        @AuraEnabled Public Boolean BackOrderFlag;
        @AuraEnabled Public Boolean FGOrderFlag;
        @AuraEnabled Public Boolean MixedShipFlag;
        @AuraEnabled Public Boolean TextTrackFlag;
        @AuraEnabled Public Boolean OrdDiscFlag;
        @AuraEnabled Public Boolean OrderDeliveryChargeFlag;
    	@AuraEnabled Public Boolean IsOrderAwaitingShippingFlag;
    	@AuraEnabled Public Boolean IsOrderAwaitingReturnFlag;
		@AuraEnabled Public Date OrderShipDate;
    	@AuraEnabled Public Boolean isCROrder;//Changes part of CCOE-1134
}
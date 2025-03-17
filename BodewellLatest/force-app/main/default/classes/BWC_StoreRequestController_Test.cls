/**
@description : Test Class for BWC_StoreRequestController
Author:       Akhil M R
Company:      TCS
Created Date: 11/06/2023
*/
@isTest
private class BWC_StoreRequestController_Test {
    
    /**
	* @description : Apex method to test request coupon method
	*/
    @isTest
    static void requestCouponConsumerTest()
    {
        Account testConsAcct = new Account(RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),Email__c='test@test.com', FirstName='First', LastName='Last');
        insert testConsAcct;
        Account testAcct = new Account(Name = 'Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),BillingLatitude=35.2154970802915,BillingLongitude = -80.98783181970849);
        insert testAcct;        
        BuyerGroup testgb = new BuyerGroup(Name = 'Bodewell Lead Exchange Buyer Group');
        insert testgb;        
        Product2 prod = new Product2(Name='Test Product',Item_Number__c='123123');
        insert prod;
        BWC_StoreRequestController.BWC_StoreRequestResponse res = BWC_StoreRequestController.requestCoupon('First','Last','test@test.com','1231231234','2023-12-13','09:30:00.000',true,testAcct.Id,prod.Id);
        System.AssertEquals(true, res.success, 'Test Passed');
    }
    
    /**
	* @description : Apex method to test request coupon method
	*/
    @isTest
    static void requestCouponTest()
    {
        Account testAcct = new Account(Name = 'Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),BillingLatitude=35.2154970802915,BillingLongitude = -80.98783181970849);
        insert testAcct;        
        BuyerGroup testgb = new BuyerGroup(Name = 'Bodewell Lead Exchange Buyer Group');
        insert testgb;        
        Product2 prod = new Product2(Name='Test Product',Item_Number__c='123123');
        insert prod;
        BWC_StoreRequestController.BWC_StoreRequestResponse res = BWC_StoreRequestController.requestCoupon('First','Last','test@test.com','1231231234','2023-12-13','09:30:00.000',true,testAcct.Id,prod.Id);
        System.AssertEquals(true, res.success, 'Test Passed');
    }
    
    /**
	* @description : Apex method to test request coupon method failure
	*/
    @isTest
    static void requestCouponFailingTest()
    {
        BuyerGroup testgb = new BuyerGroup(Name = 'Bodewell Lead Exchange Buyer Group');
        insert testgb;
        BWC_StoreRequestController.BWC_StoreRequestResponse res = BWC_StoreRequestController.requestCoupon('First','Last','test@test.com','1231231234','2023-12-13','09:30:00.000',true,'invalid account id',null);
        System.AssertEquals(false, res.success, 'Test Passed');
    }
    
    /**
	* @description : Apex method to test request coupon method with product
	*/
    @isTest
    static void requestCouponWithProductTest2()
    {
        BuyerGroup testgb = new BuyerGroup(Name = 'Bodewell Lead Exchange Buyer Group');
        insert testgb;
        Product2 prod = new Product2(Name='Test Product',Item_Number__c='123123');
        insert prod;
        BWC_StoreRequestController.BWC_StoreRequestResponse res = BWC_StoreRequestController.requestCoupon('First','Last','test@test.com','1231231234','2023-12-13','09:30:00.000',true,'invalid account id',prod.Id);
        System.AssertEquals(false, res.success, 'Test Passed');
    }
}
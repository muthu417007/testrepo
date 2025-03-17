/**
@description : Test Class for BWC_LeadExchangeEmailHelper
Author:       Akhil M R
Company:      TCS
Created Date: 23/10/2023
*/
@isTest
private class BWC_LeadExchangeEmailHelper_Test {
    
    /**
    * @description : Test Class for data encryption
    */
	@isTest
    static void encryptionTest1() {
        Account testAcct = new Account(Name = 'Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),BillingLatitude=35.2154970802915,BillingLongitude = -80.98783181970849);
        insert testAcct; 
        Store_Hours__c testStHour = new Store_Hours__c(Name='Test ST', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour; 
        Dealer_Promotion__c testdp = new Dealer_Promotion__c(Name ='Test', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp; 
        Service_Offered__c testso = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Delivery & Installation');
        insert testso;            	
      	Referral__c testRef = new Referral__c(Name ='Test',Coupon_Code__c = 'testcoupon',Partner_Account__c = testAcct.Id);
        insert testRef;
        Test.startTest();
        String encryptedCode = BWC_LeadExchangeHelper.getEncrypetedText(testRef.Id);  
        String invalidencryptedCode = BWC_LeadExchangeHelper.getEncrypetedText('testRefId');  
        BWC_LeadExchangeEmailHelper.BWC_LeadExchangeEmailHelperResponse res = BWC_LeadExchangeEmailHelper.getCouponCode(encryptedCode);        
        System.AssertEquals(true, res.success, 'Test Passed');
        Test.stopTest();
    }
    
    /**
    * @description : Test Class for data encryption using standard user
	*/    
    @isTest
    static void invalidUserTest()
    {
        Account testAcct = new Account(Name = 'Test Acct ',Party_Name__c='Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct; 
        Store_Hours__c testStHour = new Store_Hours__c(Name='Test ST', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour; 
        Dealer_Promotion__c testdp = new Dealer_Promotion__c(Name ='Test', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp; 
        Service_Offered__c testso = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Delivery & Installation');
        insert testso;                     	
      	Referral__c testRef = new Referral__c(Name ='Test',Coupon_Code__c = 'testcoupon',Partner_Account__c = testAcct.Id);
        insert testRef;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName);
        
        Test.startTest();
        	System.runAs(u) {
           		String encryptedCode = BWC_LeadExchangeHelper.getEncrypetedText(testRef.Id);  
                String invalidencryptedCode = BWC_LeadExchangeHelper.getEncrypetedText('testRefId');  
                BWC_LeadExchangeEmailHelper.BWC_LeadExchangeEmailHelperResponse res = BWC_LeadExchangeEmailHelper.getCouponCode(encryptedCode);        
               	System.assertEquals(false, res.success, 'Test Passed');
            }
      	Test.stopTest();
    }
    
    /**
    * @description : Test Class for flow encryption
    */
    @isTest
    static void emailLinkTest(){
      	Referral__c testRef = new Referral__c(Name ='Test',Coupon_Code__c = 'testcoupon');
        insert testRef;
        BWC_LeadExchangeEmailHelper.CouponLinkFlowRequest input = new BWC_LeadExchangeEmailHelper.CouponLinkFlowRequest();
        input.RecordId=testRef.Id;
        Test.startTest();
        List<BWC_LeadExchangeEmailHelper.CouponLinkFlowResponse> res = BWC_LeadExchangeEmailHelper.getCouponLink(
            new List<BWC_LeadExchangeEmailHelper.CouponLinkFlowRequest>{input}
        );
        String recId = BWC_LeadExchangeHelper.getDecrypetedText(res[0].CouponLink.Split('ref=')[1]);
        System.AssertEquals(testRef.Id, recId, 'Test Passed');
        Test.stopTest();
    }
    
    /**
    * @description : Test Class for flow encryption failure
    */
    @isTest
    static void emailLinkFailingTest(){
      	//Account testData = new Account(Name ='Test');
        //insert testData;
        BWC_LeadExchangeEmailHelper.CouponLinkFlowRequest input = new BWC_LeadExchangeEmailHelper.CouponLinkFlowRequest();
        //input.RecordId=testData.Id;
        Test.startTest();
        List<BWC_LeadExchangeEmailHelper.CouponLinkFlowResponse> res = BWC_LeadExchangeEmailHelper.getCouponLink(
            new List<BWC_LeadExchangeEmailHelper.CouponLinkFlowRequest>{input}
        );
        List<BWC_LeadExchangeEmailHelper.CouponLinkFlowResponse> flowRes = new List<BWC_LeadExchangeEmailHelper.CouponLinkFlowResponse>();
        System.AssertEquals(flowRes, res, 'Test Passed');
        Test.stopTest();
    }
}
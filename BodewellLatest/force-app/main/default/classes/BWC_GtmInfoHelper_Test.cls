/**
@description : Test Class for BWC_GtmInfoHelper
Author:       Akhil M R
Company:      TCS
Created Date: 25/10/2023
*/
@isTest
private  class BWC_GtmInfoHelper_Test {
	/**
    * @description : Apex method to test place suggestions and detail requests
    */
    @isTest
    static void getProductTypeTest()
    {
        Product2 testprd = new Product2(Name='Test', Item_Number__c='testid');
        insert testprd;   
        Test.startTest();
            BWC_GtmInfoHelper.BWC_GtmInfoHelperResponse res = BWC_GtmInfoHelper.getProductType(testprd.Id);
        	System.AssertEquals(true, res.success, 'Test Passed');
       	Test.stopTest();
    }
    
    /**
    * @description : Apex method to test place suggestions and detail requests
    */
    @isTest
    static void getProductTypeTest2()
    {
        Product2 testprd = new Product2(Name='Test', Item_Number__c='testid');
        insert testprd;   
        Test.startTest();
            BWC_GtmInfoHelper.BWC_GtmInfoHelperResponse res = BWC_GtmInfoHelper.getProductType('testprdId');
        	System.AssertEquals(false, res.success, 'Test Passed');
       	Test.stopTest();
    }
}
@isTest
private class BWC_LeadExchangeHelper_Test {
	
    //@description : Apex method to test place suggestions and detail requests
    @isTest
    static void test1()
    {
        Decimal res = BWC_LeadExchangeHelper.calculateHaversineDistance(35.21518898029149,-80.98752201970849,35.2154970802915,-80.98783181970849);
        System.AssertEquals(0.027549698680457434, res, 'Test Passed');
    }
    
    @isTest
    static void test2()
    {
        string res = BWC_LeadExchangeHelper.getGuId();
        Bodewell_Lead_Exchange__mdt mdt = BWC_LeadExchangeHelper.getBodewellLeadExchangeMetaData();
    }
    
    @isTest
    static void test3()
    {
        string testText = 'Test Text';
        string encRes = BWC_LeadExchangeHelper.getEncrypetedText(testText);
        string decRes = BWC_LeadExchangeHelper.getDecrypetedText(encRes);
        System.AssertEquals(testText,decRes,'Test Passed');        
    }
}
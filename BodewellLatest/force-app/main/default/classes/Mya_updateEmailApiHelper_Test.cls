@isTest
private class Mya_updateEmailApiHelper_Test 
{
    private class Mya_updateEmailApiHelperResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('Success');
            res.setStatusCode(200);
            return res;
            }
    }
        
     @isTest
    static void testMya_updateEmailApiHelper()
    {
        List<Mya_updateEmailApiHelper.Mya_updateEmailApi> testEmails = new List<Mya_updateEmailApiHelper.Mya_updateEmailApi>();
        Mya_updateEmailApiHelper.Mya_updateEmailApi testEmail = new Mya_updateEmailApiHelper.Mya_updateEmailApi();
        testEmail.gcid='12345';
        testEmail.newEmail='test123@test.com';
        testEmail.oldEmail='test321@test.com';
        testEmails.add(testEmail);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mya_updateEmailApiHelperResponseGenerator());
        Mya_updateEmailApiHelper.updateEmailDB(testEmails);
        
        Test.stopTest();
        
    } 

}
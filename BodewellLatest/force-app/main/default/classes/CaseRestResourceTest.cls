@IsTest
private class CaseRestResourceTest {
    @IsTest
    static void testCaseRestAPI(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();        
        req.requestURI = '/Case';  //Request URL
        req.httpMethod = 'GET';
        req.params.put('caseNumber','ABC123');
        req.params.put('startTime','2019-10-30 12:22:35.000+0000');
        req.params.put('endTime','2019-10-30 12:22:35.000+0000');
        RestContext.request = req;
        CaseRestResource.doGet();
    }
    
    @TestSetup
    static void setupData(){
        Case c = new Case(Subject='Test');
        insert c;
    }
}
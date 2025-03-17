@isTest
public class ChatEstimatedWaitTimeTest {

    @isTest
    static void makeGetCalloutTest(){
        
        Test.setMock(HttpCalloutMock.class, new ChatTranscriptApiResponse());
        Test.startTest();
        List<List<String>> idsInput = new List<List<String>>();
        List<String> ids = new List<String>();
        ids.add('5734P000000Ps5s');
        ids.add('5724P000000PqVH');
        idsInput.add(ids);
        
        List<Integer> resp = ChatEstimatedWaitTime.makeGetCallout(idsInput);
        Test.stopTest();
        system.assertNotEquals(null, resp, 'Response not null');
    }
    
    public class ChatTranscriptApiResponse implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('{"messages":[{"type":"Availability", "message":{"results":[{"estimatedWaitTime":36,"id":"5734P000000Ps5s","isAvailable":true}]}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}
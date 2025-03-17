/*
 * @description VA_RequestEndecaApiDataTest test class for VA_RequestEndecaApiData
 */
@isTest
public class VA_RequestEndecaApiDataTest {
    static testmethod void getAnalyticsDataTest(){
        Test.setMock(HttpCalloutMock.class, new ChatApiResponse());
        Test.startTest();
        String resp = VA_RequestEndecaApiData.EndecaData('IM4A');
        Test.stopTest();
        system.assertNotEquals('[]', resp,'response not empty');
    }
    /*
     * @description ChatApiResponse mock response class
     */
    public class ChatApiResponse implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('["filters": { "rec":"test"}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
}
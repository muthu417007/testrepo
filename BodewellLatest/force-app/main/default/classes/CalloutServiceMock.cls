public class CalloutServiceMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        // Mock the response when the external service is down
        HttpResponse response = new HttpResponse();
        
        response.setStatusCode(503);
        return response;
    }

}
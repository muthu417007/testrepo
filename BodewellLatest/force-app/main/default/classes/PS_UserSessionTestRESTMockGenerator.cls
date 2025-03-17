public with sharing class PS_UserSessionTestRESTMockGenerator implements HttpCalloutMock {

    private Boolean isSuccess;

    public PS_UserSessionTestRESTMockGenerator(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        if (isSuccess) {
            response.setStatusCode(200);
            response.setStatus('success');
        } else {
            response.setStatusCode(500);
            response.setStatus('error');
        }
        return response;
    }
}
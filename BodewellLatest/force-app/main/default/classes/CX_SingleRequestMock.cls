/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        01.06.2021
 * @description    Class that makes mocking a HTTP request easier, use with CX_MultiRequestMock when multiple mocks are necessary
 */
@isTest
public class CX_SingleRequestMock implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Constructor for a String body
     * @param          Integer - The mock http status code
     * @param          String - The mock http status
     * @param          String - The mock response body
     * @param          Map<String, String> - The response headers
     */
    public CX_SingleRequestMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
    }
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Constructor for a Blob body
     * @param          Integer - The mock http status code
     * @param          String - The mock http status
     * @param          Blob - The mock response body
     * @param          Map<String, String> - The response headers
     */
    public CX_SingleRequestMock(Integer code, String status, Blob body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsBlob = body;
        this.bodyAsString = null;
        this.responseHeaders = responseHeaders;
    }
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Method called by the platform to mock a Http request in tests
     * @param          HTTPRequest - The request to be mocked
     * @return         HTTPResponse - The mock response
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);
        
        if (bodyAsBlob != null) {
            resp.setBodyAsBlob(bodyAsBlob);
        } 
        else {
            resp.setBody(bodyAsString);
        }
        
        if (responseHeaders != null) {
            for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
            }
        }

        return resp;
    }
}
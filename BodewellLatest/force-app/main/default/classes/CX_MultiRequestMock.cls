/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        01.06.2021
 * @description    Class that allows multiple HTTP mocks to be used in a single test, should be used with the CX_SingleRequestMock
 */
@IsTest
public class CX_MultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Constructor with 1 parameter
     * @param          Map<String, HttpCalloutMock> - A map of mock by endpoint called
     */
    public CX_MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Method called by the platform to mock a Http request in tests, looks for the right mock in the map passed in the constructor
     * @param          HTTPRequest - The request to be mocked
     * @return         HTTPResponse - The mock response
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());

        if (mock != null) {
            return mock.respond(req);
        } 
        
        throw new MultiRequestMockException('HTTP callout not supported for test methods');
    }
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Method to add mocks to the request map
     * @param          String - The requests URL
     * @param          HttpCalloutMock - The mock to be used
     */
    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }

    public class MultiRequestMockException extends Exception {}
}
public class MockHttpResponseGeneratorForDisplayBtn implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response with your desired data
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"availabilityDetails": [{"availableQuantity": 10, "errorCode": 0}], "ADC_WrapperResponse":[{"adcOrg": "TestADC"}]');
        res.setStatusCode(200);
        return res;
    }
}
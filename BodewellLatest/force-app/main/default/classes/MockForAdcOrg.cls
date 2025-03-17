public class MockForAdcOrg {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response with your desired data
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ADC_WrapperResponse": [{"adcOrg": 12345}]}');
        res.setStatusCode(200);
        return res;
    }
}
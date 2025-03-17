global class OCRCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        String responseBodyMock = '{"object":"predictresponse","probabilities":[{"probability":0.37609568,"label":"JGB700SEJSS","boundingBox":{"minX":25,"minY":0,"maxX":188,"maxY":98},"attributes":{"pageNumber":"1"}}],"task":"text"}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBodyMock);
        res.setStatusCode(200);
        return res;
    }
}
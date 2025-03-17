public with sharing class PS_JWTServiceMockGenerator implements HttpCalloutMock{

    PS_OAuthAccessTokenWrapper OAuthResponseData;
    PS_BigCommerceUserManagementService.CustomerAPIResponseWrapper bigCommerceGETResponseData;
    PS_BigCommerceUserManagementService.CustomerAPIResponseWrapper bigCommercePOSTResponseData;

    public PS_JWTServiceMockGenerator(
            PS_OAuthAccessTokenWrapper oAuthResponseData,
            PS_BigCommerceUserManagementService.CustomerAPIResponseWrapper bigCommerceGETResponseData,
            PS_BigCommerceUserManagementService.CustomerAPIResponseWrapper bigCommercePOSTResponseData
    ) {
        this.OAuthResponseData = oAuthResponseData;
        this.bigCommerceGETResponseData = bigCommerceGETResponseData;
        this.bigCommercePOSTResponseData = bigCommercePOSTResponseData;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('success');

        if(request.getEndpoint().contains('/services/oauth2/token')){
            response.setBody(JSON.serialize(this.OAuthResponseData));
        }else if(request.getMethod() == 'GET'){
            response.setBody(JSON.serialize(this.bigCommerceGETResponseData));
        }else if(request.getMethod() == 'POST'){
            response.setBody(JSON.serialize(this.bigCommercePOSTResponseData));
        }

        return response;
    }
}
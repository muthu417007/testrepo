/**
   * @description created by : Santhosh Kanne
   * Test class : VA_RequestEndecaApiDataTest
*/
public without sharing class VA_RequestEndecaApiData {
    /**
	 * @description Method to get Equipment info from endeca.
	 * @param SKU
	 * @return returns EndecaAPI response.
	*/
	@AuraEnabled
    public static String EndecaData(String SKU)
    {
        try {
            if(SKU != '') {
                String domainUrl = Url.getOrgDomainUrl().getHost();
                MYA_Configuration__mdt myaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
                String jwt = getJWT.generateJWTToken(myaConfig.Endeca_API_Client_Id__c,myaConfig.Endeca_API_Type__c,120,myaConfig.Endeca_API_Client_Secret__c);
                String token =jwt;
                Http httpCall = new Http();
                HttpRequest request = new HttpRequest();
                request.setMethod('GET');
                request.setEndpoint(myaConfig.Endeca_API_Endpoint__c + SKU);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                request.setHeader('Authorization',token);
                request.setTimeout(60000);
                HttpResponse response ;
                response = httpCall.send(request);
                if(response.getStatusCode() == 200) {
                    System.debug('response is'+response.getBody());
                    return response.getBody();
                 }
                    
                                            
            }
            
        } catch (Exception e) {
            throw e;
        } 
        return '{results: [] }';
    }
    
}
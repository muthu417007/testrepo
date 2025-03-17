public class RequestMuleAPIData {
    @AuraEnabled
	public static String getMuleToken(String url,String API_Name){       
        Http httpToken = new Http();
        HttpRequest requestToken = new HttpRequest();
        
        requestToken.setEndpoint('callout:'+url);
        
        requestToken.setMethod('POST');
        requestToken.setHeader('Content-Type', 'application/json');
        Mule_Data_Token_Credentials__mdt settings = [SELECT  audience__c,client_id__c,client_secret__c 
                                 From Mule_Data_Token_Credentials__mdt 
                                 Where DeveloperName = :API_Name LIMIT 1];
		
        String postBodyToken = '{"client_id":"' + settings.client_id__c + 
            '","client_secret":"' + settings.client_secret__c + 
            '","audience":"' + settings.audience__c + '","grant_type":"client_credentials"}';
        
        requestToken.setBody(postBodyToken);
        requestToken.setTimeout(25000);
        HttpResponse responseToken;
        if(!test.isRunningTest()){
        responseToken = httpToken.send(requestToken);
        }
        else {
            responseToken = new HttpResponse();
            responseToken.setStatusCode(200);
            String testBody = '{"access_token": "ue1cpp06hcr8nm","scope": "read:person read:location ","expires_in": 3600, "token_type": "Bearer"}';
            responseToken.setBody(testBody);
        }
		GEAoAuthResponse  resp;
        if (responseToken.getStatusCode() == 200) {
            //System.debug(responseToken.getBody());
            resp = GEAoAuthResponse.parse(responseToken.getBody());
            System.debug('token is:  '+resp.access_token);
            return resp.access_token;
        } else {
            system.debug('The status code returned was not expected: ' +
            responseToken.getStatusCode() + ' ' + responseToken.getStatus());
            //String message = 'Error ' + responseToken.getStatusCode() + ' ' + responseToken.getStatus();
            return 'Error ' + responseToken.getStatusCode() + ' ' + responseToken.getStatus();  
        }
    }
    @AuraEnabled
    public Static String getMuleAPIData(String TokenUrl, String TokenAPIName, String DataUrl, String ExtraUrl, String DatareqMethod, String body){
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        
        String Token=getMuleToken(TokenUrl,TokenAPIName);
        if(ExtraUrl!=null){
        	request.setEndpoint('callout:'+DataUrl+ExtraUrl); 
        }
        else {
            request.setEndpoint('callout:'+DataUrl);
        }
        request.setMethod(DatareqMethod);
        Mule_Data_Token_Credentials__mdt data_auth = [SELECT  data_client_id__c,data_client_secret__c,Api_Test_Response__c 
                                 From Mule_Data_Token_Credentials__mdt 
                                 Where DeveloperName = :TokenAPIName LIMIT 1];
        request.setHeader('client_id', data_auth.data_client_id__c);
        request.setHeader('client_secret', data_auth.data_client_secret__c);                       
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+Token);  
        if(body!=null){
        	request.setBody(body);
        }
        request.setTimeout(60000);
        HttpResponse response;
        if(!test.isRunningTest()){
        	response = httpCall.send(request);
        }
        else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testbody = data_auth.Api_Test_Response__c;
            response.setBody(testbody);
        }
        if (response.getStatusCode() == 200) {
            //System.debug(response.getBody());
            return response.getBody();
            
        } else {
            system.debug('The status code returned was not expected: '+response.getStatusCode() + ' ' + response.getStatus());
            //String message = 'Error ' + response.getStatusCode() + ' ' + response.getStatus();
            return 'Error ' + response.getStatusCode() + ' ' + response.getStatus();
        }
        
    }

}
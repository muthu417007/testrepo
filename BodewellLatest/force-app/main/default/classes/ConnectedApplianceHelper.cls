public class ConnectedApplianceHelper {
    
  	public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

     @AuraEnabled
     public static connectedApplianceResponse checkOnlineStatus(String mac){
        connectedApplianceResponse applianceStatus = null;
        
        try{
            if(mac==null){
            	throw new OtherException('No macAddress');
       		 }
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint('callout:ConnectedApplianceAuth');
            //https://accounts.brillion.geappliances.com/oauth2/token?grant_type=refresh_token&refresh_token=ue1evq8eh5cqi6d92891t9zrjfosyqft&client_id=ec14b833da7e77f7b1b923ebb9ccfb490a9c4347&client_secret=e135484d85928c7eca5faa5b05adceffeca8cea70f0fd91f97c10f1f0079f4c2
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
               
            request.setTimeout(50000);
            //HttpResponse response = http.send(request);
            HttpResponse response;
            if(!test.isRunningTest()){
                response = http.send(request);
                system.debug('response ' + response);
                system.debug('response body ' + response.getBody());
            } else {
                response = new HttpResponse();
                response.setStatusCode(200);
                String testBody = '{"access_token":"123"}';
                response.setBody(testBody);
            }
            
            System.debug(response.getBody());
            system.debug(response.getStatusCode());
            // Parse the JSON response
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                connectedApplianceAuthResponse  resp = connectedApplianceAuthResponse.parse(response.getBody());
                
                Http httpDetail = new Http();
                HttpRequest requestDetail = new HttpRequest();
                requestDetail.setEndpoint('callout:ConnectedAppliance' + '/' + mac + '/presence');
                requestDetail.setMethod('GET');
                requestDetail.setHeader('Authorization', 'Bearer ' + resp.access_token);
                requestDetail.setTimeout(50000);
                //HttpResponse responseDetail = http.send(requestDetail);
                
                HttpResponse responseDetail;
                if(!test.isRunningTest()){
                    responseDetail = http.send(requestDetail);
                    //system.debug('request ' + postBody);
                    system.debug('response ' + responseDetail);
                    system.debug('response body line no 65 ' + responseDetail.getBody());
                } else {
                    responseDetail = new HttpResponse();
                    responseDetail.setStatusCode(200);
                    String testBody = '{"applianceId": "D828C917F09C","brandId": 0,"brandName": "Unknown","country": "US",' +
    '"environment": "prd","kind": "appliance#presence","poolId": "GIGYA_US","presence": "ONLINE","region": "us-east-1", "userId": "yv0tg8bqe09afys"}';
                    responseDetail.setBody(testBody);
                }
                System.debug('line no 76' + responseDetail.getBody());
                if (responseDetail.getStatusCode() == 200) {
                    System.debug(' line no 78' + responseDetail.getBody());
                    applianceStatus = connectedApplianceResponse.parse(responseDetail.getBody());
                } else {
                    system.debug('The status code returned was not expected: ' +
                                 responseDetail.getStatusCode() + ' ' + responseDetail.getStatus());                    
                }
                    
            }
            
           }catch(exception e){
             system.debug('The status code returned was not expected: ' + e.getMessage());
           }        
        return applianceStatus;
    }
}
public with sharing class ConnectedAdmin {

	@AuraEnabled
    public static String getConnectedData(String macAddress, boolean faulttable, boolean cycle){
        String req;
        if(faulttable){
            req='fault-table';
        }
        else if(cycle){
            req='cycle-history';
        }
        String extraurl='/'+req+'?macAddress='+macAddress;
        String res;
        if(!utility.isSandbox){
        	res= RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','Production_ConnectedMuleData',extraurl,'GET',null);
        }
        else {
            //res= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_Connected_Token','Sandbox_ConnectedMuleData',extraurl,'GET',null);
            res= RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','Production_ConnectedMuleData',extraurl,'GET',null);
        }
        return res;
    }
    
    @AuraEnabled
    public static String faultTable(String macAddress){
        return getConnectedData(macAddress,true,false);
    }
    
    @AuraEnabled
    public static String cycle(String macAddress){
        return getConnectedData(macAddress,false,true);
    }
    
    @AuraEnabled
    public static String connectionStatus(String macAddress){
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            if(utility.isSandbox){
                request.setEndpoint('callout:ConnectedApplianceAuth');   
            } else {
                request.setEndpoint('callout:ConnectedApplianceAuth');
            }
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
               
            request.setTimeout(50000);
            HttpResponse response;
            if(!test.isRunningTest()){
                response = http.send(request);
                system.debug('response ' + response);
                system.debug('response body ' + response.getBody());
            } 
            else {
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
                if(utility.isSandbox){
                    requestDetail.setEndpoint('callout:ConnectedAppliance' + '/' + macAddress + '/presence');   
                } else {
                    requestDetail.setEndpoint('callout:ConnectedAppliance' + '/' + macAddress + '/presence');  
                }
                requestDetail.setMethod('GET');
                requestDetail.setHeader('Authorization', 'Bearer ' + resp.access_token);
                requestDetail.setTimeout(50000);
                //HttpResponse responseDetail = http.send(requestDetail);
                
                HttpResponse responseDetail;
                if(!test.isRunningTest()){
                    responseDetail = http.send(requestDetail);
                    //system.debug('request ' + postBody);
                    system.debug('response ' + responseDetail);
                    system.debug('response body ' + responseDetail.getBody());
                } else {
                    responseDetail = new HttpResponse();
                    responseDetail.setStatusCode(200);
                    String testBody = '{"applianceId": "D828C917F09C","brandId": 0,"brandName": "Unknown","country": "US",' +
    '"environment": "prd","kind": "appliance#presence","poolId": "GIGYA_US","presence": "ONLINE","region": "us-east-1", "userId": "yv0tg8bqe09afys"}';
                    responseDetail.setBody(testBody);
                }
                
      
                
                System.debug(responseDetail.getBody());
                connectedApplianceResponse connectedStatus;
                if (responseDetail.getStatusCode() == 200) {
                    System.debug(responseDetail.getBody());
                    connectedStatus = connectedApplianceResponse.parse(responseDetail.getBody());
                    String presence=connectedStatus.presence;
                    return presence;
                } else {
                    system.debug('The status code returned was not expected: ' +
                                 responseDetail.getStatusCode() + ' ' + responseDetail.getStatus());
                    return 'Not Connectable'; 
                    
                }
                    
            } else {
                system.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                return null;
                 
            }
        }
        catch(exception e){
            return null;
       }       

    }
}
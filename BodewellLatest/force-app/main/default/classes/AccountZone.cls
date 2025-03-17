public class AccountZone {
    @InvocableMethod(label='Get Account Zone' description='Get Account Zone')
    public static List<String> getZone(List<String> zip) {
        //make callout  
        List<String> returnList = new List<String>();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_ZoneDetails');   
        } else {
            request.setEndpoint('callout:Production_ZoneDetails');
        }
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');
        String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zip[0]+'"}}';
        
        // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(15000);
        HttpResponse response;
        if(!test.isRunningTest()){
            response = http.send(request);
            system.debug('request ' + postBody);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"CityName": "LOUISVILLE","StateCode": "KY","PostalAreaCode": "40225","RegionNo": "126","ZoneCode": "57"}';
            response.setBody(testBody);
        }
        
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            zoneDetailsResponse resp = zoneDetailsResponse.parse(response.getBody());
            system.debug('zoneDetailsResponse ' + resp);
            //a[0].Region__c = integer.valueOf(resp.RegionNo);
            //a[0].Zone__c = string.valueOf(resp.ZoneCode);
            returnList.add(string.valueOf(resp.ZoneCode));
            return returnList;
        } else {
            system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()));
            return null; 
        }
    
    }
}
public class ChatEstimatedWaitTime {
    @InvocableMethod(label = 'Get Estimated Wait Time')

    public static List<Integer> makeGetCallout(List<List<String>> ids) {
        Integer estimatedWaitTime;
        Organization OrgId = [select id from Organization]; 
        String Orgs = OrgId.Id;
        System.debug('buttonId = ' +ids[0][0]+ ' DeploymentId =' +ids[0][1]);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:chat_url?org_id=' +Orgs.substring(0,15)+ '&deployment_id=' +ids[0][1]+ '&Availability.needEstimatedWaitTime=1&Availability.ids=' +ids[0][0]);
        request.setHeader('X-LIVEAGENT-API-VERSION', '50');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        system.debug('Estimated Wait Time - raw data: ');
        System.debug(response.getBody());
        JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'estimatedWaitTime')) {
                    // Get the value.
                    parser.nextToken();
                    estimatedWaitTime = (Integer)parser.getIntegerValue()/60; //estimated wait time in minutes
                    
                }
        }
        system.debug('Estimated Wait Time - return value: ' + estimatedWaitTime);
        return new List<integer>{estimatedWaitTime};
    }
}
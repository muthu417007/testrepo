public class ServiceHistory
{
    @AuraEnabled
    public static searchIdResponse get360Orders(String conId) 
    {
       system.debug('contact ID ' + conId);
        Contact c = [select Id, PersonID__c
                     from Contact where Id=:conId limit 1];
        system.debug('personId ' + c.PersonID__c);
        searchIdResponse orderResults = utility.getById(c.PersonID__c);
        system.debug('get360 orderResults ' + orderResults);
        if((orderResults.errors != null && orderResults.errors.size() > 0) || orderResults.data == null){
            //try again
            orderResults = utility.getById(c.PersonID__c);
        } else {
           orderResults.status = new searchIdResponse.statusMessage();
           orderResults.status.message = 'Success'; 
        }
        system.debug('response ' + orderResults);
        return orderResults;
    }
    
    public static String fetchConsumerNumbers(String conId){
     	List<Contact_Information__c> consumerNumbers = [SELECT Id, Contact__c, ID_Type__c, Identifier__c, PersonDetailID__c, Identifier2__c 
                                                        FROM Contact_Information__c 
                                                        where ID_Type__c = 'Ge Consumer Number'
                                                        AND Contact__c = :conId];
        String consumerNumber = '';
        for(Contact_Information__c ci: consumerNumbers){
           consumerNumber = consumerNumber + '"' + ci.Identifier__c + '",';
        }
        return consumerNumber.removeEnd(',');   
    } 
    
    
    @AuraEnabled
    public static closedCallsDetailsResponse closedCalls(String conId) 
    {
         Contact c = [select Id, PersonID__c
                     from Contact where Id=:conId limit 1];
               
        String consumerNumber = fetchConsumerNumbers(conId);
        
        // callout to get open calls
        //{"variables":{"ConsumerNumbers":["180708744","186945480"]},"query":"query ($ConsumerNumbers: [String!]!) { getOpenCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}
        String token = Utility.getGraphQLToken();
        Http httpClosedCalls = new Http();
        HttpRequest requestClosedCalls = new HttpRequest();
        if(utility.isSandbox){
            requestClosedCalls.setEndpoint('callout:Sandbox_GraphQL');   
        } else {
            requestClosedCalls.setEndpoint('callout:Production_GraphQL');
        }
        
        requestClosedCalls.setMethod('POST');
        requestClosedCalls.setHeader('Content-Type', 'application/graphql');
        //requestClosedCalls.setHeader('Authorization', resp.access_token);
         requestClosedCalls.setHeader('Authorization', token);                       
        system.debug(token);
        // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
        // 
  //      String postBody = '{"variables":{"ConsumerNumbers":["120804951","114562312","100299283","13906601","3584468151","1940107946","8582078","141120063"]},"query":"query ($ConsumerNumbers: [String!]!) { getClosedCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}';
        String postBody = '{"variables":{"ConsumerNumbers":[' + consumerNumber + ']},"query":"query ($ConsumerNumbers: [String!]!) { getClosedCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}';
       system.debug('Post body ' + postBody);
        
        // Set the body as a JSON object
        requestClosedCalls.setBody(postBody);
        requestClosedCalls.setTimeout(10000);
        HttpResponse responseClosedCalls;
        if(!test.isRunningTest()){
            responseClosedCalls = httpClosedCalls.send(requestClosedCalls);
            system.debug('request ' + postBody);
            system.debug('responseClosedCalls ' + responseClosedCalls);
            system.debug('responseClosedCalls body ' + responseClosedCalls.getBody());
        } else {
            responseClosedCalls = new HttpResponse();
            responseClosedCalls.setStatusCode(200);
            StaticResource sr = [select id,body from StaticResource Where Name = 'closedCallsDetailsTestResponse'];
            String testBody = sr.body.toString();
            responseClosedCalls.setBody(testBody);
            
        }
        
        // Parse the JSON response
        if (responseClosedCalls.getStatusCode() == 200) {
            System.debug(responseClosedCalls.getBody());
            
            closedCallsResponse  respClosedCalls = closedCallsResponse.parse(responseClosedCalls.getBody());
            String parseString = respClosedCalls.data.getClosedCallInfo;
            system.debug('parseString ' + parseString);
            //parseString = parseString.replaceAll('\\','\\');
            closedCallsDetailsResponse  closedCallsDetails = closedCallsDetailsResponse.parse(parseString);
            system.debug(closedCallsDetails);
            system.debug(closedCallsDetails.fs_callhistory_count);
            system.debug(closedCallsDetails.fs_callhistory);
            return closedCallsDetails;
        } else {
            system.debug('The status code returned was not expected: ' +
            responseClosedCalls.getStatusCode() + ' ' + responseClosedCalls.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            responseClosedCalls.getStatusCode() + ' ' + responseClosedCalls.getStatus()));
			return null;
        }
  
    }
    
    @AuraEnabled
    public static openCallsDetailsResponse openCalls(String conId) 
    {
         Contact c = [select Id, PersonID__c
                     from Contact where Id=:conId limit 1];

        String token = Utility.getGraphQLToken();
        Http httpOpenCalls = new Http();
        HttpRequest requestOpenCalls = new HttpRequest();
        if(utility.isSandbox){
            requestOpenCalls.setEndpoint('callout:Sandbox_GraphQL');   
        } else {
            requestOpenCalls.setEndpoint('callout:Production_GraphQL');
        }
        
        requestOpenCalls.setMethod('POST');
        requestOpenCalls.setHeader('Content-Type', 'application/graphql');
        //requestOpenCalls.setHeader('Authorization', resp.access_token);
         requestOpenCalls.setHeader('Authorization', token);                       
        system.debug(token);
   		String consumerNumber = fetchConsumerNumbers(conId);
        //String postBody = '{"variables":{"ConsumerNumbers":["187251578","174889894","177482815","187251612","187251588","187251608","77142759"]},"query":"query ($ConsumerNumbers: [String!]!) { getOpenCallInfo(ConsumerNumbers: $ConsumerNumbers)} "}';
        String postBody = '{"variables":{"ConsumerNumbers":[' + consumerNumber + ']},"query":"query ($ConsumerNumbers: [String!]!) { getOpenCallInfo(ConsumerNumbers: $ConsumerNumbers)} "}';
        
        
        // Set the body as a JSON object
        requestOpenCalls.setBody(postBody);
        requestOpenCalls.setTimeout(50000);
        HttpResponse responseOpenCalls;
        if(!test.isRunningTest()){
            responseOpenCalls = httpOpenCalls.send(requestOpenCalls);
            system.debug('request ' + postBody);
            system.debug('responseOpenCalls ' + responseOpenCalls);
            system.debug('responseOpenCalls body ' + responseOpenCalls.getBody());
        } else {
            responseOpenCalls = new HttpResponse();
            responseOpenCalls.setStatusCode(200);
            StaticResource sr = [select id,body from StaticResource Where Name = 'openCallsDetailsTestResponse'];
            String testBody = sr.body.toString();
            responseOpenCalls.setBody(testBody);
            
        }
        // Parse the JSON response
        if (responseOpenCalls.getStatusCode() == 200) {
            System.debug(responseOpenCalls.getBody());
            
            OpenCallsResponse  respOpenCalls = OpenCallsResponse.parse(responseOpenCalls.getBody());
            String parseString = respOpenCalls.data.getOpenCallInfo;
            system.debug('parseString ' + parseString);
            //parseString = parseString.replaceAll('\\','\\');
            OpenCallsDetailsResponse  OpenCallsDetails = OpenCallsDetailsResponse.parse(parseString);
            system.debug(OpenCallsDetails);
            system.debug(OpenCallsDetails.fs_pendingcalls_count);
            system.debug(OpenCallsDetails.cc_pendingcalls_count);
            return OpenCallsDetails;
        } else {
            system.debug('The status code returned was not expected: ' +
            responseOpenCalls.getStatusCode() + ' ' + responseOpenCalls.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            responseOpenCalls.getStatusCode() + ' ' + responseOpenCalls.getStatus()));
			return null;
        }
         
    }
    
    @AuraEnabled
    public static serviceOrderDetailResponse serviceOrderDetails(String conId) 
    {
         
        // get order numbers from Contact_Information__c
        
        // callout to get open calls
        //{"variables":{"ConsumerNumbers":["180708744","186945480"]},"query":"query ($ConsumerNumbers: [String!]!) { getOpenCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}
        String token = Utility.getGraphQLToken();
        Http httpClosedCalls = new Http();
        HttpRequest requestClosedCalls = new HttpRequest();
        if(utility.isSandbox){
            requestClosedCalls.setEndpoint('callout:Sandbox_GraphQL');   
        } else {
            requestClosedCalls.setEndpoint('callout:Production_GraphQL');
        }
        
        requestClosedCalls.setMethod('POST');
        requestClosedCalls.setHeader('Content-Type', 'application/graphql');
        //requestClosedCalls.setHeader('Authorization', resp.access_token);
         requestClosedCalls.setHeader('Authorization', token);                       
        system.debug(token);
        // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
        // 
        String postBody = '{"variables":{"OrderNumber":"6877052","OrderUniqueKey":19260},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) { findServicesExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}';
        // Set the body as a JSON object
        requestClosedCalls.setBody(postBody);
        requestClosedCalls.setTimeout(5000);
        HttpResponse responseClosedCalls;
        if(!test.isRunningTest()){
            responseClosedCalls = httpClosedCalls.send(requestClosedCalls);
            system.debug('request ' + postBody);
            system.debug('responseClosedCalls ' + responseClosedCalls);
            system.debug('responseClosedCalls body ' + responseClosedCalls.getBody());
        } else {
            responseClosedCalls = new HttpResponse();
            responseClosedCalls.setStatusCode(200);
            StaticResource sr = [select id,body from StaticResource Where Name = 'serviceOrdersDetailsTestResponse'];
            String testBody = sr.body.toString();
            responseClosedCalls.setBody(testBody);
            
        }
        // Parse the JSON response  serviceOrdersDetailsTestResponse
        if (responseClosedCalls.getStatusCode() == 200) {
            System.debug(responseClosedCalls.getBody());
            
            serviceOrderResponse   respClosedCalls = serviceOrderResponse.parse(responseClosedCalls.getBody());
            String parseString = respClosedCalls.data.findServicesExtraInfo;
            system.debug('parseString ' + parseString);
            //parseString = parseString.replaceAll('\\','\\');
            serviceOrderDetailResponse   closedCallsDetails = serviceOrderDetailResponse.parse(parseString);
            system.debug(closedCallsDetails);
            //system.debug(closedCallsDetails.fs_callhistory_count);
            //system.debug(closedCallsDetails.fs_callhistory);
            return closedCallsDetails;
        } else {
            system.debug('The status code returned was not expected: ' +
            responseClosedCalls.getStatusCode() + ' ' + responseClosedCalls.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            responseClosedCalls.getStatusCode() + ' ' + responseClosedCalls.getStatus()));
			return null;
        }
        
        
        
        
        
        
        //callout to get close calls
        //{"variables":{"ConsumerNumbers":["120804951","114562312","100299283","13906601","3584468151","1940107946","8582078"]},"query":"query ($ConsumerNumbers: [String!]!) { getClosedCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}
        //callout to get service orders
        //{"variables":{"OrderNumber":"6877052","OrderUniqueKey":19260},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) { findServicesExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}
        //callout to get parts orders
        //{"variables":{"OrderNumber":"0475201","OrderUniqueKey":"13303"},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) {  findExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}
            }
    
    /*
    @AuraEnabled
    public static serviceOrderDetailResponse serviceOrderInfoDetails(String conId) 
    {
         
        	// get order numbers from Contact_Information__c
        
        // callout to get open calls
        //{"variables":{"ConsumerNumbers":["180708744","186945480"]},"query":"query ($ConsumerNumbers: [String!]!) { getOpenCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}
        String token = Utility.getGraphQLToken();
        Http httpClosedCalls = new Http();
        HttpRequest requestClosedCalls = new HttpRequest();
        if(utility.isSandbox){
            requestClosedCalls.setEndpoint('callout:Sandbox_GraphQL');   
        } else {
            requestClosedCalls.setEndpoint('callout:Production_GraphQL');
        }
        
        requestClosedCalls.setMethod('POST');
        requestClosedCalls.setHeader('Content-Type', 'application/graphql');
        //requestClosedCalls.setHeader('Authorization', resp.access_token);
         requestClosedCalls.setHeader('Authorization', token);                       
        system.debug(token);
        // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
        // 
        String postBody = '{"variables":{"OrderNumber":"6877052","OrderUniqueKey":19260},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) { findServicesExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}';
        // Set the body as a JSON object
        requestClosedCalls.setBody(postBody);
        requestClosedCalls.setTimeout(5000);
        HttpResponse responseClosedCalls = httpClosedCalls.send(requestClosedCalls);
        // Parse the JSON response
        if (responseClosedCalls.getStatusCode() == 200) {
            System.debug(responseClosedCalls.getBody());
            
            serviceOrderInfoResponse    respClosedCalls = serviceOrderInfoResponse.parse(responseClosedCalls.getBody());
            String parseString = respClosedCalls.data.findServicesExtraInfo;
            system.debug('parseString ' + parseString);
            //parseString = parseString.replaceAll('\\','\\');
            serviceOrderDetailResponse   closedCallsDetails = serviceOrderDetailResponse.parse(parseString);
            system.debug(closedCallsDetails);
            //system.debug(closedCallsDetails.fs_callhistory_count);
            //system.debug(closedCallsDetails.fs_callhistory);
            return closedCallsDetails;
        } else {
            system.debug('The status code returned was not expected: ' +
            responseClosedCalls.getStatusCode() + ' ' + responseClosedCalls.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            responseClosedCalls.getStatusCode() + ' ' + responseClosedCalls.getStatus()));
			return null;
        }
        
    
    }
    */
    @AuraEnabled
    public static void historyCallout(String conId) 
    {
         Contact c = [select Id, PersonID__c
                     from Contact where Id=:conId limit 1];

        // callout to get open calls
        //{"variables":{"ConsumerNumbers":["180708744","186945480"]},"query":"query ($ConsumerNumbers: [String!]!) { getOpenCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}
        String token = Utility.getGraphQLToken();
        Http httpOpenCalls = new Http();
        HttpRequest requestOpenCalls = new HttpRequest();
        if(utility.isSandbox){
            requestOpenCalls.setEndpoint('callout:Sandbox_GraphQL');   
        } else {
            requestOpenCalls.setEndpoint('callout:Production_GraphQL');
        }
        
        requestOpenCalls.setMethod('POST');
        requestOpenCalls.setHeader('Content-Type', 'application/graphql');
        //requestOpenCalls.setHeader('Authorization', resp.access_token);
         requestOpenCalls.setHeader('Authorization', token);                       
        system.debug(token);
        // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
        // 
        String postBody = '{"variables":{"ConsumerNumbers":["180708744","186945480"]},"query":"query ($ConsumerNumbers: [String!]!) { getOpenCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}';
        // Set the body as a JSON object
        requestOpenCalls.setBody(postBody);
        requestOpenCalls.setTimeout(5000);
        HttpResponse responseOpenCalls = httpOpenCalls.send(requestOpenCalls);
        // Parse the JSON response
        if (responseOpenCalls.getStatusCode() == 200) {
            System.debug(responseOpenCalls.getBody());
            
            OpenCallsResponse respOpenCalls = OpenCallsResponse.parse(responseOpenCalls.getBody());
            String parseString = respOpenCalls.data.getOpenCallInfo;
            system.debug('parseString ' + parseString);
            //parseString = parseString.replaceAll('\\','\\');
            OpenCallDetailResponse openCallsDetails = OpenCallDetailResponse.parse(parseString);
            system.debug(openCallsDetails);
        } else {
            system.debug('The status code returned was not expected: ' +
            responseOpenCalls.getStatusCode() + ' ' + responseOpenCalls.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            responseOpenCalls.getStatusCode() + ' ' + responseOpenCalls.getStatus()));

        }
        
        
        
        //callout to get close calls
        //{"variables":{"ConsumerNumbers":["120804951","114562312","100299283","13906601","3584468151","1940107946","8582078"]},"query":"query ($ConsumerNumbers: [String!]!) { getClosedCallInfo(ConsumerNumbers: $ConsumerNumbers)}"}
        //callout to get service orders
        //{"variables":{"OrderNumber":"6877052","OrderUniqueKey":19260},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) { findServicesExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}
        //callout to get parts orders
        //{"variables":{"OrderNumber":"0475201","OrderUniqueKey":"13303"},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) {  findExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}
        
                 

    }
    


    /* J edit */
    //@AuraEnabled
    //public static serviceOrderDetailResponse orderDetails(String orderNumber, String uniqueKey) 
    @AuraEnabled
    public static String orderDetails(String orderNumber, String uniqueKey) 
    {

        String token = Utility.getGraphQLToken();
        Http httpClosedCalls = new Http();
        HttpRequest requestClosedCalls = new HttpRequest();
        if(utility.isSandbox){
            requestClosedCalls.setEndpoint('callout:Sandbox_GraphQL');   
        } else {
            requestClosedCalls.setEndpoint('callout:Production_GraphQL');
        }
        
        requestClosedCalls.setMethod('POST');
        requestClosedCalls.setHeader('Content-Type', 'application/graphql');
         requestClosedCalls.setHeader('Authorization', token);                       
        system.debug(token);
        // String postBody = '{"variables":{"OrderNumber":"6877052","OrderUniqueKey":19260},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) { findServicesExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}';
        // 

        /* J edit */
        String postBody = '{"variables":{"OrderNumber":"'+orderNumber+'","OrderUniqueKey":'+uniqueKey+'},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) { findServicesExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}';

        // Set the body as a JSON object
        requestClosedCalls.setBody(postBody);
        requestClosedCalls.setTimeout(5000);
        HttpResponse responseClosedCalls = httpClosedCalls.send(requestClosedCalls);

        /* J edit */
        String response = responseClosedCalls.getBody();
        return response;

        // Parse the JSON response
        /* if (responseClosedCalls.getStatusCode() == 200) {
            System.debug(responseClosedCalls.getBody());
            
            serviceOrderResponse   respClosedCalls = serviceOrderResponse.parse(responseClosedCalls.getBody());
            String parseString = respClosedCalls.data.findServicesExtraInfo;
            system.debug('parseString ' + parseString);
            //parseString = parseString.replaceAll('\\','\\');
            serviceOrderDetailResponse   closedCallsDetails = serviceOrderDetailResponse.parse(parseString);
            system.debug(closedCallsDetails);
            //system.debug(closedCallsDetails.fs_callhistory_count);
            //system.debug(closedCallsDetails.fs_callhistory);
            return closedCallsDetails;
        } else {
            system.debug('The status code returned was not expected: ' +
            responseClosedCalls.getStatusCode() + ' ' + responseClosedCalls.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            responseClosedCalls.getStatusCode() + ' ' + responseClosedCalls.getStatus()));
			return null;
        } */
        

    }

    // serviceHistory.orderDetailsCops('6101692', '19303');
    // serviceHistory.orderDetailsCops('4072203', '19309');
    @AuraEnabled
    public static String orderDetailsCops(String orderNumber, String uniqueKey) 
    {
        System.debug('orderNumber');
        System.debug(orderNumber);
        System.debug('uniqueKey');
        System.debug(uniqueKey);

        String token = Utility.getGraphQLToken();
        Http httpClosedCalls = new Http();
        HttpRequest requestClosedCalls = new HttpRequest();
        if(utility.isSandbox){
            requestClosedCalls.setEndpoint('callout:Sandbox_GraphQL');   
        } else {
            requestClosedCalls.setEndpoint('callout:Production_GraphQL');
        }
        
        requestClosedCalls.setMethod('POST');
        requestClosedCalls.setHeader('Content-Type', 'application/graphql');
         requestClosedCalls.setHeader('Authorization', token);                       
        system.debug(token);
        // String postBody = '{"variables":{"OrderNumber":"6877052","OrderUniqueKey":19260},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) { findServicesExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}';
        // 

        /* J edit */
        String postBody = '{"variables":{"OrderNumber":"'+orderNumber+'","OrderUniqueKey":'+uniqueKey+'},"query":"query ($OrderNumber: String!, $OrderUniqueKey: ID!) { findExtraInfo(OrderNumber: $OrderNumber, OrderUniqueKey: $OrderUniqueKey)}"}';

        // Set the body as a JSON object
        requestClosedCalls.setBody(postBody);
        requestClosedCalls.setTimeout(5000);
        HttpResponse responseClosedCalls = httpClosedCalls.send(requestClosedCalls);

        /* J edit */
        String response = responseClosedCalls.getBody();
        //String data = JSON.serializePretty(response);
        System.debug( response );
        return response;
    }

}
public with sharing class Twilio {


    /*
    * @description create record of message sent
    *
    * @return Twilio_Message__c
    */
    @AuraEnabled
    public static Twilio_Message__c setTwilioMessage(Twilio_Message__c tm){
        
        upsert tm;
        return tm;
    }


    /*
    * @description for auto / triggered sending via Process Buiilder
    */
    @InvocableMethod
    public static void sendTwilioMessages(List<Id> objIds){
        
        // Validate input
        System.assert(objIds != null);
        System.assert(objIds.size() > 0);
        
        
        Twilio_Config__mdt config = [
            SELECT Proxy_Address__c, Outbound_Message__c, Phone_From__c
            FROM Twilio_Config__mdt
            WHERE DeveloperName = 'Twilio_Config1'
            LIMIT 1
        ];

        System.debug(config);
        

        List<Case> cases = [SELECT Twilio_Phone__c From Case WHERE Id IN :objIds];

        System.debug(config);

        List<String> outbounds = new List<String>();

        for(Case obj : cases){
            String phone = obj.Twilio_Phone__c;
            outbounds.add('{ "to": "'+phone+'", "from": "'+config.Phone_From__c+'", "body": "'+config.Outbound_Message__c+'" }');
        }

        System.debug(outbounds);

        for(String body : outbounds){
            List<String> outbound = new List<String>{config.Proxy_Address__c, body};
            Twilio.sendRequest(outbound);
        }
    }

    /*
    * @description for sending outbound w/ options created else where in system
    */
    @future(callout=true)
    public static void sendRequest(List<String> outbound){

        System.debug('Sending SMS (Twilio.sendRequest)');
        System.debug(outbound);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(outbound[0]+'/outbound');
        req.setMethod('POST');
        req.setBody(outbound[1]);
        req.setHeader('Content-Length', String.valueOf(outbound[1].length()));
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);

        Http http = new Http();

        HTTPResponse res = Test.isRunningTest() ? new HTTPResponse() : http.send(req);

        String body = Test.isRunningTest() ? 'Test' : res.getBody();

        System.debug(body);
    }
}

/* 
@AuraEnabled
public static List<Twilio_Message__c> getTwilioMessage(String sid){

    return [
        SELECT SID__c, To__c, From__c, Message__c, Case__c
        FROM Twilio_Message__c
        WHERE SID__c = :sid
        LIMIT 1
    ];
}




        // Get the sObject token from the first ID
        // (the List contains IDs of sObjects of the same type).
        Schema.SObjectType token = objIds[0].getSObjectType();
        
        // Using the token, do a describe 
        // and construct a query dynamically. 
        Schema.DescribeSObjectResult dr = token.getDescribe();

        // if ever want more than Case object, make Forumla field Twilio_Phone__c for each object
        String queryString = 'SELECT Twilio_Phone__c FROM ' + dr.getName() + 
            ' WHERE ';
        for(ID objId : objIds) {
            queryString += 'Id=\'' + objId + '\' OR ';
        }
        // Remove the last ' OR'
        queryString = queryString.subString(0, queryString.length() - 4);

        sObject[] objects = Database.query(queryString);
*/
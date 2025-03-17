/**
 * @author         Neha Chowdhury
 * @company        GEA
 * @created        07.02.2022
 * @description    Jira Ticket 447 API for Calabrio recordings
 * @testClass      CalabrioAPI_Test  
 */
public with sharing class CalabrioAPIforStartScreen {
private static string sessionId;
      /**
     * @description This method is an invocable method from Agent Wrok trigger Flow
     */ 
	@InvocableMethod 
    public static void fireCalabrioAPIforstartscreen()
    {
        invokeCalabrioAPIforstartscreen();
    }
    /**
     * @description This method is a future method for API callouts for Authorize and start Screen
     */ 
    @future(callout=true)
      public static void invokeCalabrioAPIforstartscreen(){
       	String email = UserInfo.getUserEmail();
        CalabrioAPI__mdt calabrioAPI;
          Organization org = new Organization() ;
          //Checking if the Organization Object is accessible
          if(Schema.sObjectType.Organization.fields.IsSandbox.isAccessible()){
        	 org = [select IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
          }
        // Checking if the code is running in Sandbox
        if(org.IsSandbox == true){ 
           calabrioAPI=CalabrioAPI__mdt.getInstance('Sandbox');
       	}
        else
           {
            calabrioAPI=CalabrioAPI__mdt.getInstance('Production');   
           }
        String username = calabrioAPI.UserName__c;
        String password = calabrioAPI.Password__c;
        HttpRequest req = new HttpRequest();
	    String restURL = calabrioAPI.AuthorizeURL__c;  
        req.setMethod('POST');
        req.setHeader('content-type', 'text/json');
        String postBody = '{"userId":"' +username+ '" ,"password":"' +password+ '" ,"language":"en"}';
        //System.debug(postBody);
      	req.setEndpoint(restURL);
	    req.setBody(postBody);
 //Execute Authorize API call here     
      Http http = new Http();
      HTTPResponse res = http.send(req);
      //System.debug('STATUS:' + res.getStatus());
      //System.debug('STATUS_CODE:' + res.getStatusCode());
	  //System.debug('ResponseBody:' + res.getbody());
	  Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
      sessionId = String.valueof(results.get('sessionId')); 
  // Sending the API to start Recording
      HttpRequest req1 = new HttpRequest();
	  String restURLforRecording = calabrioAPI.RecordingURL__c+email+calabrioAPI.StartScreen__c;  
      //System.debug(restURLforRecording); 
      req1.setMethod('GET');
      req1.setHeader('Cookie','hazelcast.sessionId='+sessionId);
	  req1.setEndpoint(restURLforRecording);
	  Http httpforRecording = new Http();	
      httpforRecording.send(req1);
    }
}
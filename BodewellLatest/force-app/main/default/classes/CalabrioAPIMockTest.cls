/**
 * @author         Neha Chowdhury
 * @company        GEA
 * @created        07.02.2022
 * @description    Jira Ticket 447 API for Calabrio recordings. This is Mock class for the callouts
*/


public class CalabrioAPIMockTest implements HttpCalloutMock {
   
    /**
     * @description Implement this interface method
     * @return response res
     */
  public static HTTPResponse respond(HTTPRequest req) {
        String email = UserInfo.getUserEmail();
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint()=='https://calabriocloud.com/api/rest/authorize/'){
		System.assertEquals('https://calabriocloud.com/api/rest/authorize/', req.getEndpoint(),'Testing authorize API Endpoint');
        System.assertEquals('POST', req.getMethod(),'Testing authorize API Method as Post');
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"sessionId":"HZ0F5FE708EF0849189C30DC4C141BDE64"}');
       	res.setStatusCode(200);
   		}
        
        else if(req.getEndpoint()=='https://calabriocloud.com/api/rest/recordingcontrols/user/'+email+'/start_screen'){
         System.assertEquals('https://calabriocloud.com/api/rest/recordingcontrols/user/'+email+'/start_screen', req.getEndpoint(),'Testing recordingcontrol start screen API Endpoint');
         System.assertEquals('GET', req.getMethod(),'Testing recordingcontrol start screen Api Method as GET');
         res.setStatusCode(200);
        }
        
      else {
         if(req.getEndpoint()=='https://calabriocloud.com/api/rest/recordingcontrols/user/'+email+'/stop_screen'){
         System.assertEquals('https://calabriocloud.com/api/rest/recordingcontrols/user/'+email+'/stop_screen', req.getEndpoint() ,'Testing recordingcontrol stop screen API Endpoint');
         System.assertEquals('GET', req.getMethod() ,'Testing recordingcontrol stop screen API Method as GET');
       	 res.setStatusCode(200);
         }
      }
       return res;
    }
}
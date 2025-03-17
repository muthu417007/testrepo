public class DisplayCaseController {

    @AuraEnabled
    public static List<Case> getCaseFromId(String caseID) {
                
        List<Case> cases = [  SELECT Id, ContactMobile, ContactPhone, ContactEmail, Consumer_s_Name__c, Consumer_Full_Address__c, ContactId, Case_f_Owner__c, Incident_f_Type__c, Priority, Status, CS1049_Rejected__c, CS1049_Created__c from CASE where caseNumber= :caseID ];
        return cases;              
    }
    @AuraEnabled
	public static Map < String, Object > getCalloutResponseContents(String url) {
    // Instantiate a new http object
    Http http = new Http();
     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');
    req.setHeader('x-api-key','8Y2UQeFTo84CWj9pO24HI2RVcsnVGSBd4PnlpRM7');        
    // Send the request, and return a response
    HttpResponse res = http.send(req);
    Map < String,Object > resultsMap = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
	system.debug('resultsMap-->' + resultsMap);
 	return resultsMap;    
  }
   @AuraEnabled
    public static List<case> getCaseFromPhone(String phoneNumber) {             
        List<Case> cases = [ SELECT Id,caseNumber,CreatedDate,Status,First_Name__c,Last_Name__c from CASE where ContactPhone = :phoneNumber or ContactMobile=:phoneNumber ];
        return cases;     
    }    
  @AuraEnabled
    public static List<case> getCaseFromzipcode(String firstname,String lastname,String zipcode) {
        List<Case> cases = [ SELECT Id,caseNumber,CreatedDate,Status,First_Name__c,Last_Name__c from CASE where First_Name__c = :firstname and Last_Name__c=:lastname and Zip_Postal_Code__c=:zipcode ];
		return cases;      
    }    
  @AuraEnabled
    public static List<case> getCaseFromstreet(String street,String lastname,String zipcode) {
        List<Case> cases = [ SELECT Id,caseNumber,CreatedDate,Status,First_Name__c,Last_Name__c from CASE where Street_Address__c = :street and Last_Name__c=:lastname and Zip_Postal_Code__c=:zipcode ];
        return cases;               
    }
   
}
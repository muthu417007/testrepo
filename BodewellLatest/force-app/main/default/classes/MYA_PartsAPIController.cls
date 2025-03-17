/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        07.07.2022
 * @description    For getting user payment details
 */
public with sharing class MYA_PartsAPIController {
    public MYA_PartsAPIController() {
        System.debug(LoggingLevel.WARN, 'MYA_UserDetailsController');
    }
	// Method to get payment details from parts api
    @AuraEnabled( cacheable=true )  
    public static PaymentResponseModel getPaymentInfo(String Email) {
       	PaymentResponseModel PaymentResponse = new PaymentResponseModel();         
        try { 
            String UID;        
            List<Contact> UserContact = [ SELECT Id, Email, Global_Customer_Id__c  FROM Contact WHERE Email=:Email LIMIT 1];
        
            if(UserContact.size() > 0) {
                UID = UserContact[0].Global_Customer_Id__c;
            } else {
                UID = '';
            }        
            string UrlEncodedEmail = EncodingUtil.urlEncode(Email, 'UTF-8');
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt MyaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);        
            String Jwt = getJWT.generateJWTToken(MyaConfig.Payment_Method_Client_Id__c,MyaConfig.Payment_Method_Request_Type__c,120,MyaConfig.Payment_Method_Client_Secret__c);
            String token =Jwt;           
            Http HttpCall = new Http();
            HttpRequest Request = new HttpRequest();
            Request.setMethod(MyaConfig.Payment_Method_Type__c);
            Request.setEndpoint(MyaConfig.Payment_Method_Endpoint__c+ '?emailAddress=' + UrlEncodedEmail);
            Request.setHeader('Content-Type', 'application/json');
            Request.setHeader('Accept', 'application/json');
            Request.setHeader('Authorization',token);
            Request.setTimeout(60000);
            HttpResponse Response ;
            Response = HttpCall.send(Request);
        
            if(Response.getStatusCode() == 200) {
                PaymentResponse.Response = Response.getBody();
                PaymentResponse.UID = UID;
                PaymentResponse.EditPaymentUrl = MyaConfig.Payment_Method_Edit_Payment_URL__c;
                PaymentResponse.Success = true;
            } else {
                PaymentResponse.Success = false;
            }        
        	return PaymentResponse;
        } catch (Exception e) {
            	PaymentResponse.Success = false;
            	return PaymentResponse;
        }            
    }
    
    public class PaymentResponseModel {
        @AuraEnabled public String Response;
        @AuraEnabled public String UID;
        @AuraEnabled public String EditPaymentUrl;
        @AuraEnabled public Boolean Success;
    }
}
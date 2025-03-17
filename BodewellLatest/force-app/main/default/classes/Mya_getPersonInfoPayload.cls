//******************************************************************************************
//Name : Mya_getPersonInfoPayload
//Requirement : Class to call getPersonInfo Mulesoft API
//EPIC/US/TASK : IDMSF- 155
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			09/09/2022			Initial
//******************************************************************************************
//@description : Class to call getPersonInfo Mulesoft API
public with sharing class Mya_getPersonInfoPayload 
{
    Public Static String Token;
    //@description : Method is used for retrieving Authorition Token by passing credentials stored in Custom Metadata
    @AuraEnabled(cacheable=false)     
    public static void mya_ClientAuth()
    {  
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);        
        String postBodyToken = '{"client_id":"' + details.Agent_Token_Client_Id__c + 
                    '","client_secret":"' + details.Agent_Token_Client_Secret__c + 
                    '","audience":"' + details.Agent_Token_Audience__c + 
                    '","grant_type":"' + details.Agent_Token_Grant_Type__c + '"}';
        
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(details.Agent_Token_EndPoint_URL__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(postBodyToken);        
        request.setTimeout(60000);
        HttpResponse response;        
        response = httpCall.send(request);        
        GEAoAuthResponse  resp;
        resp = GEAoAuthResponse.parse(response.getBody());
        Token = resp.access_token;
    }
    
    //@description : Method is used for retrieving Mulesoft GetpersonInfo Data
    //Input: String GCId
    //Return: JSON String of GetpersonInfo Data
    @AuraEnabled(cacheable=false)
    Public static string getPersonInfo(String GCId)
    {
        mya_ClientAuth();
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);   
        String tok = Token;
        String AuthToken = 'Bearer ' + tok;
        
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(details.MyAccountLoginGeaURL__c + GCId);
        request.setHeader('Content-Type','application/json');
        request.setHeader('client_id',details.Name__c);
        request.setHeader('client_secret',details.Review_Link__c);
        request.setHeader('Authorization',AuthToken);
        request.setTimeout(60000);
        HttpResponse response ;        
        response = httpCall.send(request);
        return response.getBody();
    }
}
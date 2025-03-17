//******************************************************************************************
//Name : Mya_AgentApiZipHelper
//Requirement : To display PickUp Warehouse details on Order Details Page
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
//@description : Class to fetch Agent API data
public without sharing class Mya_AgentApiZipHelper 
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
    
    //@description : Method is used for retrieving Agent Zip Data
    //Input: String Zip
    //Return: JSON String of Agent API data
    @AuraEnabled(cacheable=false)
    Public static string mya_ZipDetail(String Zip)
    {
        mya_ClientAuth();
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);   
        String tok = Token;
        String AuthToken = 'Bearer ' + tok;
        String postBodyToken = '{"zipcode": "' + Zip + '"}';
        
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(details.Agent_EndPoint_URL__c);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Client_id',details.Agent_Client_Id__c);
        request.setHeader('Client_secret',details.Agent_Client_Secret__c);
        request.setHeader('Authorization',AuthToken);
        request.setBody(postBodyToken); 
        request.setTimeout(60000);
        HttpResponse response ;        
        response = httpCall.send(request);
        String JS = response.getBody();
        return JS; 
    }
}
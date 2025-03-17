//******************************************************************************************
//Name : Mya_OrderDetailApiHelper
//Requirement : To display Orders Data on My Orders and Order Details Page
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//  2.0					Yogesh Sharma			17/01/2024			Updated.
//******************************************************************************************
//@description : Class to fetch Orders API data
public without sharing class Mya_OrderDetailApiHelper
{
    //@description : Method is used for retrieving Authorition Token by passing credentials stored in Custom Metadata
    @AuraEnabled(cacheable=false)     
    public static string mya_ClientAuth()
    {  
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
        String postBodyToken = '{"client_id":"' + details.Order_Token_Client_Id__c + 
                    '","client_secret":"' + details.Order_Token_Client_Secret__c + 
                    '","audience":"' + details.Order_Token_Audience__c + 
                    '","grant_type":"' + details.Order_Token_Grant_Type__c + '"}';
        
        
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(details.Order_Token_EndPoint_URL__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(postBodyToken);        
        request.setTimeout(60000);
        HttpResponse response;        
        response = httpCall.send(request);        
        
        GEAoAuthResponse  resp;
        resp = GEAoAuthResponse.parse(response.getBody());
        Return resp.access_token;
    }
    
    //@description : Method is used for retrieving Order Data
    //Input: String Order Number
    //Return: JSON String of Order API data
    @AuraEnabled(cacheable=false)
    Public static string mya_FetchOrderDetail(String OrderNo, String OrderType, String Token)
    {
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);        
        String postBodyToken;
        String AuthToken = 'Bearer ' + Token;
        if(OrderType == 'FG')
        {
            postBodyToken ='{"P_PO_NUMBER":"","P_INVOICE":"","P_TRACKING_NUMBER":"","P_OPERATING_UNIT":"","ORIG_SYS_DOCUMENT_REF":"'+ OrderNo + '"}';
        }
        else if(OrderType == 'Parts' || OrderType == 'Concession')//Changes part of CCOE-1134
        {
            postBodyToken = '{"P_ORDER_NUMBER": ' + OrderNo + '}';
        }

        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(details.Order_EndPoint_URL__c);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Client_id',details.Order_Client_Id__c);
        request.setHeader('Client_secret',details.Order_Client_Secret__c);
        request.setHeader('Authorization',AuthToken);
        request.setBody(postBodyToken); 
        request.setTimeout(60000);
        HttpResponse response ;        
        response = httpCall.send(request);
        String JS = response.getBody();
        JSONParser parser = JSON.createParser(JS);
        while (parser.nextToken() != null) 
        {
            if ((parser.getCurrentName() == 'error') && (parser.getText() == 'Invalid token.')) 
            {
                JS = 'Error';
            }
            else if ((parser.getCurrentName() == 'P_OUT_ERROR_STATUS') && (parser.getText() == 'F')) 
            {
                JS = 'Not Found';
            }
        }
        return JS; 
    }
}
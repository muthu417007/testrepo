/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        27.05.2022
 * @description    For managing product details from AFX
 */
public without sharing class MYA_AfxAPIController {
    public MYA_AfxAPIController() {
    }
    // Search input for AFX api
    public class SearchInput {
        public String LastName { get; set; }
        public String AddressLine1 { get; set; }
        public String Locality { get; set; }
        public String Region { get; set; }
        public String PostalCode { get; set; }
        public String PhoneNumber { get; set; }
        public String EmailAddress { get; set; }
    }
    // Search product details from AFX api
    @AuraEnabled( cacheable=true )  
    public static String searchAssetsFromAFX(String AddressLine1, String Locality, String Region, String PostalCode, String PhoneNumber, String EmailAddress, String LastName) {
        try {           
        
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt MyaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            system.debug('Test ###'+MyaConfig);
            Http http = new Http();
            HttpRequest Request = new HttpRequest();
            SearchInput Input = new SearchInput();
            Input.AddressLine1 = AddressLine1;
            Input.Locality = Locality;
            Input.Region = Region;
            Input.PostalCode = PostalCode;
            Input.PhoneNumber = PhoneNumber;
            Input.EmailAddress = EmailAddress;
            Input.LastName = LastName;
            Request.setEndpoint(MyaConfig.AFX_Search_API_Endpoint__c);
            Request.setMethod(MyaConfig.AFX_Search_API_MethodType__c);
            Request.setHeader('Content-Type', 'text/json');
            Request.setHeader('Authorization', MyaConfig.AFX_Search_API_AuthToken__c);
            Request.setBody(JSON.serialize(Input));
           // Request.setTimeout(120000);
            HttpResponse Response = http.send(Request);
            System.debug('Test ### Response'+Response);
            if(Response.getStatusCode() == 200) {
                return Response.getBody();
            } else {
                return 'Error Response';
            }
            
        } catch (Exception e) {      
              System.debug('Test inside catch'+e);
            
              //  MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_AfxAPIController', 'searchAssetsFromAFX');
                throw e;
        } 
    }
}
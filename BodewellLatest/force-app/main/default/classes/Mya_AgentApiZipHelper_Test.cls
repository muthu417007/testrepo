//******************************************************************************************
//Name : Mya_AgentApiZipHelper_Test 
//Requirement : To test Mya_MyAgentDetails.Mya_MyAgentDetails and Mya_OrderDetailApiHelper.mya_ClientAuth
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//  Version		Author				Date		        Detail
//  1.0			Yogesh Sharma		07/11/2022			Initial
//******************************************************************************************
@isTest
private class Mya_AgentApiZipHelper_Test 
{
    private class Mya_AgentApiZipHelperResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().endsWith('tokens'))
            {
                System.assertEquals(details.Agent_Token_EndPoint_URL__c, req.getEndpoint());
                System.assertEquals('POST', req.getMethod());
                System.assertEquals('{"client_id":"' + details.Agent_Token_Client_Id__c 
                + '","client_secret":"' + details.Agent_Token_Client_Secret__c 
                + '","audience":"' + details.Agent_Token_Audience__c 
                + '","grant_type":"' + details.Agent_Token_Grant_Type__c + '"}',req.getBody());
                
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik5qVXdNMFUxUVVRM00wSXlNVVZCTUVSQ09EUkJSak00TURnd09UZzBNRGsyUVRNelJUazNPUSJ9.eyJpc3MiOiJodHRwczovL2dlYS1ub25wcm9kLmF1dGgwLmNvbS8iLCJzdWIiOiJCQjl0S3hVSHdKempROXhzZklqa0hBWHhsS2dZQmhsaEBjbGllbnRzIiwiYXVkIjoiZ2VhLWp3dC1hdXRob3JpemVyLW5vbi1wcmQiLCJpYXQiOjE2NTg5MjU1NjIsImV4cCI6MTY1ODkyNjQ2MiwiYXpwIjoiQkI5dEt4VUh3SnpqUTl4c2ZJamtIQVh4bEtnWUJobGgiLCJndHkiOiJjbGllbnQtY3JlZGVudGlhbHMifQ.LxtgctEPd11jFnkBe1tbW0IIQFq-AGSvVRIEqQRL9Ho77poxrAyxL6jkoaV7jq0xhTUL9tOZIrv3flOJjkCtFZPi6N9Sx1nQK848MmUyWmUTKL9uzh439hXlRl9gjII6EYIsX1iMf5VMNT76l_Fh2_n2YqIBSHXT6nXKV06Y-t07eKfWdinTSB8urmqzw1UyMUE0W5caCuAFcyyBT0M7rwPxXuuFn9C-YDq3DPsID3GmhDDeCxPaQUI2bI-3j2xo4mthRqPvdAzLusCyTS-0kMmZ2x0hbVjMc3BMr0ZWAxGiBZe-YrcAtn6qPzU1ztgPpojm-8UdSKpqpFB-GbzJeg","expires_in": 900,"token_type": "Bearer"}');
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().endsWith('agent'))
            {
                System.assertEquals(details.Agent_EndPoint_URL__c, req.getEndpoint());
                System.assertEquals('POST', req.getMethod());
                System.assertEquals(details.Agent_Client_Id__c, req.getHeader('Client_id'));
                System.assertEquals(details.Agent_Client_Secret__c, req.getHeader('Client_secret'));
                System.assertEquals('{"zipcode": "12345"}',req.getBody());
                
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"zipcode":"12345","has_home_delivery":true,"has_small_package":true,"has_sds_delivery":true,"is_will_call":false,"has_will_call":true,"sds_ap_zone":"ZONE1","hd_ap_zone":"HOME","mt_ap_zone":"ZONE1","agents":[{"zipcode":"21903","address":"238 BELVIDERE ROAD","method":"","agent_id":"BAL","phone":"410-996-2613","city":"PERRYVILLE","name":"GEA DISTRIB CTR-BALTIMORE","state":"MD","display_name":"","v_code":null,"loc_type":"adc_will_call_loc"}]}');
                res.setStatusCode(200); 
            } 
            return res;
        }
    }
    //@description : Test Method
    @isTest
    static void Mya_MyAgentDetails_test()
    {
        Test.setMock(HttpCalloutMock.class, new Mya_AgentApiZipHelperResponseGenerator());
        Mya_Agents AgDet = Mya_MyAgentDetails.Mya_MyAgentDetails('12345');
    }
}
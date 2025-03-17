//******************************************************************************************
//Name : Mya_getPersonInfoPayload_Test 
//Requirement : To display Orders Data on My Orders and Order Details Page
//EPIC/US/TASK : IDMSF- 155
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			09/09/2022			Initial
//******************************************************************************************
//@description : Class to test 
@isTest
Private with sharing class Mya_getPersonInfoPayload_Test 
{
    //@description : Mock Response Generator 
    Private class Mya_getPersonInforesponseGenerator implements HttpCalloutMock
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
                //System.assertEquals('{"client_id":"' + details.Token_Client_Id__c 
                //+ '","client_secret":"' + details.Token_Client_Secret__c 
                //+ '","audience":"' + details.Token_Audience__c 
                //+ '","grant_type":"' + details.Token_Grant_Type__c + '"}',req.getBody());
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token": "xyz","expires_in": 900,"token_type": "Bearer"}');
                res.setStatusCode(200);
            }
            else if(req.getEndpoint().containsIgnoreCase('global_customer_id='))
            {
                System.assertEquals(details.MyAccountLoginGeaURL__c + '1659519220703-100-6278036018416083364', req.getEndpoint());
                System.assertEquals('GET', req.getMethod());
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"firstName":"QAMYA","lastName":"Test","global_customer_id":"1659519220703-100-6278036018416083364","emailAddress":"qamyatest1@gmail.com","Locations":[{"addressLine1":"NoAddress","addressLine2":"","locality":"City-G","region":"ST","postalCode":"00000","country":null,"accountId":"001P000001uLq2mIAC","nickName":null,"primary":false},{"addressLine1":"7673SVineStreet7673SVineStreet","addressLine2":"","locality":"Littleton","region":"CO","postalCode":"80122","country":"UnitedStatesofAmerica","accountId":"001P000001uzVpDIAU","nickName":"Test","primary":false},{"addressLine1":"7671SVineStreet7671SVineStreet","addressLine2":"","locality":"Littleton","region":"CO","postalCode":"80121","country":"UnitedStatesofAmerica","accountId":"001P000001uzW3ZIAU","nickName":"RachelleDecker","primary":false},{"addressLine1":"307NHurstbourneLane307NHurstbourneLane","addressLine2":"","locality":"Louisville","region":"KY","postalCode":"40222","country":"UnitedStatesofAmerica","accountId":"001P000001v03XJIAY","nickName":null,"primary":false},{"addressLine1":"500HurstbournePkwy500HurstbournePkwy","addressLine2":"","locality":"NorthMiamiBeach","region":"FL","postalCode":"33160","country":"UnitedStatesofAmerica","accountId":"001P000001v03YSIAY","nickName":null,"primary":false},{"addressLine1":"500HurstbournePkwy","addressLine2":"","locality":"NorthMiamiBeach","region":"FL","postalCode":"33160","country":"UnitedStatesofAmerica","accountId":"001P000001v2LCKIA2","nickName":null,"primary":false},{"addressLine1":"201KatlianStSte108","addressLine2":"","locality":"Juneau","region":"AK","postalCode":"99803","country":"UnitedStatesofAmerica","accountId":"001P000001v2ahZIAQ","nickName":null,"primary":false},{"addressLine1":"3726LakeSt","addressLine2":"","locality":"Homer","region":"AK","postalCode":"99603","country":"UnitedStatesofAmerica","accountId":"001P000001v2ajbIAA","nickName":null,"primary":false},{"addressLine1":"105BuffaloWay","addressLine2":"","locality":"Jackson","region":"WY","postalCode":"83001","country":"UnitedStatesofAmerica","accountId":"001P000001v2alXIAQ","nickName":null,"primary":false},{"addressLine1":"501SHurstbournePkwy","addressLine2":"","locality":"Louisville","region":"KY","postalCode":"40222","country":"UnitedStatesofAmerica","accountId":"001P000001v7U4HIAU","nickName":"ApplianceForum","primary":true}],"Phones":[{"phone":"8789498456","primary":"false","phoneTypeDescription":null,"contactPointId":"a4IP0000001oWeNMAU"},{"phone":"9595899584","primary":"false","phoneTypeDescription":null,"contactPointId":"a4IP0000001oWeSMAU"},{"phone":"0987654123","primary":"false","phoneTypeDescription":null,"contactPointId":"a4IP00000028TA2MAM"},{"phone":"8878988888","primary":"false","phoneTypeDescription":null,"contactPointId":"a4IP00000028TA7MAM"},{"phone":"9078123444","primary":"false","phoneTypeDescription":null,"contactPointId":"a4IP00000028TD0MAM"},{"phone":"1213234343","primary":"false","phoneTypeDescription":null,"contactPointId":"a4IP00000028TDUMA2"},{"phone":"0909090999","primary":"false","phoneTypeDescription":null,"contactPointId":"a4IP00000028TDZMA2"},{"phone":"1234567890","primary":"true","phoneTypeDescription":null,"contactPointId":"a4IP00000028TDeMAM"},{"phone":"9686660369","primary":"false","phoneTypeDescription":null,"contactPointId":"a4IP00000028TIwMAM"}]}');
                res.setStatusCode(200); 
            } 
            return res;
        }
    }
    //@description : Test Method
    @isTest
    static void mya_getPersonInfoPayloadTest()
    {
         Test.setMock(HttpCalloutMock.class, new Mya_getPersonInforesponseGenerator());
         string payLoad = mya_getPersonInfoPayload.getPersonInfo('1659519220703-100-6278036018416083364');
    }
    //@description : Test Method
    @isTest
    static void restApiGetPersonInfoTest() 
    {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI='/services/apexrest/GlobalCustomerId/1659519220703-100-6278036018416083364';
        request.httpMethod='GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mya_getPersonInforesponseGenerator());
        mya_restApiGetPersonInfo.restApiGetPersonInfo();
        Test.stopTest();        
    }   
}
//******************************************************************************************
//Name : Mya_restApiGetPersonInfo
//Requirement : Rest Service for getPersonInfo
//EPIC/US/TASK : IDMSF- 155
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			09/09/2022			Initial
//******************************************************************************************
//@description : Rest Service for getPersonInfo
@RestResource(urlMapping='/GlobalCustomerId/*')
global with sharing class Mya_restApiGetPersonInfo 
{
    //@description : Rest Method
    @HttpGet
    global static void restApiGetPersonInfo() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //system.debug('Request Recieved from BigCommerce');
        res.addHeader('Access-Control-Max-Age', '86400'); 
        res.addHeader('Access-Control-Allow-Origin','https://staging.geappliances.com/');
        res.addHeader('Access-Control-Allow-Origin','https://stg-bc.cafeappliances.com/');
        res.addHeader('Access-Control-Allow-Origin','https://stg-bc.haierappliances.com/');     
        res.addHeader('Access-Control-Allow-Credentials','true');
        res.addHeader('Access-Control-Expose-Headers', 'Server,range,hdntl,hdnts,Authorization'); 
        res.addHeader('Access-Control-Allow-Headers', 'origin,range,hdntl,hdnts,Authorization'); 
        res.addHeader('Access-Control-Allow-Headers', 'Access-Control-Allow-Headers,Access-Control-Allow-Credentials,Access-Control-Allow-Origin, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers');
        res.addHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
        res.addHeader('Content-type', 'application/json');
        String GCId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        string result = Mya_getPersonInfoPayload.getPersonInfo(GCId);
        Mya_PersonInfoPayLoad payLoad = (Mya_PersonInfoPayLoad) JSON.deserialize(result, Mya_PersonInfoPayLoad.class);
        res.responseBody = Blob.valueOf(result);
    }
}
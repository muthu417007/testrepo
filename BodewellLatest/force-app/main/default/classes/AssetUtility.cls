/**
 * @author         Sukumar Venkatesan
 * @company        GEA
 * @created        06.Nov.2022
 * @description    This is utility  class for Asset trigger events.
					It contains all the methods which are called in before insert trigger event
 */

public class AssetUtility {
    public static void populateHerokuExtId(set<Id> assetIds){
		// create a list of all assets retrieved, need the asset id and Heroku External Id
        List<asset> assetinfolist = [select id, AssetID__c, Heroku_Ext_ID__c from asset where id in :assetIds];
        
        // create List to hold updated records, set the Heroku Ext Id field as appropriate
        List<Asset> updassetinfo = new List<Asset>();
        for (Asset a1 : assetinfolist ) {
            Asset newassetinfo = new Asset();
            newassetinfo.id = a1.id;
            if(a1.assetid__c != NULL && a1.assetid__c != a1.Heroku_Ext_ID__c)
                newassetinfo.Heroku_Ext_ID__c = a1.assetID__c;
            else if (a1.assetid__c == NULL)
            //else if (a1.Heroku_Ext_ID__c == NULL && a1.assetid__c == NULL)
               newassetinfo.Heroku_Ext_ID__c = a1.id;     
       	updassetinfo.add(newassetinfo);
        }
        //system.debug('updassetinfo: '+updassetinfo);
        if(updassetinfo.size()>0){
            update(updassetinfo);
        }
                    
    }
/*    public static void populateHerokuExtId(List<Asset> NewAssets){
        
        for (Asset a1 : NewAssets ) {
            if(a1.assetid__c != NULL && a1.assetid__c != a1.Heroku_Ext_ID__c)
                a1.Heroku_Ext_ID__c = a1.assetID__c;
            else if (a1.assetid__c == NULL)
            //else if (a1.Heroku_Ext_ID__c == NULL && a1.assetid__c == NULL)
               a1.Heroku_Ext_ID__c = a1.id;     
       	}
}*/
    Public static void validateModelNumber(List<Asset> newAssets){
    	List<Asset> assetItems = (List<Asset>) newAssets;
        System.debug('Entered in to ValidateModelNumber 1');
        for(Asset asset: assetItems) 
        {
            if(asset.Model_number__c != '' && 
              (test.isRunningTest() || asset.BrandName__c == '' || asset.Product_Type__c == '' || asset.Product_Line__c == '' ||
               asset.Product_Line_Desc__c == '' || asset.Product_Type_Desc__c== '')){
            	
            	Http http = new Http();
        		HttpRequest request = new HttpRequest();
        		request.setTimeout(15000);
        		if(utility.isSandbox){
            		request.setEndpoint('callout:Sandbox_ValidateModelNumber');   
        		} else {
            		request.setEndpoint('callout:Production_ValidateModelNumber');
        		}
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('geasfdccode','ApplServiceCloudGEA');
                request.setHeader('appname','SiebelXML');
                String postBody = ' {"request": "ModelNumberValidateRequest","payload": {"ModelNumber": "' + Asset.Model_Number__c +'","BrandCode": "", "ProductTypeCode": "", "ProductLineCode": ""}}';
                // Set the body as a JSON object
                request.setBody(postBody);
                HttpResponse response;
                System.debug('Entered in to ValidateModelNumber 2');
                if(!test.isRunningTest()){
                    response = http.send(request);
                    system.debug('request ' + postBody);
                    system.debug('response ' + response);
                    system.debug('response body ' + response.getBody());
                }
                else {
            		response = new HttpResponse();
            		response.setStatusCode(200);
            		String testBody = '{"CityName": "PALM COAST", "StateCode": "FL","PostalAreaCode": "32137", "RegionNo": "133", "ZoneCode": "35"}';
            		response.setBody(testBody);
        		}
        
                // Parse the JSON response
                if (response.getStatusCode() == 200) {
                    System.debug(response.getBody());
                    modelNumberResponse resp = modelNumberResponse.parse(response.getBody());
                    Asset.BrandName__c = resp.BrandCode;
                    Asset.Product_Type__c = resp.ProductTypeCode;
                    Asset.Product_Line__c = resp.ProductLineCode;
                    Asset.Product_Line_Desc__c = resp.ProductLineDesc;
                    Asset.Product_Type_Desc__c = resp.ProductTypeDesc;
				} 	
	        }
        }
    }
}
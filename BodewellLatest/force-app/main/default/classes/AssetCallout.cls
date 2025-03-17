public class AssetCallout {
    @InvocableMethod(label='Update Asset Info' description='Update Asset Info')

    public static List<List<String>> updateAsset(List<String> assetId) {
        //make callout  
        List<List<String>> returnList = new List<List<String>>();
        List<String> resId = new List<String>();
        List<Asset> updateAssets = [SELECT ID,Model_number__c, BrandName__c,Product_Type__c,Product_Line__c,Product_Line_Desc__c,Product_Type_Desc__c
            FROM Asset
            WHERE ID in :assetId];
        List<Asset> updateAssetList = new List<Asset>();
        
        if(updateAssets.size() == 0){
            resId.add(string.valueOf('Error - Asset not found'));
            returnList.add(resId);
        }
        
        for(Asset ass:updateAssets){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(15000);
            //request.setEndpoint('https://gc9zw2x6fa.execute-api.us-east-1.amazonaws.com/DEV/validatemodelnumber');
            if(utility.isSandbox){
                request.setEndpoint('callout:Sandbox_ValidateModelNumber');   
            } else {
                request.setEndpoint('callout:Production_ValidateModelNumber');
            }
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('geasfdccode','ApplServiceCloudGEA');
            request.setHeader('appname','SiebelXML');
            String postBody = ' {"request": "ModelNumberValidateRequest","payload": {"ModelNumber": "' + ass.Model_Number__c +'","BrandCode": "", "ProductTypeCode": "", "ProductLineCode": ""}}';
          //  {"request": "ModelNumberValidateRequest","payload": {"ModelNumber": "GSD2100VBB","BrandCode": "", "ProductTypeCode": "", "ProductLineCode": ""}}
            // Set the body as a JSON object
            request.setBody(postBody);
            HttpResponse response;
            if(!test.isRunningTest()){
                response = http.send(request);
                system.debug('request ' + postBody);
                system.debug('response ' + response);
                system.debug('response body ' + response.getBody());
            } else {
                response = new HttpResponse();
                response.setStatusCode(200);
                String testBody = '{"CityName": "PALM COAST", "StateCode": "FL","PostalAreaCode": "32137", "RegionNo": "133", "ZoneCode": "35"}';
                response.setBody(testBody);
            }
            
            // Parse the JSON response
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                modelNumberResponse resp = modelNumberResponse.parse(response.getBody());
                ass.BrandName__c = resp.BrandCode;
                ass.Product_Type__c = resp.ProductTypeCode;
                ass.Product_Line__c = resp.ProductLineCode;
                ass.Product_Line_Desc__c = resp.ProductLineDesc;
                ass.Product_Type_Desc__c = resp.ProductTypeDesc;
                updateAssetList.add(ass);
                //update updateAsset;
                resId.add(string.valueOf(ass.id));
          		returnList.add(resId);
                
            } else {
                system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                String errorMessage = 'Error ' + response.getStatusCode() + ' ' + response.getStatus();
                resId.add(string.valueOf(errorMessage));
          		returnList.add(resId);
            }    
      
     }
        if(updateAssetList.size() > 0){
            update updateAssetList;
        }
      return returnList;
    }
}
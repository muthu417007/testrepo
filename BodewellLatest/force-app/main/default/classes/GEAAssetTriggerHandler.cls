public class GEAAssetTriggerHandler {

    public static void getGEAAssetInfo(List<Asset> geaAssetList){
        for(Asset objGEAAsset :geaAssetList){
            GEAAssetTriggerHandler.sendGEAAssetInfo(objGEAAsset.Ductless_product_registration__c, objGEAAsset.Id,objGEAAsset.DFS_Primary_Asset__c);                             
        }
    }
     
    @future (callout=true)
    public static void sendGEAAssetInfo(String ductlessRegId, String assetId, String geaPrimaryAsset) {
        	
        Ductless_product_registration__c dfs_reg = new Ductless_product_registration__c();
        try{
         	dfs_reg = [Select outdoor_unit_model__c, outdoor_unit_serial__c, indoor_unit_1_model__c, indoor_unit_1_serial__c, 
                                                                    indoor_unit_2_model__c, indoor_unit_2_serial__c, indoor_unit_3_model__c, indoor_unit_3_serial__c, 
                                                                    indoor_unit_4_model__c, indoor_unit_4_serial__c, indoor_unit_5_model__c, indoor_unit_5_serial__c, 
                                                                    indoor_unit_6_model__c, indoor_unit_6_serial__c, indoor_unit_7_model__c, indoor_unit_7_serial__c, 
                                                                    indoor_unit_8_model__c, indoor_unit_8_serial__c, indoor_unit_9_model__c, indoor_unit_9_serial__c,
                                                                    install_date__c 
                                                                FROM Ductless_product_registration__c Where Id = :ductlessRegId LIMIT 1];
           
        }catch(Exception ex){
            return;
        }
            
         
        String modelNumber, serialNo, postBody;
        Date installDate;
           
        if(geaPrimaryAsset == 'Outdoor 1'){
            modelNumber = dfs_reg.outdoor_unit_model__c;            
            serialNo = dfs_reg.outdoor_unit_serial__c;
            installDate = dfs_reg.install_date__c;                    
        }else if(geaPrimaryAsset == 'Indoor 1'){
            modelNumber = dfs_reg.indoor_unit_1_model__c;            
            serialNo = dfs_reg.indoor_unit_1_serial__c;
            installDate = dfs_reg.install_date__c;                       
        }else if(geaPrimaryAsset == 'Indoor 2'){
            modelNumber = dfs_reg.indoor_unit_2_model__c;            
            serialNo = dfs_reg.indoor_unit_2_serial__c;
            installDate = dfs_reg.install_date__c;
        }else if(geaPrimaryAsset == 'Indoor 3'){
            modelNumber = dfs_reg.indoor_unit_3_model__c;            
            serialNo = dfs_reg.indoor_unit_3_serial__c;
            installDate = dfs_reg.install_date__c;
        }else if(geaPrimaryAsset == 'Indoor 4'){
            modelNumber = dfs_reg.indoor_unit_4_model__c;            
            serialNo = dfs_reg.indoor_unit_4_serial__c;
            installDate = dfs_reg.install_date__c;
        }else if(geaPrimaryAsset == 'Indoor 5'){
            modelNumber = dfs_reg.indoor_unit_5_model__c;            
            serialNo = dfs_reg.indoor_unit_5_serial__c;
            installDate = dfs_reg.install_date__c;
        }else if(geaPrimaryAsset == 'Indoor 6'){
            modelNumber = dfs_reg.indoor_unit_6_model__c;            
            serialNo = dfs_reg.indoor_unit_6_serial__c;
            installDate = dfs_reg.install_date__c;
        }else if(geaPrimaryAsset == 'Indoor 7'){
            modelNumber = dfs_reg.indoor_unit_7_model__c;            
            serialNo = dfs_reg.indoor_unit_7_serial__c;
            installDate = dfs_reg.install_date__c;
        }else if(geaPrimaryAsset == 'Indoor 8'){
            modelNumber = dfs_reg.indoor_unit_8_model__c;            
            serialNo = dfs_reg.indoor_unit_8_serial__c;
            installDate = dfs_reg.install_date__c;
        }else if(geaPrimaryAsset == 'Indoor 9'){
            modelNumber = dfs_reg.indoor_unit_9_model__c;            
            serialNo = dfs_reg.indoor_unit_9_serial__c;
            installDate = dfs_reg.install_date__c;
        }
        
        try{
            if(modelNumber!=Null)
                modelNumber = modelNumber.toUpperCase();
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(25000);
            
            if(utility.isSandbox){
                request.setEndpoint('callout:Sandbox_ValidateModelNumber');   
            } else {
                request.setEndpoint('callout:Production_ValidateModelNumber');
            }
            
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('geasfdccode','ApplServiceCloudGEA');
            request.setHeader('appname','SiebelXML');
            if(modelNumber!=Null)
            postBody = ' {"request": "ModelNumberValidateRequest","payload": {"ModelNumber": "' + modelNumber.trim() +'","BrandCode": "", "ProductTypeCode": "", "ProductLineCode": ""}}';
            if(postBody!=Null)
            request.setBody(postBody);
            HttpResponse response;
            
            if(!test.isRunningTest()){
                response = new HttpResponse();
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
            
            List<Asset> newAssetList = new List<Asset>();
            Asset newAsset = [Select Id,SerialNumber,Model_Number__c, BrandName__c,Product_Type__c,Product_Line__c,Product_Line_Desc__c,Product_Type_Desc__c From Asset Where Id =: assetId];
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                modelNumberResponse resp = modelNumberResponse.parse(response.getBody());
                newAsset.BrandName__c = resp.BrandCode;
                newAsset.Product_Type__c = resp.ProductTypeCode;
                newAsset.Product_Line__c = resp.ProductLineCode;
                newAsset.Product_Line_Desc__c = resp.ProductLineDesc;
                newAsset.Product_Type_Desc__c = resp.ProductTypeDesc;
                newAsset.Model_Number__c = modelNumber;
                newAsset.SerialNumber = serialNo;
                newAsset.InstallDate = installDate;
                newAsset.name = modelNumber + '-' + serialNo; 
                if(installDate !=  Null && (installDate.addYears(10) > System.today())){
                    newAsset.In_Warranty_asset__c = 'Yes';    
                }else{
                    newAsset.In_Warranty_asset__c = 'No';
                }
                newAssetList.add(newAsset);
            }else{
                newAsset.Model_Number__c = modelNumber;
                newAsset.SerialNumber = serialNo;
                newAsset.InstallDate = installDate;
                newAsset.name = modelNumber + '-' + serialNo;
                if(installDate !=  Null && (installDate.addYears(10) > System.today())){
                    newAsset.In_Warranty_asset__c = 'Yes';    
                }else{
                    newAsset.In_Warranty_asset__c = 'No';
                }
                newAssetList.add(newAsset);
            }
            
            if(newAssetList.size()>0)
                update newAssetList;
        }
        catch(System.CalloutException e){
            System.debug('Error-' + e.getMessage());   
        }
    }
}
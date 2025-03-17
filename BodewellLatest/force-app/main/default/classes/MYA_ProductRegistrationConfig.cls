/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        07.06.2022
 * @description    For getting product registration configurations
 */
public with sharing class MYA_ProductRegistrationConfig {
    // For getting product registration configurations
	@AuraEnabled(cacheable=true)
    public static ProductRegistrationConfigResponse getProductRegistrationConfig(Boolean isGuestUser) {          
        ProductRegistrationConfigResponse response = new ProductRegistrationConfigResponse();         
        try {
            String selectedLabel; 
            String selectedQrLabel;
            if(isGuestUser) {
                selectedLabel = 'Online guest prod reg';
                selectedQrLabel = 'qr guest';
            }
            else {
                selectedLabel = 'Account prod reg';
                selectedQrLabel = 'qr login';
            }
            String domainUrl = Url.getOrgDomainUrl().getHost();            
            List<MYA_ProdReg_ReviewLink__mdt> prodRegReviewLinks = MYA_MetaDataConfigHelper.getProdRegReviewLinks();            
            MYA_Configuration__mdt myaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            response.ReviewLinks = prodRegReviewLinks;
            MYA_Assurant_Service_Setting assurantServiceConfig = new MYA_Assurant_Service_Setting();
            assurantServiceConfig.Endpoint = myaConfig.Assurant_Service_Endpoint__c;
            assurantServiceConfig.End_Parameters = myaConfig.Assurant_Service_Endpoint_Endparameters__c;
            response.AssurantSiteConfig = assurantServiceConfig;
            List<Data_Source_Code__mdt> dataSourceCode = [SELECT Id, Label, HA__c, GEA__c, Cafe__c,Bodewell__c FROM Data_Source_Code__mdt WHERE Label IN (:selectedQrLabel, :selectedLabel)]; 
            if(dataSourceCode.size() > 0) {                
                for(Data_Source_Code__mdt data : dataSourceCode){
                    if(data.Label == selectedQrLabel)
                    {                 
                        response.QrDataSourceCode = data;
                    }
                    else 
                    {
                        response.DataSourceCode = data;
                    }                
                }
            }
            response.Success = true;
            
            return response;
        } catch (Exception e) {              
         	//MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_ProductRegistrationConfig', 'getProductRegistrationConfig');
            response.Error = e;
            response.Success = false;
            return response;
        }                
    }
    
    public class MYA_ProdReg_ReviewLink {
        @AuraEnabled public String Brand;
        @AuraEnabled public String ReviewLink;
        @AuraEnabled public String CampaignId;
    }
    
    public class MYA_Assurant_Service_Setting {
        @AuraEnabled public String Endpoint;
        @AuraEnabled public String End_Parameters;
    }
    
    public class ProductRegistrationConfigResponse {
        @AuraEnabled public MYA_Assurant_Service_Setting AssurantSiteConfig;
        @AuraEnabled public Data_Source_Code__mdt QrDataSourceCode;
        @AuraEnabled public Data_Source_Code__mdt DataSourceCode;
        @AuraEnabled public List<MYA_ProdReg_ReviewLink__mdt> ReviewLinks;        
        @AuraEnabled public Object Error;
        @AuraEnabled public Boolean Success;
    }
     // For getting product SMC details
    @AuraEnabled(cacheable=true)
    public static SMCConfigResponse getSMCData(String[] modelNumbers) { 
        SMCConfigResponse response = new SMCConfigResponse();
        try {
            List<SMCConfig> configList = new List<SMCConfig>();
            for(String modelNumber: modelNumbers) 
          	{                    
            	SMCConfig config = new SMCConfig();
             	config.Model = modelNumber;
                String key = '%' + modelNumber.left(3) + '%';
            	config.SMCDataList = [SELECT Id, Model_No__c, Brand_Code__c, Product_Line_Code__c FROM SMCModelCA__c WHERE Model_No__c LIKE :key];
				configList.add(config);
        	}
            response.SMCConfigList = configList;
            response.Success = true;
            return response;
        } catch (Exception e) {              
         	MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_ProductRegistrationConfig', 'getSMCData');
            response.Success = false;
            return response;
        }                
    }
    
    public class SMCConfig {
        @AuraEnabled public String Model;
        @AuraEnabled public List<SMCModelCA__c> SMCDataList;
    }
    
    public class SMCConfigResponse {
        @AuraEnabled public List<SMCConfig> SMCConfigList;        
        @AuraEnabled public Object Error;
        @AuraEnabled public Boolean Success;
    }
}
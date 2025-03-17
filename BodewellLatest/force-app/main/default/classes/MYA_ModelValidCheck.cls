public without sharing class MYA_ModelValidCheck {
    // Model validity response
    public class ModelValidityResponse {
        @AuraEnabled public List<Model_Rel__c> ModelRelation;
        @AuraEnabled public Object Error;        
        @AuraEnabled public String Input;
        @AuraEnabled public Boolean IsValid;
        @AuraEnabled public Boolean Success;
    }
    
    @AuraEnabled(cacheable = false)
    public static ModelValidityResponse MYA_marketingModelValidityCheck(String marketingModelNumber) {
        ModelValidityResponse response = new ModelValidityResponse();
        try {
            response.Input = marketingModelNumber;
            response.ModelRelation = [select id,MN__c,MR_PKMOD__c from Model_Rel__c where MR_PKMOD__c=: marketingModelNumber];
            if(response.ModelRelation.size() > 0) {
                response.IsValid = true;
            } else {
                response.IsValid = false;
            }
            response.Success = true;
            return response;            
        } catch (Exception e) {              
            	MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_ModelValidCheck', 'MYA_marketingModelValidityCheck');
            	response.Success = false;
            	return response;
        }  
    }
    
    @AuraEnabled(cacheable = false)
    public static ModelValidityResponse MYA_manufacturingModelValidityCheck(String manufacturingModelNumber) {
        ModelValidityResponse response = new ModelValidityResponse();
        try {
            response.Input = manufacturingModelNumber;
            response.ModelRelation = [select id,MN__c,MR_PKMOD__c from Model_Rel__c where MN__c=: manufacturingModelNumber];
			if(response.ModelRelation.size() > 0) {
                response.IsValid = true;
            } else {
                response.IsValid = false;
            }
            response.Success = true;
            return response;            
        } catch (Exception e) {              
            	MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_ModelValidCheck', 'MYA_manufacturingModelValidityCheck');
            	response.Success = false;
            	return response;
        }  
    }
    
    @AuraEnabled(cacheable = false)
    public static Integer MYA_modelValidityCheckkforMarketing(String marketingModel) {
         List<Model_Rel__c> modelCheckingValidation=[select id,MN__c,MR_PKMOD__c from Model_Rel__c where MR_PKMOD__c=: marketingModel ]; 
         return modelCheckingValidation.size();
    }
    
    @AuraEnabled(cacheable = false)
    public static Integer MYA_modelValidityCheckkforManufacturing(String manufacturingModel) {
        List<Model_Rel__c>  modelCheckingValidation=[select id,MN__c,MR_PKMOD__c from Model_Rel__c where MN__c=:manufacturingModel ]; 
        return modelCheckingValidation.size();
    }
    @AuraEnabled(cacheable = false)
    public static Integer MYA_productLineCode(string SKU) {
       
        String ModelNumberStr = SKU;            
       	Boolean IsFound = false;
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt myaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
        string nonServiceString = myaConfig.CampaignId_Parameter__c;
        list<string> nonServiceCodes = nonServiceString.split(',');
        
        
        do 
        {
            system.debug(ModelNumberStr);
            List <SMCModelCA__c> SMCModelList = [SELECT Id, Brand_Code__c, Product_Line_Code__c FROM SMCModelCA__c WHERE Model_No__c=:ModelNumberStr];
            if(SMCModelList.size() > 0 && SMCModelList[0].Product_Line_Code__c!=null) 
        	{
                system.debug(SMCModelList[0].Product_Line_Code__c);
                for(string ES:nonServiceCodes)
                {
                    system.debug(IsFound);
                    if(SMCModelList[0].Product_Line_Code__c == ES)
                    {
                        IsFound = true;
                    	system.debug(IsFound);
                    }
                }
        	}
            ModelNumberStr = ModelNumberStr.left(ModelNumberStr.length()-1);
        } while (!IsFound && ModelNumberStr.length() > 2);
        
               
        if(IsFound == true) {
            return 1;
        } else {
      		return 0;
        }  
    }  
    
     @AuraEnabled(cacheable = false)
    public static String mya_getContact() {
        string user1 = UserInfo.getUserId();
        String contactId=[select id, Contact.Global_Customer_Id__c from User where id=:user1].Contact.Global_Customer_Id__c;
        system.debug('contactId'+contactId);
        return contactId;
    }      
    
}
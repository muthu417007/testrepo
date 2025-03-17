//******************************************************************************************
//Name : Mya_AgentDetails 
//Requirement : NVR - To add records to Web Consumer Info when we search AFX rexords
//EPIC/US/TASK : IDMSF- 1000, IDMSF- 1186
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Srinivas Siddireddi		08/01/2022			Initial
//******************************************************************************************
//@description : Wrapper Class to handle Agent API data after Deserializing
public class MYA_WebConsumerInfoController {
    // Asset creation method
    @AuraEnabled(cacheable=false)  
    public static SaveAssetResponse saveAssets(String ModelNumber, String SerialNumber,String InstallationDate,String DataSourceCode,String AccountId,String ContactId,Boolean IsValidModelNumber) {
        system.debug('In web consumer controller');
        SaveAssetResponse Response = new SaveAssetResponse();
        try {
            //Boolean IsNotDeleted = false;
            List <WebConsumerInfo__c> WebConsList = [SELECT Id FROM WebConsumerInfo__c WHERE Model_number__c=:ModelNumber AND Serial_Number__c=:SerialNumber];
            system.debug('WebConsList '+WebConsList);   	
            if(WebConsList.size() == 0) {
                WebConsumerInfo__c WebConsObj = new WebConsumerInfo__c();
                WebConsObj.Model_number__c = ModelNumber;
                WebConsObj.Serial_Number__c = SerialNumber;
                WebConsObj.Data_Source_Code__c = DataSourceCode;              
                insert WebConsObj;                    
                Response.Asset = WebConsObj;
                Response.Message = 'Asset Inserted';                    
                Response.AlreadyExist = false;
            } else {
                Response.Asset = WebConsList[0];
                Response.Message = 'Already Exist';
                Response.AlreadyExist = true;
            }            
            Response.Success = true;
            system.debug('Response '+Response); 
            return Response;
        } catch (Exception e) {
            Response.Error = e;
            Response.Message = 'Error occured';
            Response.Success = false;
            system.debug('catch Response '+Response); 
            return Response;
        }        
    }
    // Asset creation method response
    public class SaveAssetResponse {
        @AuraEnabled public Object Asset;
        @AuraEnabled public Object Error;
        @AuraEnabled public String Message;
        @AuraEnabled public Boolean AlreadyExist;
        @AuraEnabled public Boolean Success;
    }
}
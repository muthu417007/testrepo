/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        07.05.2022
 * @description    For manage user account details
 */
public without sharing class MYA_AccountController {   
    public class AccountControllerException extends Exception {}    
    // Asset creation method
    @AuraEnabled( cacheable=false )  
    public static SaveAssetResponse saveAssets(String ModelNumber, String SerialNumber,String InstallationDate,String DataSourceCode,String AccountId,String ContactId,Boolean IsEndecaModelNumber) {
        SaveAssetResponse response = new SaveAssetResponse();
        try {
            	Boolean isDeleted = false;
            	List <Asset> assetList = [SELECT Id, AccountId FROM Asset WHERE OriginalModelNumber__c=:ModelNumber AND SerialNumber=:SerialNumber AND AccountId=:AccountId AND Deleted__c=:isDeleted];
               	if(assetList.size() == 0) {
                    Asset geaAssetObj = new Asset();
                    geaAssetObj.OriginalModelNumber__c = ModelNumber;
                    geaAssetObj.SerialNumber = SerialNumber;
                    geaAssetObj.InstallDate = date.parse(InstallationDate);
                    geaAssetObj.OwnershipStartedOn__c = date.parse(InstallationDate);
                    geaAssetObj.DataSourceCode__c = DataSourceCode;
                    geaAssetObj.AccountId = AccountId;
                    geaAssetObj.ContactId = ContactId;
                    //geaAssetObj.MYA_Included__c = true; 
                    geaAssetObj.Deleted__c = false;
                    insert geaAssetObj;                    
            		response.Asset = geaAssetObj;
                    response.Message = 'Asset Inserted';                    
                    response.AlreadyExist = false;
                } 
            	else {
                    response.Asset = assetList[0];
                 	response.Message = 'Already Exist';
                    response.AlreadyExist = true;
                }   
            	response.Success = true;
            	return response;
        } catch (Exception e) {
            	MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_AccountController', 'saveAssets');
            	response.Error = e;
            	response.Message = 'Error occured';
            	response.Success = false;
            	return response;
        }        
    }
    // Asset creation method response
    public class SaveAssetResponse 
    {
        @AuraEnabled public Object Asset;
        @AuraEnabled public Object Error;
        @AuraEnabled public String Message;
        @AuraEnabled public Boolean AlreadyExist;
        @AuraEnabled public Boolean Success;
    }
    // Asset Register method for product registration and AFX search
    @AuraEnabled( cacheable=false )  
    public static SaveAssetResponse registerAssets(AssetRegisterInput assetInput, AssetRegisterAddressInput addressInput, String dataSourceCode, String accountId, String contactId, Boolean isEndecaModelNumber, String qrLink) {
        
        SaveAssetResponse response = new SaveAssetResponse();
        try 
        {            
            	Boolean isDeleted = false;             
              	Asset geaAssetObj = new Asset(); 
            	List <Asset> assetList = new List <Asset>(); 
            	if(assetInput.AFXAssetId != null) 
                {  
                    assetList = [SELECT Id, AccountId FROM Asset WHERE AssetID__c =:assetInput.AFXAssetId OR (OriginalModelNumber__c=:assetInput.ModelNumber AND SerialNumber=:assetInput.SerialNumber AND AccountId=:accountId AND Deleted__c=:isDeleted)]; 
               	} 
                else 
                { 
                   	assetList = [SELECT Id, AccountId FROM Asset WHERE OriginalModelNumber__c=:assetInput.ModelNumber AND SerialNumber=:assetInput.SerialNumber AND AccountId=:accountId AND Deleted__c=:isDeleted];
              	}
            	if(assetList.size() == 0) 
                { 
                 	geaAssetObj.AssetID__c = assetInput.AFXAssetId; 
                    geaAssetObj.OriginalModelNumber__c = assetInput.ModelNumber; 
                    geaAssetObj.SerialNumber = assetInput.SerialNumber;
                    system.debug('Install Date :' +assetInput.InstallationDate);
                    geaAssetObj.InstallDate = date.parse(assetInput.InstallationDate);
                    geaAssetObj.OwnershipStartedOn__c = date.parse(assetInput.InstallationDate);
                    geaAssetObj.DataSourceCode__c = dataSourceCode;
                    geaAssetObj.AccountId = accountId;
                    geaAssetObj.ContactId = contactId;
                    //geaAssetObj.MYA_Included__c = true; 
                    geaAssetObj.Deleted__c = false;
                    insert geaAssetObj;                    
            		response.Asset = geaAssetObj;
                    response.Message = 'Asset Inserted';                    
                    response.AlreadyExist = false;                    
            
                    String bussinessExceptionStr = 'Model ';
                    Boolean isException = false;
                    //List <GEA_Asset__c> geaAsset = [SELECT Id, ModelValidityFlag__c, BrandName__c, Product_Line__c FROM GEA_Asset__c WHERE Id=:GeaAssetObj.Id];
                    Asset assetInfo = [SELECT Id, OriginalModelNumber__c, SerialNumber, InstallDate, Product_Line__c, BrandName__c, ModelValidityFlag__c FROM Asset WHERE Id=:GeaAssetObj.Id LIMIT 1];
                    if(assetInfo != null ) 
                    {                        
                        if(assetInfo.ModelValidityFlag__c == true)
                        {
                            bussinessExceptionStr += 'available in MMR ';
                        } 
                        else 
                        {
                            bussinessExceptionStr += 'not available in MMR ';
                            isException = true;
                        }	
                        
                        if(IsEndecaModelNumber == true)
                        {
                            bussinessExceptionStr += 'available in MDM ';
                        } 
                        else 
                        {
                            bussinessExceptionStr += 'not available in MDM ';
                            isException = true;
                        }	
                    
                        if(assetInfo.BrandName__c != Null || assetInfo.Product_Line__c != Null)
                        {
                            bussinessExceptionStr += 'present in Services';
                        } 
                        else 
                        {
                            bussinessExceptionStr += 'not present in Services';
                            isException = true;
                        }
                        registerWebConsumerInfo(assetInfo, addressInput, dataSourceCode, isException, bussinessExceptionStr, qrLink); 
                    } 
                    else 
                    {
                        MYA_ApplicationErrorLog.Mya_CustomExHandler('Asset Info not found', 'MYA_AccountController', 'registerAssets');
                        response.Message = 'Asset Info not found';
                    }
                } 
            	else 
                {
                    response.Asset = assetList[0];
                 	response.Message = 'Already Exist';
                    response.AlreadyExist = true;
                } 
            	response.Success = true;
            	return response;
        } 
        catch (Exception e) 
        {              
            	MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_AccountController', 'registerAssets');
            	response.Error = e;
            	response.Message = 'Error occured';
            	response.Success = false;
            	return response;
        }       
    }
    // Asset creation method response
    public class AssetRegisterInput 
    {        
        @AuraEnabled public String AFXAssetId { get; set; } 
      	@AuraEnabled public String ModelNumber { get; set; }  
      	@AuraEnabled public String SerialNumber { get; set; }
        @AuraEnabled public String InstallationDate { get; set; }        
    }
    // Asset creation method response
    public class AssetRegisterAddressInput 
    {        
      	@AuraEnabled public String Address1 { get; set; }  
      	@AuraEnabled public String City { get; set; }
        @AuraEnabled public String State { get; set; }        
        @AuraEnabled public String PostalCode { get; set; }
        @AuraEnabled public String Firstname { get; set; }
        @AuraEnabled public String Lastname { get; set; }        
        @AuraEnabled public String Email { get; set; }
        @AuraEnabled public String Phone { get; set; }
    }
    // Web consumer info creation on Asset Register
    @AuraEnabled( cacheable=false )  
    public static void registerWebConsumerInfo(Asset assetInput, AssetRegisterAddressInput addressInput, String dataSourceCode, Boolean isError, String message, String qrLink)
    {
        try 
        {  
            WebConsumerInfo__c webConsumerInfoObj = new WebConsumerInfo__c(); 
            if(assetInput != null) 
            { 
                webConsumerInfoObj.Model_number__c  = (assetInput.OriginalModelNumber__c != null && assetInput.OriginalModelNumber__c.length() > 40) ? assetInput.OriginalModelNumber__c.substring(0,40) : assetInput.OriginalModelNumber__c;
                webConsumerInfoObj.Serial_Number__c =(assetInput.SerialNumber != null && assetInput.SerialNumber.length() > 20) ? assetInput.SerialNumber.substring(0,20) : assetInput.SerialNumber;
                webConsumerInfoObj.Install_date__c = assetInput.InstallDate;
                webConsumerInfoObj.Product_line_Code__c = (assetInput.Product_Line__c != null && assetInput.Product_Line__c.length() > 3) ? assetInput.Product_Line__c.substring(0,3) : assetInput.Product_Line__c;
                webConsumerInfoObj.Brand_Code__c = (assetInput.BrandName__c != null && assetInput.BrandName__c.length() > 3) ? assetInput.BrandName__c.substring(0,3) : assetInput.BrandName__c;
                webConsumerInfoObj.Is_Error__c = assetInput.ModelValidityFlag__c ? false : true;
            }
            if(addressInput != null) 
            {
                webConsumerInfoObj.Name =(addressInput.Firstname != null && addressInput.Firstname.length() > 80) ? addressInput.Firstname.substring(0,80) : addressInput.Firstname;
                webConsumerInfoObj.Last_Name__c = (addressInput.Lastname != null && addressInput.Lastname.length() > 20) ? addressInput.Lastname.substring(0,20) : addressInput.Lastname;
                webConsumerInfoObj.Email_Address__c  = addressInput.Email;
                webConsumerInfoObj.Phone_Number__c = (addressInput.Phone != null && addressInput.Phone.length() > 40) ? addressInput.Phone.substring(0,40) : addressInput.Phone;
                webConsumerInfoObj.Billing_Street__c = (addressInput.Address1 != null && addressInput.Address1.length() > 40) ? addressInput.Address1.substring(0,40) : addressInput.Address1;
                webConsumerInfoObj.Billing_City__c = (addressInput.City != null && addressInput.City.length() > 25) ? addressInput.City.substring(0,25) : addressInput.City;
                webConsumerInfoObj.Billing_State__c = addressInput.State;                  
                webConsumerInfoObj.Billing_Zip_Prefix__c = (addressInput.PostalCode != null && addressInput.PostalCode.length() > 5) ? addressInput.PostalCode.substring(0,5) : addressInput.PostalCode;
                if(addressInput.PostalCode != null && addressInput.PostalCode.length() >= 9) 
                {
                    webConsumerInfoObj.Billing_Zip_Suffix__c = addressInput.PostalCode.substring(5,9);
               	} 
                if(addressInput.PostalCode != null && addressInput.PostalCode.length() < 9 && addressInput.PostalCode.length() > 5)
                {
                    webConsumerInfoObj.Billing_Zip_Suffix__c = addressInput.PostalCode.substring(5,addressInput.PostalCode.length());
                }
            }
            if(dataSourceCode != null) 
            {
                webConsumerInfoObj.Data_Source_Code__c = (dataSourceCode.length() > 2) ? dataSourceCode.substring(0,2) : dataSourceCode;
            }
            if(qrLink != null) 
            {
                webConsumerInfoObj.Mobile_QR_Link__c = (qrLink != '') ? qrLink : Null;
            }            
            if(isError == true)
         	{
                webConsumerInfoObj.MYA_Bussiness_Exception__c = true;
              	webConsumerInfoObj.MYA_Bussiness_Exception_Message__c = message;
            }
            insert webConsumerInfoObj; 
        } 
        catch (Exception ex) 
        {
        	throw ex; 
        }
    }    
}
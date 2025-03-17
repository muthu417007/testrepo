/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        17.05.2022
 * @description    For manage product registration
 */
public without sharing class MYA_ProductRegistrationController {
    // Get account details
	@AuraEnabled(Cacheable=true)
    public static AccountInfoResponse getAccountInfo(String UserId){
        AccountInfoResponse Response = new AccountInfoResponse();
        
        try {
            List<User> UserData = [SELECT Id, Name, FirstName, LastName, Email, ContactId FROM User WHERE Id=:UserId];
            Response.UserDetails = UserData[0];
            List<Contact> ContactData = [SELECT Id, Name, FirstName, LastName, Email FROM Contact WHERE Id=:UserData[0].ContactId];
            Response.ContactDetails = ContactData[0];
            Boolean MYA_Included = true;
            Boolean Mya_Deleted = false;
            List<Account> AccountsData = [SELECT Name,BillingStreet,BillingCountry,BillingCity,BillingState,BillingPostalCode FROM Account WHERE Id IN (SELECT Account__c FROM GEA_AccountContactRelation__c WHERE Contact__c=:UserData[0].ContactId AND MYA_Included__c=:MYA_Included)];
            
            for(Account account:AccountsData)
            {
                account.BillingPostalCode = (account.BillingPostalCode.length() > 5) ? account.BillingPostalCode.substring(0,5) : account.BillingPostalCode;                                
            }
            
            response.AddressList = AccountsData;
            system.debug('addresslist'+response.AddressList);
            List<Contact_Point__c> ContactPoints = [SELECT Id,Phone__c,MYAISPrimary__c FROM Contact_Point__c WHERE Contact__c = :UserData[0].ContactId AND MYA_Included__c=:MYA_Included AND MYA_IsDeleted__c=:Mya_Deleted];
            response.ContactPoints = ContactPoints;
            Response.Success = true;
            system.debug('response'+response);
           	return Response;
        } catch(Exception ex) {              
         	MYA_ApplicationErrorLog.Mya_ExHandler(ex, 'MYA_ProductRegistrationController', 'getAccountInfo');
            Response.Error = ex;
            Response.Success = false;
            return Response;
        }       
   }
    // Account info response
    public class AccountInfoResponse {
        @AuraEnabled public Object UserDetails;
        @AuraEnabled public Object ContactDetails;
        @AuraEnabled public Object AddressList;
        @AuraEnabled public Object ContactPoints;
        @AuraEnabled public Object Error;
        @AuraEnabled public Boolean Success;
    }
    // Consent verification method
    @AuraEnabled(cacheable=false)
    public static ConsentVerificationResponse userConsentVerification() {
        ConsentVerificationResponse Response = new ConsentVerificationResponse();
        try {
            MYA_GuestConsentVerification ConsentVerification = new MYA_GuestConsentVerification();
            if(!Test.isRunningTest()){
              ConsentVerification.getGuestUserVerification();
             }       
            Response.Success = true;
            return Response;
        } catch (Exception e) {              
         	MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_ProductRegistrationController', 'userConsentVerification');
            Response.Success = false;
            Response.Error = e;
            return Response;
        }
    }
    // Consent verification method response
    public class ConsentVerificationResponse {
        @AuraEnabled public Object Error;
        @AuraEnabled public Boolean Success;
    }
    // Asset creation method
    @AuraEnabled( cacheable=false )  
    public static CheckAssetExistingResponse checkAssets(AssetInput[] AssetInputs, String AccountId) {
        CheckAssetExistingResponse Response = new CheckAssetExistingResponse();
        try {     
            	Boolean IsAlreadyExist = false;
            	List<AssetResultResponse> ResultResponseList = new List<AssetResultResponse>();
                for(AssetInput AssetItem: AssetInputs) {
                    AssetResultResponse ResultResponse = new AssetResultResponse();
                    ResultResponse.ModelNumber = AssetItem.ModelNumber;
                    ResultResponse.SerialNumber = AssetItem.SerialNumber;
                    Boolean IsNotDeleted = false;
                    List <Asset> AssetList = [SELECT Id, AccountId FROM Asset WHERE OriginalModelNumber__c=:AssetItem.ModelNumber AND SerialNumber=:AssetItem.SerialNumber AND AccountId=:AccountId AND Deleted__c=:IsNotDeleted];
                    
                    if(AssetList.size() == 0) {
                        ResultResponse.AlreadyExist = false;
                    } else {
                        ResultResponse.AlreadyExist = true;
                        IsAlreadyExist = true;
                    }
                    ResultResponseList.add(ResultResponse);
                }
            	Response.Assets = ResultResponseList;
                if(IsAlreadyExist == true) {
                    Response.ItemsAlreayExist = true;
                } else {
                    Response.ItemsAlreayExist = false;
                }
            	Response.Success = true;
            	return Response;
        } catch (Exception e) {              
         		MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_ProductRegistrationController', 'checkAssets');
            	Response.Error = e;
            	Response.Message = 'Error occured';
            	Response.Success = false;
            	return Response;
        }        
    }
    // Asset creation method response
    public class AssetInput {        
         @AuraEnabled public String ModelNumber { get; set; }  
       	 @AuraEnabled public String SerialNumber { get; set; }
    }
    // Asset creation method response
    public class AssetResultResponse {        
        @AuraEnabled public String ModelNumber;  
       	@AuraEnabled public String SerialNumber;
        @AuraEnabled public Boolean AlreadyExist;
    }
    // Asset creation method response
    public class CheckAssetExistingResponse {        
        @AuraEnabled public Object Error;
        @AuraEnabled public String Message;       
        @AuraEnabled public List<AssetResultResponse> Assets;
        @AuraEnabled public Boolean ItemsAlreayExist;
        @AuraEnabled public Boolean Success;
    }
}
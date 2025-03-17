//******************************************************************************************
//Name : MYA_generateEmailPayloadForSFMC 
//Requirement : To generate Email Payload for Product registration
//EPIC/US/TASK : IDMSF-1173
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
//@description : Class to handle request for Payload for Email.
public without sharing class MYA_generateEmailPayloadForSFMC 
{
    //@description : Asset creation method response
    public class PublishEmailResponse {
        @AuraEnabled public Object Payload;
        @AuraEnabled public Object Error;
        @AuraEnabled public Boolean Success;
    }
    
    //@description : Publish Email Response
    @AuraEnabled(cacheable=false)
    Public Static PublishEmailResponse MYA_Utility_publishEmailPayloadForSFMC(List<String> AssetIDS, String assurantURL)
    {
        PublishEmailResponse ResponseObj = new PublishEmailResponse();
        try {
            Prd_Reg_Event__e ProductRegisterPayload = MYA_Utility_generateEmailPayloadForSFMC(AssetIDS,assurantURL);
        	Database.SaveResult sr = EventBus.publish(ProductRegisterPayload);
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
                ResponseObj.Payload = ProductRegisterPayload;
                ResponseObj.Success = true;
                return ResponseObj;
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
                ResponseObj.Error = sr.getErrors();
                ResponseObj.Success = false;
                return ResponseObj;
            }
        } catch (Exception e) {
            	ResponseObj.Error = e;
                ResponseObj.Success = false;
                return ResponseObj;
        }         
    }
    
    //@description : Poduct registration event with email Payload
	@AuraEnabled(cacheable=false)
    Public Static Prd_Reg_Event__e MYA_Utility_generateEmailPayloadForSFMC(List<String> AssetIDS,String assurantURL)
    {
        List<String> AssetId = AssetIDS;
        Prd_Reg_Event__e PrdRegPayload = new Prd_Reg_Event__e();
        
        List<Asset> Product = [SELECT OwnershipStartedOn__c, OriginalEngineeringModelNumber__c, ModelValidityFlag__c, Model_Number__c, SerialNumber, DataSourceCode__c, OriginalModelNumber__c
                                      FROM Asset
                                      WHERE id IN: AssetId];
        List<Asset> ContInfo = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.Email,
                                       Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode 
                                       FROM Asset 
                                       WHERE id IN: AssetId 
                                       LIMIT 1];
        
        
        System.JSONGenerator JS = JSON.createGenerator(false);
        JS.writeStartObject();
            JS.writeFieldName('transaction_data');
            JS.writeStartObject();
        	For(Asset EC: ContInfo)
            {
                if(EC.Contact.FirstName!=null) {JS.writeStringField('ConsumerFirstName', EC.Contact.FirstName);}
                else {JS.writeStringField('ConsumerFirstName', '');}
                if(EC.Contact.LastName!=null) {JS.writeStringField('ConsumerLastName', EC.Contact.LastName);}
                else {JS.writeStringField('ConsumerLastName', '');}
                if(EC.Account.BillingStreet!=null) {JS.writeStringField('ConsumerAddress1', EC.Account.BillingStreet);}
                else {JS.writeStringField('ConsumerAddress1', '');}
                
                JS.writeStringField('ConsumerAddress2', '');
                if(EC.Contact.Phone!=null) {JS.writeStringField('ConsumerPhone', EC.Contact.Phone);}
                else {JS.writeStringField('ConsumerPhone', '');}
                if(EC.Account.BillingCity!=null) {JS.writeStringField('City', EC.Account.BillingCity);}
                else {JS.writeStringField('City', '');}
                if(EC.Account.BillingState!=null) {JS.writeStringField('State', EC.Account.BillingState);}
                else {JS.writeStringField('State', '');}
                if(EC.Account.BillingPostalCode!=null) {JS.writeStringField('ZipCode', EC.Account.BillingPostalCode);}
                else {JS.writeStringField('ZipCode', '');}
                if(assurantURL!='') {JS.writeStringField('AssurantURL', assurantURL);}
                else {JS.writeStringField('AssurantURL', '');}
                JS.writeFieldName('product');
                    JS.writeStartArray();
                    For(Asset EP: Product)
                    {
                        JS.writeStartObject();
                        if(EP.OwnershipStartedOn__c!=null) {JS.writeStringField('ApplianceInstallDate', formatDate(EP.OwnershipStartedOn__c));}
                        else {JS.writeStringField('ApplianceInstallDate', '');}
                        if(EP.OriginalEngineeringModelNumber__c!=null) {JS.writeStringField('ManufacturingModel', EP.OriginalEngineeringModelNumber__c);}
                        else {JS.writeStringField('ManufacturingModel', '');}
                        JS.writeStringField('ModelValidityFlag', EP.ModelValidityFlag__c ? 'TRUE' : 'FALSE');
                        if(EP.Model_Number__c!=null) {JS.writeStringField('MarketingModel', EP.Model_Number__c);}
                        else {JS.writeStringField('MarketingModel', '');}
                        if(EP.SerialNumber!=null) {JS.writeStringField('ApplianceSerial', EP.SerialNumber);}
                        else {JS.writeStringField('ApplianceSerial', '');}
                        if(EP.DataSourceCode__c!=null) {JS.writeStringField('SourceCode', EP.DataSourceCode__c);}
                        else {JS.writeStringField('SourceCode', '');}
                        if(EP.OriginalModelNumber__c!=null) {JS.writeStringField('InputModel', EP.OriginalModelNumber__c);}
                        else {JS.writeStringField('InputModel', '');}
                        JS.writeEndObject();
                    }
                    JS.writeEndArray();
                JS.writeEndObject();
                        
                JS.writeFieldName('send_single_options');
                JS.writeStartObject();
                JS.writeStringField('suppression_info', 'false');
                JS.writeEndObject();
            
                JS.writeFieldName('send_single_contact');
                JS.writeStartObject();
                if(EC.Contact.Email!=null){JS.writeStringField('email', EC.Contact.Email);}
                else {JS.writeStringField('email', '');}
                JS.writeEndObject();
            
                JS.writeEndObject();
                
                PrdRegPayload.Payload__c = JS.getAsString();
                
                PrdRegPayload.Email__c = EC.Contact.Email;
                PrdRegPayload.SessionID__c = EC.Id;
                
            }
        return PrdRegPayload;
    }
    
    //@description : Date Conversion to required format
    Public static string formatDate(Date d)
    {
        return d.year() + '/' + d.month() + '/' + d.day();
    }
    
    //@description : Publish Email Response
    @AuraEnabled(cacheable=false)
    Public Static PublishEmailResponse MYA_Utility_publishGuestEmailPayloadForSFMC(EmailPayloadInput input)
    {
        PublishEmailResponse ResponseObj = new PublishEmailResponse();
        try {
            Prd_Reg_Event__e ProductRegisterPayload = input.Payload;
        	Database.SaveResult sr = EventBus.publish(ProductRegisterPayload);
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
                ResponseObj.Payload = ProductRegisterPayload;
                ResponseObj.Success = true;
                return ResponseObj;
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
                ResponseObj.Error = sr.getErrors();
                ResponseObj.Success = false;
                return ResponseObj;
            }
        } catch (Exception e) {
            	ResponseObj.Error = e;
                ResponseObj.Success = false;
                return ResponseObj;
        }         
    }
    
    // Asset creation method response
    public class EmailPayloadInput {        
      	@AuraEnabled public Prd_Reg_Event__e Payload { get; set; }
    }
}
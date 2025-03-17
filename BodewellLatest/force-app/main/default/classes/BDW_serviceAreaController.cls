//******************************************************************************************
//Name : BDW_serviceAreaController
//Requirement : To display Service Areas and Retails areas from Custom Metadata
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			11/21/2022			Initial
//******************************************************************************************
//@description : To display Service Areas and Retails areas from Custom Metadata
public without sharing class BDW_serviceAreaController 
{
	//@description : Method is used for fetching Service Area Data
	@AuraEnabled(Cacheable=true)
    Public static List<bw_ServiceLocation__mdt> getServiceArea()
    {
        return [SELECT Id, Service_Area_Name__c, Service_Area_Number__c FROM bw_ServiceLocation__mdt];
    }
    
    //@description : Method is used for fetching Retail Area Data
    @AuraEnabled(Cacheable=true)
    Public static List<bw_RetailLocation__mdt> getRetailArea()
    {
        return [SELECT Id, Retail_Area_Name__c, Retail_Area_Number__c, Retail_Area_AddresLine1__c, Retail_Area_AddresLine2__c, 
                Retail_Area_City__c, Retail_Area_State__c, Retail_Area_ZipCode__c 
                FROM bw_RetailLocation__mdt];
    }
}
//******************************************************************************************
//Name : Mya_OrderHelper
//Requirement : To display Orders Data on My Orders and Order Details Page
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
//@description : Class to handle request for Orders Data, Contact Data and Custom Metadata.
public without sharing class Mya_OrderHelper 
{
    //@description Method is used for retrieving Contacts Data
    //Input: String UserId
    //Return: List<Contact>
    @AuraEnabled (Cacheable=true)
    public static List<Contact> getContact(string UserId)
    {
        return [SELECT Id, Global_Customer_Id__c, Email 
        FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id=:UserId)
        LIMIT 1];
    }

    //@description Method is used for retrieving Custom Metadata for Parts URL
    //Return: SmartOrder_URL__mdt Data
    @AuraEnabled (Cacheable=false)
    public static MYA_Configuration__mdt getURL()
    {
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);  
        Return details;
    }

    @AuraEnabled (Cacheable=true)
    public static User getUser(String ContId)
    {
        return [SELECT Id 
        FROM User 
        WHERE ContactId=:ContId
        LIMIT 1];
    }
}
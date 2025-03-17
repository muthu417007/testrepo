/*********************************************
**********************************************
Name: Navya N N
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
EPIC: IDMSF-1043
EPIC: IDMSF-32
**********************************************
Purpose: get details of all registered
products
**********************************************
History
---------------------------------------------
Version     Author          Date        Details
-------     -------         -------     -------
1.0         Navya N N       07/07/2022  Created
2.0         Akefa Taranum
3.0         Yogesh Sharma   26/09/2023  Modified (CCOE-1213)
**********************************************
**********************************************/
public with sharing class Mya_ProductDetails{    
    
    // To get mya configutations for product
    @AuraEnabled(cacheable=true)
    public static MYA_Configuration__mdt getmyaConfigs()
    {
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt myaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            return myaConfig;
    }
    
    //get first name of user
    @AuraEnabled(cacheable=true)
    public static list<User> MYA_GetContactName(String UserId)
    {
       
            string user1 = UserId;
            return [select id,contactId,contact.FirstName, contact.Global_Customer_Id__c,Account.Bodewell_Member__c,Account.Bodewell_Member_Start_Date__c from User where Id=:user1 LIMIT 1];
        
    }
    
    //get address of user
    @AuraEnabled(cacheable=true)
    public static list<User> MYA_GetAccountProduct(String UserId)
    {

            string user1 = UserId;
            return [select id,contactId,contact.FirstName from User where Id=:user1 LIMIT 1];
        
        
    }
    
    //get manufacturing model number
    @AuraEnabled(cacheable=true)
    //Changes are part of CCOE-1213-(Product2 replaced by Model_Rel__c Object)-Yogesh Sharma/TCS/26.09.2022
    //public static Model_Rel__c Mya_GetManufactureModel(String ModelNo)
    public static Product2 Mya_GetManufactureModel(String ModelNo)
    {       
        //Changes are part of CCOE-1213-(Product2 replaced by Model_Rel__c Object)-Yogesh Sharma/TCS/26.09.2022
        /*list<Model_Rel__c> Details=[SELECT Id,MN__c FROM Model_Rel__c WHERE MR_PKMOD__c=:ModelNo LIMIT 1];
        Model_Rel__c Detail;
        if(Details.Size()>0)
        {
            Detail=Details[0];
        }
        return Detail;*/
        List<Product2> details = MYA_FetchProduct2Records.getProduct2ByMarketingModelNo(ModelNo);
        Product2 detail =  new Product2();
        if(details.Size()>0)
        {
            detail = details[0];
        }
        return detail;
    }

    
  /*    @AuraEnabled(cacheable=true)
    public static Boolean isGeaProduct(String assetId )
    {       
            Asset isGEA =[select id,Product2.Is_GEA_Product__c from Asset WHERE id=:assetId limit 1];
        system.debug('isGEA'+isGEA.Product2.Is_GEA_Product__c);
            if(isGEA.Product2.Is_GEA_Product__c == 'Yes'){
                return true;
            }
        else {
            return false;
        }
        
                
    } */

    //delete asset
    @AuraEnabled(cacheable=false)
    public static void Mya_DeleteAsset(string Id)
    {
       try
       {
            list<Asset> asset=[SELECT  Id,Date_Time_of_deletion__c,Deleted__c FROM Asset WHERE Id=:Id];
            for(Asset prod:asset)
            {
                prod.Deleted__c=true;
                prod.Date_Time_of_deletion__c=system.now();
                update prod;
            }
       }
       catch (Exception e) {
        MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_ProductDetails', 'Mya_DeleteAsset');
       }    
    }

}
/**
*@description : Test class for MYA_MetaDataConfigHelper.
Name: Baishali Das
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
EPIC: Overall project
**********************************************
Purpose: Test class for MYA_MetaDataConfigHelper.
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Baishali Das 21/07/2022   Created
**********************************************
**********************************************/
@isTest(seeAllData = true)
public class MYA_MetaDataConfigHelper_Test{

@isTest
    static void mya_Config_one_test()
    { 
     MYA_Configuration__mdt con = new MYA_Configuration__mdt();
     
    MYA_Configuration__mdt c= [Select Id,Domain__c,Environment_Name__c from MYA_Configuration__mdt LIMIT 1];
    
    String domain = Url.getOrgDomainUrl().getHost();

    MYA_MetaDataConfigHelper.getmyaConfigByDomain(domain);
    }
@isTest
    static void mya_Config_two_test()
    { 
     MYA_Configuration__mdt con_one = new MYA_Configuration__mdt();
     String domain = 'geapp--mya.my.salesforce.com';
     String envName= 'MYA';
     MYA_Configuration__mdt c= [Select Id,Domain__c,Environment_Name__c from MYA_Configuration__mdt where Domain__c=:domain
                AND Environment_Name__c = :envName
                LIMIT 1];
    MYA_MetaDataConfigHelper.getmyaConfigByDomain(domain);
    System.assert(c!=null); 
    
    }
@isTest
    static void getSourceDocumentTypes_test()
    { 
        List<Source_Document_Type__mdt> c= [SELECT Id, Brand__c, Appliance_Registration_Card__c, Mobile_Apps__c, Outer_Appliance_Carton_Label__c,Rating_Plate__c
                 FROM Source_Document_Type__mdt];
     	List<Source_Document_Type__mdt> con_one = MYA_MetaDataConfigHelper.getSourceDocumentTypes();
        System.assert(c==con_one); 
    }
    
    @isTest
    static void getStaticOwnerLinks_test()
    { 
        List<MYA_Owner_Link__mdt> c = 
                [SELECT Id, Category__c, Haier_Link__c, Hotpoint_Link__c, Monogram_Link__c
                 FROM MYA_Owner_Link__mdt];
     	List<MYA_Owner_Link__mdt> con_one = MYA_MetaDataConfigHelper.getStaticOwnerLinks();  
        System.assert(c==con_one); 
    }
    
    @isTest
    static void mya_prod_reg_review_link_test()
    { 
    	Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
     	List<MYA_ProdReg_ReviewLink__mdt> c = 
                [SELECT Id,Brand__c,CampaignId_Parameter__c,Review_Link__c,IsSandbox__c
                FROM MYA_ProdReg_ReviewLink__mdt
                WHERE IsSandbox__c = :isSandbox];
     	List<MYA_ProdReg_ReviewLink__mdt> con_one = MYA_MetaDataConfigHelper.getProdRegReviewLinks();  
        System.assert(c==con_one); 
    
    }
    
    @isTest
    static void getProdSpecLinks_test()
    { 
        List<MYA_Product_Spec_URL__mdt> c = 
                [SELECT Id, Brand__c, Ductless_Spec_Link__c, IsQRPage__c, Spec_Link__c
                 FROM MYA_Product_Spec_URL__mdt];
     	List<MYA_Product_Spec_URL__mdt> con_one = MYA_MetaDataConfigHelper.getProductSpecLinks();  
        System.assert(c==con_one); 
    }
}
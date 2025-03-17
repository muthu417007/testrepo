/**
*@description : Class has been created to query consolidated metadata component created for MYA project.
Name: Baishali Das
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
EPIC: Overall project
**********************************************
Purpose: Class has been created to query consolidated metadata component created for MYA project.
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Baishali Das 21/07/2022   Created
2.0      Akhil Raj 20/10/2022   Updated
**********************************************
**********************************************/
public without sharing class MYA_MetaDataConfigHelper {

   @TestVisible
    private static MYA_Configuration__mdt myaConfig;
    
    @TestVisible
    private static List<MYA_ProdReg_ReviewLink__mdt> regReviewLinks;
   
    @AuraEnabled(cacheable=true) 
    public static MYA_Configuration__mdt getmyaConfigByDomain(
            String domain
    ) {
        if (Test.isRunningTest() && myaConfig != null) {
            return myaConfig;
        }

        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                Url.getOrgDomainUrl().getHost().split('--').get(1).split('\\.').get(0) :
                null;
        List<Organization> s = [SELECT IsSandbox FROM Organization LIMIT 1];
        System.debug(LoggingLevel.WARN,s);
        System.debug(LoggingLevel.WARN,envName);

        List<MYA_Configuration__mdt> dataConfig = [
                SELECT Id,Domain__c,Environment_Name__c,Mellisa_Client_Id__c,Mellisa_Client_Secret__c,
                        Mellisa_EndPoint_URL__c,Brand__c,Brands__c,CampaignId_Parameter__c,PartsSiteBaseUrl__c,
                        DeliveryInfoURL__c,Endpoint__c,Method_Type__c,MyAccountLoginCafeURL__c,
                        MyAccountLoginGeaURL__c,MyAccountLoginHaierURL__c,Name__c,PartsStoreURL__c,Privacy_Policy_Url__c,
                        Redirection_Links__c,RescheduleURL__c,ReturnBaseURL__c,Review_Link__c,Source_URL__c,Token_Audience__c,
                        Token_Client_Id__c,Token_Client_Secret__c,Token_EndPoint_URL__c,Token_Grant_Type__c,TrackMyOrderURL__c,
                        Image_Url__c,Review_Link_GEA__c,Review_Link_Haier__c,Review_Link_Cafe__c,Review_Url_Hotpoint__c,Review_Link_Monogram__c,
                        Product_Specs_Cafe__c,Product_Specs_GEA__c,Product_Specs_Haier__c,Product_Specs_Monogram__c,Product_Specs_Hotpoint__c,
                        PartsOrderStatus__c,Agent_Token_Grant_Type__c,Agent_Token_EndPoint_URL__c,Agent_Token_Client_Secret__c,
                        Agent_Token_Client_Id__c,Agent_Token_Audience__c,Agent_EndPoint_URL__c,Agent_Client_Secret__c,Agent_Client_Id__c,Order_Token_Grant_Type__c,
                        Order_Token_EndPoint_URL__c,Order_Token_Client_Secret__c,Order_Token_Client_Id__c,Order_Token_Audience__c,Order_EndPoint_URL__c,
                        Order_Client_Secret__c,Order_Client_Id__c,smartURL__c,partsURL__c,partsURLParams__c,stateURL__c,Owner_Support_GEA__c,
                        AFX_Search_API_Endpoint__c, AFX_Search_API_AuthToken__c, AFX_Search_API_MethodType__c,
                        Payment_Method_Endpoint__c, Payment_Method_Type__c,Payment_Method_Edit_Payment_URL__c,
                        Payment_Method_Client_Id__c, Payment_Method_Client_Secret__c, Payment_Method_Request_Type__c,
                        Prod_Reg_CampaignId_Parameter_Cafe__c,
                        Prod_Reg_CampaignId_Parameter_GEA__c,
                        Prod_Reg_CampaignId_Parameter_Haier__c,
                        Assurant_Service_Endpoint__c, Assurant_Service_Endpoint_Endparameters__c,
            			E_service_product_selection_url__c, Marketing_Object_Retrieval_Path__c, Parts_And_Accessories_Path__c, 
                        Endeca_API_Client_Id__c, Endeca_API_Client_Secret__c, Endeca_API_Endpoint__c,
                        Endeca_API_Type__c,EService_Source_URL__c,EService_Target_Url__c,
                        Appliance_review_link_GEA__c,Appliance_review_link_cafe__c,Appliance_review_link_Haier__c,
                        Appliance_Campaign_Parameter_Cafe__c,Appliance_Campaign_Parameter_GEA__c,Appliance_Campaign_Parameter_Haier__c,
                        QR_Review_link_Cafe__c,QR_Review_Link_for_Haier__c,QR_Review_link_GEA__c,QR_Review_link_Hotpoint__c,QR_Review_link_Monogram__c
                FROM MYA_Configuration__mdt
                WHERE Domain__c = :domain
                AND Environment_Name__c = :envName
                LIMIT 1
        ];

        if (dataConfig.isEmpty()) {
            return null;
        }
        return dataConfig.get(0);
    }

    //Get SourceDocumentType metadata
    @AuraEnabled( cacheable=false )  
    public static List<Source_Document_Type__mdt> getSourceDocumentTypes(){
     	List<Source_Document_Type__mdt> sourceDocumentTypes = 
                [SELECT Id, Brand__c, Appliance_Registration_Card__c, Mobile_Apps__c, Outer_Appliance_Carton_Label__c,Rating_Plate__c
                FROM Source_Document_Type__mdt];
   		return sourceDocumentTypes;
    }
    
    // Get StaticOwnerLinks metadata
    @AuraEnabled( cacheable=false )  
    public static List<MYA_Owner_Link__mdt> getStaticOwnerLinks(){        
     	List<MYA_Owner_Link__mdt> ownerLinks = 
                [SELECT Id, Category__c, Haier_Link__c, Hotpoint_Link__c, Monogram_Link__c
                FROM MYA_Owner_Link__mdt];
     	return ownerLinks;        
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<MYA_ProdReg_ReviewLink__mdt> getProdRegReviewLinks() {
        if (Test.isRunningTest() && regReviewLinks != null) {
            return regReviewLinks;
        }        
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        System.debug(LoggingLevel.WARN,isSandbox);
        List<MYA_ProdReg_ReviewLink__mdt> reviewLinks = [
                SELECT Id,Brand__c,CampaignId_Parameter__c,Review_Link__c,IsSandbox__c
                FROM MYA_ProdReg_ReviewLink__mdt
                WHERE IsSandbox__c = :isSandbox
        ];
        if (reviewLinks.isEmpty()) {
            return null;
        }        
        return reviewLinks;
    }
    
    // Get StaticOwnerLinks metadata
    @AuraEnabled( cacheable=false )  
    public static List<MYA_Product_Spec_URL__mdt> getProductSpecLinks(){            
     	List<MYA_Product_Spec_URL__mdt> specLinks = 
                [SELECT Id, Brand__c, Ductless_Spec_Link__c, IsQRPage__c, Spec_Link__c
                FROM MYA_Product_Spec_URL__mdt];        
     	return specLinks;        
    }
}
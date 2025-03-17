/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        06.04.2023
 * @description    For getting media page info
 */
public without sharing class RG_MediaController {
	@AuraEnabled(cacheable=true)
    public static RG_MediaControllerResponse getMediaServiceCity(String service, String city){
        RG_MediaControllerResponse response = new RG_MediaControllerResponse();
        if(service != Null) {
            response.mediaService = [SELECT Id, Label, Brand__c, CertifiedServiceHeader__c, Description_Tag__c, Image__c,Main_Header__c,Phone__c,Service_Name__c,Sub_Header__c,Title_Tag__c,URL_Trigger__c
                            FROM RG_Repair__mdt WHERE URL_Trigger__c =:service LIMIT 1];
        }
        if(service != Null && city != Null) {
            Boolean isDeleted = false;
        	response.mediaCity = [SELECT Id, Name, City_Flag__c, City_Phone__c, Is_Duplicated__c, Name__c, Phone__c, URL_Trigger__c
                         FROM RG_MediaCity__c WHERE URL_Trigger__c =:service AND Name__c=:city AND Is_Deleted__c=:isDeleted AND Is_Duplicated__c='Null' LIMIT 1];
        }  
        response.success = true;        
        return response;  
    }
}
/**
*@description : Class has been created to access CMS data from Salesforce workspace created for Bodewell project.
Name: Akhil MR
Copyright: © 2021 GE Appliances
**********************************************

History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Akhil MR   10/13/2022   Created
**********************************************
**********************************************/
public without sharing class BDW_CMSController {
    
    	@AuraEnabled(cacheable=true)
      	public static Map<String, ConnectApi.ManagedContentNodeValue> getContent(
            String contentId, 
            Integer page, 
            Integer pageSize, 
            String language, 
            String filterby
        ){
            try{
                String networkId = Network.getNetworkId();
                ConnectApi.ManagedContentVersionCollection contentCollection = ConnectApi.ManagedContent.getManagedContentByContentKeys(
                    networkId,
                    new List<String> { contentId },
                    0,
                    1,
                    language,
                    filterby,
                    false
                );                
            	return contentCollection.items[0].contentNodes;
            } catch(ConnectApi.ConnectApiException e){
                System.debug(LoggingLevel.WARN,'Error Message: ' + e);
                Map<String, ConnectApi.ManagedContentNodeValue> mcnvMap = new Map<String, ConnectApi.ManagedContentNodeValue>();
                return mcnvMap;
            }
        }
    
    @AuraEnabled(cacheable=true)
      	public static List<ConnectApi.ManagedContentVersion> getContentList(
            Integer page, 
            Integer pageSize, 
            String language, 
            String filterby
        ){
            try{
                String networkId = Network.getNetworkId();
                ConnectApi.ManagedContentVersionCollection contentCollection = ConnectApi.ManagedContent.getAllManagedContent(
                    networkId,
                    page,
                    pageSize,
                    language,
                    filterby
                );                
            	return contentCollection.items;
            } catch(ConnectApi.ConnectApiException e){
                System.debug(LoggingLevel.WARN,'Error Message: ' + e);
                List<ConnectApi.ManagedContentVersion> mcnvMap = new List<ConnectApi.ManagedContentVersion>();
                return mcnvMap;
            }
        }
    
    /**@AuraEnabled(cacheable=false)
      	public static ConnectApi.ManagedContentVersionCollection getManagedContentByContentKeys(String communityId, String[] managedContentIds, Integer pageParam, Integer pageSize, String language, String managedContentType, Boolean showAbsoluteUrl){
            try{
            	return ConnectApi.ManagedContent.getManagedContentByContentKeys(communityId, managedContentIds, pageParam, pageSize, language, managedContentType, showAbsoluteUrl);
            } catch(Exception e){
                throw e;
            }
        }*/

}
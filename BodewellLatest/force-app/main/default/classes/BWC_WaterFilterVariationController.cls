/**
* @author Shubhada 
* @date 08/08/2023
* @description Controller used to return prodect details for water filter variation
*/
public without sharing class BWC_WaterFilterVariationController {
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductOverviewCollection getProductDetails(String modelSku,string accId,string communityId) {
          try{
        String Id=[Select Id, StockKeepingUnit from Product2 where StockKeepingUnit=:modelSku].Id;
        List<string> skus=new List<String>();
        skus.add(modelSku);
        
        String webStoreId=BWC_utils.resolveCommunityIdToWebstoreId(communityId);
        
        return  ConnectApi.CommerceCatalog.getProducts(webStoreId, accId,null, skus, null, false, false);
          }
        catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(String communityId, String productId, string accId)
    {
        try{
      String webStoreId=BWC_utils.resolveCommunityIdToWebstoreId(communityId);
        
        return ConnectApi.CommerceStorePricing.getProductPrice(webStoreId,productId,accId);
             }
        catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    }
    
    //This method is used to get account id for current user
    @AuraEnabled(cacheable=true)
    public static String getAccount(String userId)
    {
    	try{
            User u=[SELECT Id, Name, ContactId from User WHERE id=:userId];
            system.debug('usr====='+u);
            Contact con=[SELECT Id, AccountId from Contact WHERE Id=:u.ContactId WITH SECURITY_ENFORCED];            
            return con.AccountId;
        } catch(Exception e){
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
    }
}
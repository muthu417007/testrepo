/**
 * @author         Sukumar Venkatesan
 * @company        GEA
 * @created        06.Nov.2022
 * @description    Trigger Handler Class for Asset Object
 */
public class AssetTriggerHandler implements PS_ITriggerHandler{
    
    Boolean isDataMigrationUser = FeatureManagement.checkPermission('DataMigrationUser'); //check if data migration user needs to be bypassed for the triggerexecution
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled() {
		if(bypassTrigger__mdt.getInstance('AssetTriggerHandler').bypassCriteria__c){// check to bypassTrigger through custom metadata
            TriggerDisabled=true;
        }
        if(isDataMigrationUser){
            TriggerDisabled=true;
        }
        return TriggerDisabled;
    }
  	public void beforeInsert(List<SObject> newItems){
		List<Asset> newAssets = (List<Asset>) newItems;
        //List<Asset> assetsToProcess = (List<Asset>) newItems;
        List<Asset> assetsToProcess = new List<Asset> ();
        for(Asset a: newAssets){
            if(a.OriginalModelNumber__c != Null){
                assetsToProcess.add(a);
            }    
            if(a.Ductless_product_registration__c == null || test.isRunningTest()){
               a.Name = (a.Model_Number__c != null) ? a.Model_Number__c + '-'+ a.SerialNumber : a.OriginalModelNumber__c   + '-'+   a.SerialNumber;
            }
            
        }
        if(assetsToProcess.size() >0){
            AssetTriggerBeforeInsertService.invokeReferenceObject(assetsToProcess); //this method used to populate modal vality flag and Marketing modal numbers from SMC and PROD Rel tables
        }
        //Call SiebelXML to Validate ModelNumber
        if(!bypassTrigger__mdt.getInstance('AssetUtilityvalidateModelNumber').bypassCriteria__c){
       	 AssetUtility.validateModelNumber(newAssets);
        }
        
    }
    public void afterInsert(List<SObject> newItems) {
        system.debug('Asset After insert');
        List<Asset> newAssets = (List<Asset>) newItems;
        AssetTriggerAfterInsertService.populateHerokuExtId(newAssets);
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    	system.debug('Asset After insert');
        Map<Id,Asset> newAssetsMap = (Map<Id,Asset>) newItems;
        //AssetTriggerAfterUpdateService.populateHerokuExtId(newAssetsMap);    //Calling this class to update HerokuExtId
        
        if(system.isFuture()) return;
    	String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
    	List<Asset> geaAssetList = new List<Asset>();
       
        if(profileName == 'DFS Tech Support'|| test.isRunningTest()){
            for(Asset objGEAAsset : newAssetsMap.values()){
                geaAssetList.add(objGEAAsset);                             
            }
            
            if(geaAssetList!=null && !geaAssetList.isEmpty())
                GEAAssetTriggerHandler.getGEAAssetInfo(geaAssetList);
        }
    }
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    public void afterDelete(Map<Id, SObject> oldItems) {}
}
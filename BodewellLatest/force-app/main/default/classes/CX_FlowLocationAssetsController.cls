/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        04.07.2021(dd.mm.yyyy) 
 * @description    Controller Class for cx_flowLocationAssets LWC component
 * @testClass      TODO
 */
public with sharing class CX_FlowLocationAssetsController { 
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        04.07.2021 (dd.mm.yyyy)
     * @description    gets the assets of a case default location
     * @param          String - caseId that user populated
     * @return         List<GEA_Asset__c> - returns Locations Assets that are not related to Case Assets
     */
    @AuraEnabled
    public static CX_FlowLocationAssetsWrapper selectLocationAssets(String caseId){
        CX_FlowLocationAssetsWrapper wrap = new CX_FlowLocationAssetsWrapper();
        List<Asset> returnList = new List<Asset>();
            
        try {
            List<Case_Asset__c> caseAssetList = CX_AssetDAO.getInstance().getCaseAssetByCaseId(caseId);
            Case currentCase = CX_CaseDAO.getInstance().getCase(Id.valueOf(caseId));
            Id locationId = currentCase.AccountId;    
            
            if(locationId == null){
                wrap.locationAssets = returnList;
                wrap.messageIndicator = 'NO_LOCATION_ID';
                return wrap;
            }

            Set<Id> caseAssetIds =  new Set<Id>();
            CX_CollectionUtils.loadSet(caseAssetIds, 'Asset__c', caseAssetList);
            
            returnList = CX_AssetDAO.getInstance().getAssetsByLocationId(new Set<Id>{locationId},caseAssetIds);    
            wrap.messageIndicator = 'OK';
            wrap.locationAssets = returnList;
        
        } catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while selecting the location assets!');
        }
        return wrap;
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        04.07.2021 (dd.mm.yyyy)
     * @description    gets the assets of a case default location
     * @param          String - assetId GEA_ASSET_ID that needed to create a Case Asset
     * @param          String - caseId transactionCaseId
     * @return         List<GEA_Asset__c> - returns Locations Assets that are not related to Case Assets
     */
    @AuraEnabled
    public static List<Asset> addCaseAsset(String assetId,String caseId){
        List<Asset> returnList = new List<Asset>();
        try {
            Case currentCase = CX_CaseDAO.getInstance().getCase(caseId);
            Id locationId = currentCase.AccountId;    
            Asset transactionGEAAsset = CX_AssetDAO.getInstance().getAssetById(new Set<String>{assetId})[0];
            Case_Asset__c transactionCaseAsset =  new Case_Asset__c(
                Case__c = caseId,
                Model_Number__c = transactionGEAAsset.Model_Number__c,
                Install_Date__c = transactionGEAAsset.InstallDate,
                Serial_Number__c = transactionGEAAsset.SerialNumber,
                Asset__c = Id.valueof(assetId)
            );
            insert transactionCaseAsset;

            List<Case_Asset__c> caseAssetList = CX_AssetDAO.getInstance().getCaseAssetByCaseId(caseId);    
            Set<Id> caseAssetIds =  new Set<Id>();
            CX_CollectionUtils.loadSet(caseAssetIds, 'Asset__c', caseAssetList);
            returnList = CX_AssetDAO.getInstance().getAssetsByLocationId(new Set<Id>{Id.valueOf(locationId)},caseAssetIds);
        } catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while adding the case asset!');
        }
        return returnList;
    }
}
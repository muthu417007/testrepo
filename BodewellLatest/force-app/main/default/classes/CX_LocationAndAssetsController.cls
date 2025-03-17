/**
 * @author         Gabriel Alves
 * @company        PolSource
 * @created        11.06.2021
 * @description    Class for handling the data fetching of cx_locationAndAssets lwc
 * @testClass      CX_LocationAndAssetsControllerTest
 */
public with sharing class CX_LocationAndAssetsController {

    @AuraEnabled(cacheable=true)
    public static List<Account> getLocations (Id contactId) {
        try {
            return CX_AccountDAO.getInstance().getLocationsByContactId(Id.valueOf(contactId));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssets (Id contactId) {
        try {
            Set<Asset> assets = new Set<Asset>();
            CX_AssetDAO assetDao = CX_AssetDAO.getInstance();
            assets.addAll(assetDao.getAssetsByOwnerContact(Id.valueOf(contactId)));
            assets.addAll(assetDao.getAssetsByContactLocations(contactId));
            return new List<Asset>(assets);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        07.06.2021
 * @description    Class used to keep Asset queries
 */
public inherited sharing class CX_AssetDAO {
    private static final CX_AssetDAO INSTANCE = new CX_AssetDAO();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Returns the singleton instance
     * @return         CX_AssetDAO - a CX_AssetDAO singleton instance
     */
	public static CX_AssetDAO getInstance() {
		return INSTANCE;
	}

    private CX_AssetDAO() { }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        05.07.2021
     * @description    Returns a list of Assets using the ID
     * @param          Set<String> -  ids
     * @return         List<Asset> - A list of GEA Assets
     */
    public List<Asset> getAssetById(Set<String> ids) {
        return [
            SELECT 
                ID,
                AssetID__c,
                Model_Number__c,
                SerialNumber,
                InstallDate,
                BrandName__c 
            FROM 
                Asset 
            WHERE 
                Id in :ids
        ];
    }
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Returns a list of Assets using the AssetID__c
     * @param          Set<String> - asset ids
     * @return         List<Asset> - A list of GEA Assets
     */
    public List<Asset> getAssetByAssetId(Set<String> assetIds) {
        return [
            SELECT 
                ID,
                AssetID__c 
            FROM 
                Asset 
            WHERE 
                AssetID__c in :assetIDs
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        16.06.2021
     * @description    Returns a list of Assets using the Case id
     * @param          Id - case id
     * @return         List<Case_Asset__c> - A list of Case Assets
     */
    public List<Case_Asset__c> getCaseAssetByCaseId(Id caseId) {
        return [
            SELECT 
                Id,
                Asset__c,
                Asset__r.name,
                Asset__r.Model_Number__c,
                Asset__r.SerialNumber,
                Asset__r.Product_Type__c,                                            
                Asset__r.Product_Line__c,
                Asset__r.AccountId,
                Asset__r.BrandName__c,
                Asset__r.InstallDate
            FROM 
                Case_Asset__c     
            WHERE
                Case__c = :caseId
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        16.06.2021
     * @description    Returns a list of Assets using the Case id
     * @param          Set<Id> - location ids
     * @param          Set<Id> - case asset ids
     * @return         List<Asset> - A list of Assets
     */
    public List<Asset> getAssetsByLocationId(Set<Id> locationIds, Set<Id> caseAssetIds) {
        return [
            SELECT 
                Id, 
                Name,
                Model_Number__c,
                SerialNumber,
                Product_Type__c,
                Product_Line__c,
                AccountId,
                BrandName__c,
                InstallDate
            FROM 
                Asset 
            WHERE 
                AccountId IN :locationIds 
                AND ID NOT IN :caseAssetIds 
        ];
    }

    /**
     * @author         Gabriel Alves
     * @company        PolSource
     * @created        28.06.2021
     * @description    Returns a list of Assets related to the Contact Id provided
     * @param          Id - contact id
     * @return         List<Asset> - A list of Assets
     */
    public List<Asset> getAssetsByOwnerContact (Id contactId) {
        return
            [SELECT Id, 
                    Model_Number__c, 
                    SerialNumber, 
                    InstallDate, 
                    BrandName__c, 
                    Product_Type__c, 
                    Product_Line__c, 
                    AccountId 
               FROM Asset 
              WHERE ContactId = :contactId];
    }

    /**
     * @author         Gabriel Alves
     * @company        PolSource
     * @created        28.06.2021
     * @description    Returns a list of Assets related to the Locations related to the Contact Id provided
     * @param          Id - contact id
     * @return         List<Asset> - A list of Assets
     */
    public List<Asset> getAssetsByContactLocations (Id contactId) {
        return
            [SELECT Id, 
                    Model_Number__c, 
                    SerialNumber, 
                    InstallDate, 
                    BrandName__c, 
                    Product_Type__c, 
                    Product_Line__c, 
                    AccountId 
               FROM Asset 
              WHERE AccountId IN (SELECT Account__c FROM GEA_AccountContactRelation__c WHERE Contact__c = :contactId)];
    }
}
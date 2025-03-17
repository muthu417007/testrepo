/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        17.06.2021
 * @description    Wrapper class for the Asset Verification method result
 */
public with sharing class CX_AssetVerificationWrapper {
    public String assetType { get; set; }
    public List<Asset> assets { get; set; }
    public List<Case_Asset__c> caseAssets { get; set; }
}
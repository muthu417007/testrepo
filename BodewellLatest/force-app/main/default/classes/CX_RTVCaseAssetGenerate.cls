/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        09.07.2021
 * @description    Class with the RTV Case Assets recommendation logic for Next Best Action
 * @testClass      CX_RTVCaseAssetGenerateTest
 */
global without sharing class CX_RTVCaseAssetGenerate {
    private static Set<String> MODELS = new Set<String>();
    
    static {
        CX_CollectionUtils.loadSet(MODELS, 'DeveloperName', [SELECT DeveloperName FROM CX_RTVUnit__mdt]);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        09.07.2021
     * @description    Returns the recommendations for the case assets
     * @param          List<String> caseIds - case ids (it's only one, but NBA only supports lists)
     * @return         List<List<Recommendation>> - A list of lists of Recommendations (it's only one list, but NBA only supports lists of lists)
     */
    @InvocableMethod(label = 'Get RTV Case assets recommendation' description = 'Returns a recommendation for the case\'s RTV assets')
    global static List<List<Recommendation>> getRTVCaseAssetRecommendation(List<String> caseIds) {
        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
        List<Recommendation> recommendations = new List<Recommendation>(); 

        List<Case_Asset__c> caseAssets = CX_AssetDAO.getInstance().getCaseAssetByCaseId(caseIds[0]);

        if(caseAssets.isEmpty()) {
            return outputs;
        }

        List<Case_Asset__c> validCaseAssets = new List<Case_Asset__c>();

        for(Case_Asset__c caseAsset : caseAssets) {
            if(MODELS.contains(caseAsset.Asset__r.Model_Number__c)) {
                validCaseAssets.add(caseAsset);
            }
        }

        if(validCaseAssets.isEmpty()) {
            return outputs;
        }

        Set<Id> validCaseAssetIds = new Set<Id>();
        CX_CollectionUtils.loadSet(validCaseAssetIds, 'Id', validCaseAssets);

        Map<String, List<Concession__c>> concessionsByCaseAssetId = new Map<String, List<Concession__c>>();
        CX_CollectionUtils.loadMap(concessionsByCaseAssetId, 'Case_Asset__c', CX_ConcessionDAO.getInstance().getConcessionsByCaseAssetId(validCaseAssetIds, 'Goodwill Certificate'));

        for(Case_Asset__c caseAsset : validCaseAssets) {
            List<Concession__c> assetConcessions = concessionsByCaseAssetId.get(caseAsset.Id);

            if(assetConcessions == null || assetConcessions.isEmpty()) {
                Recommendation recommendation = new Recommendation(
                    Name = 'RTV, Offer GWC Concession',
                    Description = 'RTV, Offer GWC Concession for asset ' + caseAsset.Asset__r.Model_Number__c,                 
                    ActionReference = 'ps_CX_GWC_Next_Best_Action_for_RTV_Units',
                    AcceptanceLabel = 'Accept',
                    RejectionLabel = 'Decline',
                    CX_AssetId__c = caseAsset.Id,
                    CX_CaseId__c = caseIds[0]
                );

                recommendations.add(recommendation);
            }
        }

        if(!recommendations.isEmpty()) {
            outputs.add(recommendations);
        }

        return outputs;
    }
}
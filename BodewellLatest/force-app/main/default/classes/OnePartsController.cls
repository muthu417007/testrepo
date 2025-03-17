public class OnePartsController{
    
    @AuraEnabled(cacheable=false)
    public static String getModelNumber(String assetId){
        List<Asset> assets = [select id,Model_Number__c 
                                    from Asset
                                    where id =: assetId];
        if(assets.size() ==1){
            return assets[0].Model_Number__c;
        }
        return null;
    }
    
}
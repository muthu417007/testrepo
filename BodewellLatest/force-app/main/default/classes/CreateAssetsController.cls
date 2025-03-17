public with sharing class CreateAssetsController {

    @AuraEnabled
    public static void attachFilesToGEAAsset(Id assetId, List<Id> filesIdList) {

        if(!filesIdList.isEmpty() && !String.isBlank(assetId)){
            List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
            for(Id fileId : filesIdList){
                linksToInsert.add(
                    new ContentDocumentLink(
                        ContentDocumentId = fileId,
                        LinkedEntityId = assetId
                    )
                );
            }
            Database.insert(linksToInsert);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTextFromPictureOCR(Id documentId) {
        List<String> detectedText = new List<String>();
        List<ContentDistribution> cdts = [
            SELECT ContentDownloadURL FROM ContentDistribution WHERE ContentDocumentId =:documentId
        ];
        if(!cdts.isEmpty() && !String.isBlank(cdts.get(0).ContentDownloadURL)){
            for(String text : ImageContentExtractor.getImageText(cdts.get(0).ContentDownloadURL)){
                if( text.length() > 7 && text.length() < 20 && text.isAlphanumeric() && !text.isAlpha()){
                    detectedText.add(text);
                }
            }
        }
        return detectedText;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBrandValuesIntoList(){
        List<String> pickListValuesList= new List<String>();

         Schema.DescribeFieldResult fieldResult = Case_Asset__c.Brand__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }     
         return pickListValuesList;
     }
}
public without sharing class KnowledgeTrgHandler {
    public static void onBeforeDelete(List<Knowledge__kav> trgNew){
        List<Knowledge_Delete__c> kdList = new List<Knowledge_Delete__c>();
        for(Knowledge__kav k : trgNew){
            kdList.add(new Knowledge_Delete__c(Knowledge_Id__c=k.Id));
		}
        insert kdList;
    }
}
/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        08.07.2022
 * @description    For getting model reference list for type ahead
 */
public without sharing class MYA_ModelRelationController {
    // Search matching model number
	@AuraEnabled(Cacheable = true)
    //Changes are part of CCOE-1213-(Product2 replaced by Model_Rel__c Object)-Yogesh Sharma/TCS/26.09.2022
    // public static List<Model_Rel__c> searchModelNumber(String Value){
    //         String searchTerm = '%' + Value +'%';
    //         return [select Id, MN__c, MR_PKMOD__c from Model_Rel__c WHERE MN__c LIKE :searchTerm];
    // }
    public static List<Product2> searchModelNumber(String Value){
            String searchTerm = '%' + Value +'%';
        	return [SELECT Id, Is_Manufacturing_Model__c, Is_Finished_Good__c, StockKeepingUnit, Marketing_Model__r.StockKeepingUnit 
                    FROM Product2 
                    WHERE Is_Manufacturing_Model__c = 'YES' AND StockKeepingUnit LIKE: searchTerm];
    }
}
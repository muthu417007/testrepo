/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        04.07.2021(dd.mm.yyyy) 
 * @description    Controller Class for cx_flowMissingItems LWC component
 * @testClass      TODO
 */
public with sharing class CX_FlowMissingItemsController {
    public static Id acctLocationTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        04.07.2021 (dd.mm.yyyy)
     * @description    returns a list to show the cases curretn situtation
     * @param          String - Id of the transactionCase
     * @return         List<String> - a list that keeps the case situation
     */
    @AuraEnabled
    public static List<String> selectCaseItems(String caseId){
        Case transactionCase = [
            Select  ContactId,AccountId,Account.RecordTypeId, (SELECT
                Asset__c,
                Serial_Number__c,
                Model_Number__c
                FROM Case_ID__r) 
        from Case where Id = :caseId];

        List<String> returnSet = new List<String>();
        if(transactionCase.ContactId == null){
            returnSet.add('emptyContact');
        }else{
            returnSet.add(transactionCase.ContactId+'');
        }

        if(transactionCase.AccountId == null && transactionCase.Account.RecordTypeId != acctLocationTypeId ){
            returnSet.add('emptyLocation');
        }else if(transactionCase.Account.RecordTypeId != acctLocationTypeId ){
            returnSet.add('emptyLocation');
         }else{
            returnSet.add(transactionCase.AccountId+'');
          }

        if(transactionCase.Case_ID__r.size() < 1){
            returnSet.add('emptyAsset');
        }
        else{
            returnSet.add('hasAssets');
        }
        return returnSet; 
    }
}
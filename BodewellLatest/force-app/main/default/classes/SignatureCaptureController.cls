public with sharing class SignatureCaptureController {

    @AuraEnabled
    public static Case updateOwnerConsent(Case caseRec){
        caseRec.Owner_Consent__c = true;
        update caseRec;
        return caseRec;
    }
}
public class PS_CustomerAgreement_TriggerHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
    }

    public void afterInsert(List<SObject> newItems) {}
    
    public void beforeDelete(Map<Id, SObject> oldItems) {
        Id profileId = userinfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]?.Name;

        if (!profileName.contains('System Administrator') ) {
            for (Customer_Agreement__c agreement : (List<Customer_Agreement__c>) oldItems.values()) {
                if (String.isNotBlank(agreement.DocuSign_Envelope_Status__c)) {
                    agreement.addError(Label.PS_CANNOT_DELETE_CUSTOMER_AGREEMENT);
                }
            }
        }
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void afterDelete(Map<Id, SObject> oldItems) {      
    }
}
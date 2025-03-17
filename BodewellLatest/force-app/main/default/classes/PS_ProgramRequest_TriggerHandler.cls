public class PS_ProgramRequest_TriggerHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;

    public Boolean IsDisabled () {
        return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
    }

    public void afterInsert(List<SObject> newItems) {

    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        Id profileId = userinfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]?.Name;

        if (!profileName.contains('System Administrator') ) {
            for (Program_Request__c request : (List<Program_Request__c>) oldItems.values()) {
                if (request.Stage_Name__c != GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_DRAFT) {
                    request.addError(Label.PS_CANNOT_DELETE_CUSTOMER_PROGRAM);
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
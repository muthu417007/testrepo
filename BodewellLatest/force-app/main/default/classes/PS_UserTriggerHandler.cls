public with sharing class PS_UserTriggerHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;
    public static String experienceName = '';

    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
        new PS_CustomerSessionIdService().generateSessionIdValue((List<User>) newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
    }

    public void afterInsert(List<SObject> newItems) {
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        new PS_UserProvisioningService().createNewUserProvRequests(
                (Map<Id, User>) newItems,
                (Map<Id, User>) oldItems
        );

        new PS_SendVerificationWebServiceHelper(experienceName)
                .sendEmailVerificationToActiveChangedEmailUsers(
                (Map<Id, User>) newItems,
                (Map<Id, User>) oldItems
        );
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
    }
}
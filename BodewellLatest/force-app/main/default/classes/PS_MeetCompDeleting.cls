public with sharing class PS_MeetCompDeleting {

    public void checkRecordToDelete(Map<Id, Meet_Comp__c> meetCompsById) {
        Id profileId = userinfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]?.Name;

        if (profileName.contains('System Administrator') || profileName.contains('B2B Integration')) {
            return;
        }

        for (Meet_Comp__c comp : meetCompsById.values()) {
            if (comp.Effective_Date__c <= Date.today() && comp.Termination_Date__c >= Date.today() && !comp.Transferred_to_Oracle__c) {
                continue;
            }

            if (comp.Effective_Date__c > Date.today() && !comp.Transferred_to_Oracle__c) {
                continue;
            }

            comp.addError(System.Label.PS_CANNOT_DELETE_MEET_COMP);
        }
    }

}
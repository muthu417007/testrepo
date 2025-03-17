public with sharing class ContactTriggerHandler {

    private static Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Contact');
    private List<Contact> triggerOldList;
    private Map<Id, Contact> triggerNewMap;

    public ContactTriggerHandler() {
        this.triggerOldList = (List<Contact>) Trigger.old;
        this.triggerNewMap = (Map<Id, Contact>) Trigger.newMap;
    }

    public void onBeforeInsert() {
        this.handleOnBeforeInsert();
    }

    public void onAfterInsert() {
        this.handleContactsOnAfterInsert();
    }

    public void onBeforeUpdate() {
        system.debug('inside before update');
        //filter Users with changed email
        List<Contact> contactsWithChangedEmail = new List<Contact>();
        List<Contact> eventsRegisteredUpdated = new List<Contact>();
        for (Contact oldContact : triggerOldList) {
            if (oldContact.Email != triggerNewMap.get(oldContact.Id).Email) {
                contactsWithChangedEmail.add(oldContact);
            }
            system.debug('enevts registered when updated--'+triggerNewMap.get(oldContact.Id).Events_Registered__c);
            system.debug('UserInfo.getName-->'+UserInfo.getName());
            if((triggerNewMap.get(oldContact.Id).Events_Registered__c != oldContact.Events_Registered__c) && UserInfo.getName()=='Data Integration'){
                system.debug('inside 1st if');
                eventsRegisteredUpdated.add(oldContact);
                system.debug('eventsRegisteredUpdated'+eventsRegisteredUpdated);
            }
        }
        system.debug('eventsRegisteredUpdated.isEmpty()'+eventsRegisteredUpdated.isEmpty());
        if(!eventsRegisteredUpdated.isEmpty()){
            system.debug('inside 2nd if');
            for(Contact oldContact:eventsRegisteredUpdated){
               if(triggerNewMap.get(oldContact.Id).Events_Registered__c!=null && triggerNewMap.get(oldContact.Id).Events_Registered__c!=''){
                if(oldContact.Events_Registered__c!=null && oldContact.Events_Registered__c!=''){
                    List<String> oldEvents = new List<String>();
                    List<String> newEvents = new List<String>();
                    for(String oldEvent: oldContact.Events_Registered__c.split(';')){
                        oldEvents.add(oldEvent.toLowerCase());
                        system.debug('oldevents-->'+oldEvents);
                    }
                    //for(String newEvent: triggerNewMap.get(oldContact.Id).Events_Registered__c.split(';')){
                        //newEvents.add(newEvent.toLowerCase());
                    //}
                    //triggerNewMap.get(oldContact.Id).Events_Registered__c =
                    if(!oldEvents.contains(triggerNewMap.get(oldContact.Id).Events_Registered__c.toLowerCase())) {
                        system.debug('inside 3rd if');
                        triggerNewMap.get(oldContact.Id).Events_Registered__c=triggerNewMap.get(oldContact.Id).Events_Registered__c+';'+oldContact.Events_Registered__c;
                    }
                }
               } 
            }
            
        }
        if (!contactsWithChangedEmail.isEmpty()) {
			for (Contact oldContact : contactsWithChangedEmail) {
            	Set<String> contactPreviousEmails =
                    String.isBlank(oldContact.Previous_Emails__c)
                            ? new Set<String>()
                            : new Set<String>(oldContact.Previous_Emails__c?.split('; '));
            	contactPreviousEmails.add(oldContact.Email);
            	triggerNewMap.get(oldContact.Id).Previous_Emails__c = String.join(new List<String>(contactPreviousEmails), '; ');
        	}
        }
    }

    public void onBeforeDelete() {
        this.checkContactsBeforeDeletion();
    }

    private void handleOnBeforeInsert() {
        new PS_ContactTriggerHandlerHelper().setContactsGlobalIds(Trigger.new);
    }

    private void checkContactsBeforeDeletion() {
        Id profileId = userinfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]?.Name;

        if (!profileName.contains('System Administrator')) {
            Set<Id> recordTypeIdsAllowedToDelete = new Set<Id>{
                    rtIdByName.get(GEA_Constants.RECORD_TYPE_CONTACT_INSTALLATION_CONTRACTOR),
                    rtIdByName.get(GEA_Constants.RECORD_TYPE_CONTACT_ARCHITECT_DESIGNER),
                    rtIdByName.get(GEA_Constants.RECORD_TYPE_CONTACT_STANDARD)
            };

            for (Contact contact : this.triggerOldList) {
                if (!recordTypeIdsAllowedToDelete.contains(contact.RecordTypeId)) {
                    contact.addError(Label.CannotDeleteContact);
                }
            }
        }
    }

    private void handleContactsOnAfterInsert() {
       
        List<Account> personAccountsToCreate = new List<Account>();
        list<contact> conList=(list<contact>)Trigger.new;
        system.debug('@@@in handleContactsOnAfterInsert'+conList);
        // Check if the Contact's record type is set to a Person Account record type
        // and if it doesn't have an associated Person Account
       /* for (Contact con : conList) {
            system.debug('@@@con in conList:'+con);
            if (con.AccountId == null) {
                Account personAccount = new Account(
                    FirstName = con.FirstName,
                    LastName = con.LastName,
                    PersonEmail = con.Email
                );
                insert personAccount;
                Contact cn=[select id,accountid from contact where id=: con.id];
                cn.AccountId=personAccount.id;
                upsert cn;
                personAccount.RecordTypeId='012DO0000008Y8FYAU';
                upsert personAccount;
                system.debug('@@@personAccount in conList:'+personAccount);
                //persopersonAccountnAccountsToCreate.add(personAccount);
            }
        }
        
        // Insert the new Person Accounts
       /* if (!personAccountsToCreate.isEmpty()) {
            insert personAccountsToCreate;
            
            system.debug('@@@personAccount in conList:'+personAccountsToCreate);
        }*/
        Map<Id, Contact> idToContactMap = (Map<Id, Contact>) Trigger.newMap;

        List<OpportunityContactRole> ocRoles = new List<OpportunityContactRole>();
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id contactId : triggerNewMap.keySet()) {
            if (triggerNewMap.get(contactId).Related_Opportunity__c != null) {
                Contact clonedContact = triggerNewMap.get(contactId).clone(true, true);
                ocRoles.add(
                        new OpportunityContactRole(
                                OpportunityId = clonedContact.Related_Opportunity__c,
                                ContactId = clonedContact.Id
                        )
                );
                clonedContact.Related_Opportunity__c = null;
                contactsToUpdate.add(clonedContact);
            }
        }
        insert ocRoles;
        update contactsToUpdate;
    }

}
trigger Contactafterinsertorupdate on Contact (before insert, after insert, before update, after update, before delete) {
    //system.debug('Trigger Count: '+triggerCountContact.getRunTimes());

    Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Contact');
    Set<Id> contactRecordTypesToOmmit = new Set<Id> {
        rtIdByName.get(GEA_Constants.RECORD_TYPE_CONTACT_ARCHITECT_DESIGNER),
        rtIdByName.get(GEA_Constants.RECORD_TYPE_CONTACT_INSTALLATION_CONTRACTOR),
        rtIdByName.get(GEA_Constants.RECORD_TYPE_CONTACT_ORACLE_SITE),
        rtIdByName.get(GEA_Constants.RECORD_TYPE_CONTACT_STANDARD)
    };

    if (Trigger.operationType == TriggerOperation.BEFORE_INSERT) {
        new ContactTriggerHandler().onBeforeInsert();
    }

    if (Trigger.operationType == TriggerOperation.AFTER_INSERT) {
        new ContactTriggerHandler().onAfterInsert();
    }

    if (Trigger.operationType == TriggerOperation.BEFORE_DELETE) {
        new ContactTriggerHandler().onBeforeDelete();
    } else if (Trigger.operationType == TriggerOperation.AFTER_INSERT || Trigger.operationType == TriggerOperation.AFTER_UPDATE) {
        if(triggerCountContact.getRunTimes()<2){
            //system.debug('Trigger Count: '+triggerCountContact.getRunTimes());

            // create a set of all unique contacts passed in to the trigger
            Set<id> contactids = new Set <id>();
            for (contact c : Trigger.new){
                if(!contactRecordTypesToOmmit.contains(c.RecordTypeId)) {
                    contactids.add(c.id);
                }
            }

            // create a list of all contacts retrieved, need the contact id and person id
            List<Contact> contactlist = [select id, PersonID__c, Heroku_Ext_ID__c from contact where id in :contactids];

            // create List to hold updated records, set the Heroku Ext Id field as appropriate
            List<Contact> updcontacts = new List<Contact>();
            for (contact c1 : contactlist ) {
                contact newcontact = new contact();
                newcontact.id = c1.id;
                //system.debug('personid: '+c1.personID__c+' Heroku_Ext_ID__c: '+c1.Heroku_Ext_Id__c);
                //if(c1.PersonID__c != NULL)
                if(c1.PersonID__c != NULL && c1.PersonID__c != c1.Heroku_Ext_ID__c)
                    newcontact.Heroku_Ext_ID__c = c1.PersonID__c;
                else if (c1.PersonID__c == NULL)
                //else if (c1.Heroku_Ext_ID__c == NULL && c1.PersonID__c == NULL)
                   newcontact.Heroku_Ext_ID__c = c1.id;
            updcontacts.add(newcontact);
            }
            triggerCountContact.setRunTimes();
            //system.debug('updcontacts: '+updcontacts);
            update(updcontacts);
        }
    }

    if (Trigger.operationType == TriggerOperation.BEFORE_UPDATE) {
        new ContactTriggerHandler().onBeforeUpdate();
    }

}
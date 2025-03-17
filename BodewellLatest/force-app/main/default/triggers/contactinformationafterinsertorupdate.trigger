trigger contactinformationafterinsertorupdate on Contact_Information__c (after insert, after update) {
    
    //system.debug('Trigger Count: '+triggerCountContactInfo.getRunTimes());
    if(triggerCountContactInfo.getRunTimes()<2){
        //system.debug('Trigger Count: '+triggerCountContact.getRunTimes());
        
    	// create a set of all unique contacts passed in to the trigger    
        Set<id> contactinfoids = new Set <id>();
        for (contact_information__c c : Trigger.new){
            contactinfoids.add(c.id);
            
        }
        
        // create a list of all contacts retrieved, need the contact information id, Heroku External Id and person detail id
        List<Contact_Information__c> contactinfolist = [select id, PersonDetailId__c, Heroku_Ext_ID__c from contact_information__c where id in :contactinfoids];
        
        // create List to hold updated records, set the Heroku Ext Id field as appropriate
        List<Contact_Information__c> updcontactinfo = new List<Contact_Information__c>();
        for (contact_information__c c1 : contactinfolist ) {
            contact_information__c newcontactinfo = new contact_information__c();
            newcontactinfo.id = c1.id;
            if(c1.PersonDetailID__c != NULL && c1.PersonDetailID__c != c1.Heroku_Ext_ID__c)
                newcontactinfo.Heroku_Ext_ID__c = c1.PersonDetailID__c;
            else if (c1.PersonDetailID__c == NULL)
            //else if (c1.Heroku_Ext_ID__c == NULL && c1.PersonDetailID__c == NULL)
               newcontactinfo.Heroku_Ext_ID__c = c1.id;     
        updcontactinfo.add(newcontactinfo);
        }
        triggerCountContactInfo.setRunTimes();
        //system.debug('updcontactinfo: '+updcontactinfo);
        update(updcontactinfo);
	}
}
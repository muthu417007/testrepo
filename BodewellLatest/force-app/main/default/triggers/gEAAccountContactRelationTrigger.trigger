trigger gEAAccountContactRelationTrigger on GEA_AccountContactRelation__c (after insert, after update) {
           
    //system.debug('Trigger Count: '+triggerCountaccount.getRunTimes());
    if(triggerCountContactLocation.getRunTimes()<2){
        //system.debug('Trigger Count: '+triggerCountaccount.getRunTimes());
        
    	// create a set of all unique accounts passed in to the trigger    
        Set<id> crids = new Set <id>();
        for (GEA_AccountContactRelation__c cr : Trigger.new){
            crids.add(cr.id);
            
        }
        
        // create a list of all accounts retrieved, need the account id and Heroku External Id
        List<GEA_AccountContactRelation__c> crinfolist = [select id, LocationPersonId__c, Heroku_Ext_ID__c from GEA_AccountContactRelation__c where id in :crids];
        
        // create List to hold updated records, set the Heroku Ext Id field as appropriate
        List<GEA_AccountContactRelation__c> updcrinfo = new List<GEA_AccountContactRelation__c>();
        for (GEA_AccountContactRelation__c cr1 : crinfolist ) {
            GEA_AccountContactRelation__c newcrinfo = new GEA_AccountContactRelation__c();
            newcrinfo.id = cr1.id;
            if(cr1.LocationPersonId__c != NULL && cr1.locationpersonid__c != cr1.Heroku_Ext_ID__c)
                newcrinfo.Heroku_Ext_ID__c = cr1.locationpersonID__c;
            else if (cr1.locationpersonid__c == NULL)
            //else if (cr1.Heroku_Ext_ID__c == NULL && cr1.locationpersonid__c == NULL)
               newcrinfo.Heroku_Ext_ID__c = cr1.id;     
        updcrinfo.add(newcrinfo);
        }
        triggerCountContactLocation.setRunTimes();
        //system.debug('updcrinfo: '+updcrinfo);
        update(updcrinfo);
	}
}
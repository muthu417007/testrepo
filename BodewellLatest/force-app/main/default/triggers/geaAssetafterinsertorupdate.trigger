trigger geaAssetafterinsertorupdate on GEA_Asset__c (after insert, after update) {
       
    //system.debug('Trigger Count: '+triggerCountGEAAsset.getRunTimes());
    if(triggerCountGEAAsset.getRunTimes()<2){
        //system.debug('Trigger Count: '+triggerCountGEAAsset.getRunTimes());
        
        // create a set of all unique assets passed in to the trigger    
        Set<id> assetids = new Set <id>();
        for (gea_asset__c a : Trigger.new){
            assetids.add(a.id);
            
        }
        
        // create a list of all assets retrieved, need the asset id and Heroku External Id
        List<gea_asset__c> assetinfolist = [select id, AssetID__c, Heroku_Ext_ID__c from gea_asset__c where id in :assetids];
        
        // create List to hold updated records, set the Heroku Ext Id field as appropriate
        List<gea_asset__c> updassetinfo = new List<gea_asset__c>();
        for (gea_asset__c a1 : assetinfolist ) {
            gea_asset__c newassetinfo = new gea_asset__c();
            newassetinfo.id = a1.id;
            if(a1.assetid__c != NULL && a1.assetid__c != a1.Heroku_Ext_ID__c)
                newassetinfo.Heroku_Ext_ID__c = a1.assetID__c;
            else if (a1.assetid__c == NULL)
            //else if (a1.Heroku_Ext_ID__c == NULL && a1.assetid__c == NULL)
               newassetinfo.Heroku_Ext_ID__c = a1.id;     
        updassetinfo.add(newassetinfo);
        }
        triggerCountGEAAsset.setRunTimes();
        //system.debug('updassetinfo: '+updassetinfo);
        update(updassetinfo);
    }
}
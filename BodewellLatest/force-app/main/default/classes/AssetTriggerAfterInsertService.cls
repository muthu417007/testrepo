/**
 * @author         Sukumar Venkatesan
 * @company        GEA
 * @created        06.Nov.2022
 * @description    This is service class for Asset trigger on After Insert trigger event.
					It contains all the methods which are called in Afterinsert trigger event
 */

public class AssetTriggerAfterInsertService {
    public static void populateHerokuExtId(List<Asset> newassets){
    	system.debug('after insert service');
        if(triggerCountGEAAsset.getRunTimes()<2){
        //system.debug('Trigger Count: '+triggerCountGEAAsset.getRunTimes());
        
    	// create a set of all unique assets passed in to the trigger    
            Set<id> assetids = new Set <id>();
            for (asset a : newassets){
                assetids.add(a.id);
            }
            if(assetids.size() > 0){
                    AssetUtility.populateHerokuExtId(assetids);
            }
            triggerCountGEAAsset.setRunTimes();
		}
    }
}
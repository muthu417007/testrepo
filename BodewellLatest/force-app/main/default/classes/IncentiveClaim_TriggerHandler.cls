/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/29/2022
 * @description    Trigger Handler for Incentive Claim trigger.
 */
public without sharing class IncentiveClaim_TriggerHandler implements PS_ITriggerHandler {
    public static Boolean triggerDisabled = false;

    public Boolean isDisabled() { //Used for preventing reccurence
        if(bypassTrigger__mdt.getInstance('IncentiveClaimTriggerHandler').bypassCriteria__c){// check to bypassTrigger through custom metadata
            TriggerDisabled=true;
        }
        return TriggerDisabled;
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { // method to handle afterUpdate trigger context
      	
    }
    
    public void beforeInsert(List<SObject> newItems){ // method to handle beforeInsert trigger context
        
            IncentiveClaimService obj = new IncentiveClaimService();
            obj.checkDuplicates(newItems); // calling method in service class
        
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems){ // method to handle beforeDelete trigger context
        
    }
    
    public void afterInsert(List<SObject> newItems){ // method to handle afterInsert trigger context
        
    }
    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){ // method to handle beforeUpdate trigger context
        
    }
    
    public void afterDelete(Map<Id, SObject> oldItems){ // method to handle afterDelete trigger context
        
    }

}
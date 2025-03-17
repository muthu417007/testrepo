public class PS_MeetComp_TriggerHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
        preventDuplicates((List<Meet_Comp__c>) newItems);
        new PS_MeetCompService().setOriginalMeetCompWhenCloned((List<Meet_Comp__c>) newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        List<Meet_Comp__c> modifiedMeetComps = new List<Meet_Comp__c>();
		Map<Id, Meet_Comp__c> triggerOld = (Map<Id, Meet_Comp__c>)oldItems;
        Map<Id, Meet_Comp__c> triggerNew = (Map<Id, Meet_Comp__c>)newItems;
        
        for (Meet_Comp__c mc : triggerNew.values()) {
            Meet_Comp__c oldMc = triggerOld.get(mc.Id);
            if (mc.Account__c != oldMc.Account__c
               || mc.GEA_Model__c != oldMc.GEA_Model__c
               || mc.MC_Type__c != oldMc.MC_Type__c
               || mc.Effective_Date__c != oldMc.Effective_Date__c
               || mc.Termination_Date__c != oldMc.Termination_Date__c) {
				modifiedMeetComps.add(mc);
            }
        }
		preventDuplicates(modifiedMeetComps);
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        new PS_MeetCompDeleting().checkRecordToDelete((Map<Id, Meet_Comp__c>) oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
      
    }

    public void afterInsert(List<SObject> newItems) {

    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
 
    }
    
    private void preventDuplicates (List<Meet_Comp__c> meetComps) {
        Map<String, List<Meet_Comp__c>> mcsByMatchingKey = new Map<String, List<Meet_Comp__c>>();
        for (Meet_Comp__c mc : meetComps) {
			setMatchingKey(mc);

            if (String.isNotBlank(mc.Matching_Key__c)) {
                if (!mcsByMatchingKey.containsKey(mc.Matching_Key__c)) {
                    mcsByMatchingKey.put(mc.Matching_Key__c, new List<Meet_Comp__c>{mc});
                } else {
                    mcsByMatchingKey.get(mc.Matching_Key__c).add(mc);
                }
            }
        }
        if (mcsByMatchingKey.isEmpty()) {
            return;
        }
     
        for (Meet_Comp__c oldMC : [SELECT Name, Matching_Key__c, Effective_Date__c, Termination_Date__c FROM Meet_Comp__c WHERE Matching_Key__c IN :mcsByMatchingKey.keySet()]) {
            for (Meet_Comp__c mc : mcsByMatchingKey.get(oldMC.Matching_Key__c)) {
                if (mc.Id != oldMc.Id 
                    && (
                        (mc.Effective_Date__c >= oldMc.Effective_Date__c && mc.Effective_Date__c <= oldMc.Termination_Date__c)
                        ||(mc.Termination_Date__c >= oldMc.Effective_Date__c && mc.Termination_Date__c <= oldMc.Termination_Date__c))) {
                    mc.addError(Label.PS_OVERLAPPING_WITH_EXISTING_MC + ' ' + oldMc.Name);
                }   
            }
        }
        
        for(String key : mcsByMatchingKey.keySet()) {
            List<ExistingDates> existingDates = new List<ExistingDates>();
            for (Meet_Comp__c mc : mcsByMatchingKey.get(key)) {
                for(ExistingDates ed : existingDates) {
                    if ((mc.Effective_Date__c >= ed.effectiveDate && mc.Effective_Date__c <= ed.terminationDate)
                            ||(mc.Termination_Date__c >= ed.effectiveDate && mc.Termination_Date__c <= ed.terminationDate)) {
                        mc.addError(Label.PS_OVERLAPPING_WITH_MC_TO_REDOC);
                  			
                    }       
                }
                
                ExistingDates ed = new ExistingDates();
                ed.effectiveDate = mc.Effective_Date__c;
                ed.terminationDate = mc.Termination_Date__c;
                existingDates.add(ed);
            }
        }
    }
    
    private void setMatchingKey (Meet_Comp__c mc) {
        if (mc.MC_Type__c != null && mc.Account__c != null && mc.GEA_Model__c != null) {
            String mcType = mc.MC_Type__c == 'MC' || mc.MC_Type__c == 'Net/Net MC' ? 'MC' : mc.MC_Type__c;
            mc.Matching_Key__c = mcType + mc.Account__c + mc.GEA_Model__c;
        }
    }
    
    private class ExistingDates {
        Date effectiveDate {get; set;}
        Date terminationDate {get; set;}
    }
}
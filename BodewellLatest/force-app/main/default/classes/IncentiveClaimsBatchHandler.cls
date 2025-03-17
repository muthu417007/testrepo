/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/27/2022
 * @description    Batch Handler for Incentive Claim Batch class.
 */
public without sharing class IncentiveClaimsBatchHandler {
    public static Set<id> sendEscalationEmails(List<ProcessInstance> prIn){ //method called from batch class to get pending processWorkItem records and send mail to "IncentiveCompensationBigHatApprovers@geappliances.com"
        Set<Id> incentiveClaimIDs = new Set<Id>();
        try{
            Map<Id, Id> incentiveClaimManagerMap = new Map<Id, Id>(); // Map of <IncentiveClaimId , RequestorRegionManagerId>
            Map<Id, Id> prcsInsInctvClaimMap = new Map<Id,Id>(); // Map for storing all the ProcessInstance Id with Incentive Claim Ids
            Map<Id, List<Id>> managerClaimMap = new Map<Id, List<Id>>(); // Map of <RequestorRegionManagerId , List of <IncentiveClaimIds>>
            for(ProcessInstance pi:prIn){ // for adding processInstanceId and IncentiveClaimIds in map
                prcsInsInctvClaimMap.put(pi.Id,pi.TargetObjectId);
            }
            
            if(!prcsInsInctvClaimMap.values().isEmpty()){
                for(Incentive_Claim__c ic:[Select Id, OwnerId, Requestor_s_Region_Manager__c from Incentive_Claim__c where Id in:prcsInsInctvClaimMap.values()]){
                    incentiveClaimManagerMap.put(ic.Id,ic.Requestor_s_Region_Manager__c);  // adding IncentiveClaimIds with it's Requestor's Region Manager Id                  
                    if(managerClaimMap.containsKey(ic.Requestor_s_Region_Manager__c)){
                        managerClaimMap.get(ic.Requestor_s_Region_Manager__c).add(ic.Id);
                    }
                    else{
                        managerClaimMap.put(ic.Requestor_s_Region_Manager__c,new List<Id>{ic.Id});
                    }
                }
            }
            if(!incentiveClaimManagerMap.values().isEmpty()){
                List<processinstanceworkitem> prWrkItem = new List<processinstanceworkitem>();
                if(!Test.isRunningTest()){
                	prWrkItem = [Select Id,OriginalActorId from processinstanceworkitem where processInstanceId in :prcsInsInctvClaimMap.keyset() and elapsedtimeindays>=:SOQL_filter__mdt.getInstance('Elapsed_Time_In_Days_Min').Number_Filter__c and elapsedtimeindays<:SOQL_filter__mdt.getInstance('Elapsed_Time_In_Days_Max').Number_Filter__c and OriginalActorId in :incentiveClaimManagerMap.values()]; // Query all ProcessWorkItems for specific ProcessInstance and whose elapsedTimeInDays is greated than equal to 3 and less than 4 and the approver is one of the region manager
                }
                else{
                    prWrkItem = [Select Id,OriginalActorId from processinstanceworkitem where processInstanceId in :prcsInsInctvClaimMap.keyset() and OriginalActorId in :incentiveClaimManagerMap.values()];
                }
                    for(processinstanceworkitem pwi : prWrkItem){
                        incentiveClaimIDs.addAll(managerClaimMap.get(pwi.OriginalActorId));
                    }
                    
            }
            
        }
        catch(Exception e){
            System.debug(LoggingLevel.INFO,'Error while executing Batch : '+e);
        }
        return incentiveClaimIDs;
    }

}
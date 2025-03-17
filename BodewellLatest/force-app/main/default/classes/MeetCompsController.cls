public with sharing class MeetCompsController {

    /*@InvocableMethod(label = 'Get Unqualified Meet Comp records' description='Send records whose Termination Date is less than Today or Stage is Awaiting Approval')
    public static List<Boolean> getUnqualifiedMeetComps(List<String> meetCompIds){
        system.debug('inside getUnqualifiedMeetComps');
        System.debug(meetCompIds);
        List<String> mcIds = meetCompIds[0].split(',');
        if([Select id,Name from Meet_Comp__c where Id in :mcIds and (Termination_Date__c < TODAY or Stage_Name__c = 'Awaiting Approval')].size() > 0){
            //return [Select id,Name from Meet_Comp__c where Id in :mcIds and (Termination_Date__c < TODAY or Stage_Name__c = 'Awaiting Approval')].size();
            return (new List<Boolean> {True});
        }
        else{
            return (new List<Boolean> {False});
        }
        //System.debug([Select id,Name from Meet_Comp__c where Id in :mcIds limit 5]);
    }*/
    
    @AuraEnabled(cacheable=true)
        public static List<Meet_Comp__c> fetchMeetComps(List<String> MeetCompIds){
            //List<String> MCIds = MeetCompIds.split(',');
            system.debug('MeetCompIds-->'+MeetCompIds);
           // System.debug('MCIds-->'+MCIds);
            System.debug([Select id from Meet_Comp__c where Id in :MeetCompIds]);
            return [Select Id,Account__c,Account__r.Name,Name,Created_by_Redoc__c,SKU__c,Termination_Date__c,Effective_Date__c,
                    GEA_Meet_Comp_Price__c,GEA_Prior_Invoice_Price__c,Quantity__c,Quantity_without_Meet_Comp__c,
                    MC_Type__c,GEA_Model__c,GEA_Model__r.Name,Stage_Name__c,Transferred_to_Oracle__c from Meet_Comp__c where Id in :MeetCompIds];
        }

        @AuraEnabled
        public static Boolean getMeetComps(List<String> MeetCompIds){
            //List<String> MCIds = MeetCompIds.split(',');
            system.debug('MeetCompIds-->'+MeetCompIds);
           // System.debug('MCIds-->'+MCIds);
            System.debug([Select id from Meet_Comp__c where Id in :MeetCompIds]);
            if([Select id,Name from Meet_Comp__c where Id in :MeetCompIds and (Termination_Date__c < TODAY or Stage_Name__c = 'Awaiting Approval')].size() > 0){
                //return [Select id,Name from Meet_Comp__c where Id in :mcIds and (Termination_Date__c < TODAY or Stage_Name__c = 'Awaiting Approval')].size();
                return True;
            }
            else{
                return False;
            }
        }
    

}
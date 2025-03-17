public class PS_MeetCompMassTerminate_ctrl {
    public List<Meet_Comp__c> selectedMeetCompRecords {get; set;}
    public String submitResultMsg {get;set;}
    public String result {get {if (result == null) {return 'success';} else return result;} set;}
	public Boolean containsSelectedRequests {get;set;}

    public PS_MeetCompMassTerminate_ctrl(ApexPages.StandardSetController controller){
        selectedMeetCompRecords = new List<Meet_Comp__c>();
        
        for (Meet_Comp__c mc : (List<Meet_Comp__c>)controller.getSelected()) {
            containsSelectedRequests = true;
            if(!Approval.isLocked(mc.Id)) {
                selectedMeetCompRecords.add(mc);   
            }       
        }
    }

    public void terminateMeetComps() {
        if(selectedMeetCompRecords.size() == 0) {
            submitResultMsg = 'None of the selected records are valid for termination.';
            result = 'info';
            return;
        }

    	List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        Meet_Comp__c[] mcsToDelete = new List<Meet_Comp__c>();
        Meet_Comp__c[] mcsToUpdate = new List<Meet_Comp__c>();
        Savepoint sp = Database.setSavepoint();

        Date today = System.today();
        for(Meet_Comp__c mc: selectedMeetCompRecords) {
            if(mc.Effective_Date__c > today && mc.Transferred_to_Oracle__c == true) {
                mc.Stage_Name__c = 'Deleted';
                mc.Operator__c = 'Delete'; 
                mcsToUpdate.add(mc);
            } else if(mc.Effective_Date__c > today && mc.Transferred_to_Oracle__c == false ) { 
                mcsToDelete.add(mc);
            } else if (mc.Effective_Date__c <= today && mc.Termination_Date__c >= today && mc.Transferred_to_Oracle__c == true) {
            	mc.Termination_Date__c = today;
                mc.Stage_Name__c = 'Approved';
                mc.Operator__c = 'Update';
                mcsToUpdate.add(mc);
            } else if (mc.Effective_Date__c <= today && mc.Termination_Date__c >= today && mc.Transferred_to_Oracle__c == false) {
 				mcsToDelete.add(mc);
            } else if (mc.Termination_Date__c < today) {
            	result = 'error';
            	submitResultMsg = 'Meet Comp has already terminated and cannot be deleted.';
            }
        }
        try {
            delete mcsToDelete;
            update mcsToUpdate;
        } catch (DmlException ex) {
            Database.rollback(sp);
            result = 'error';
            submitResultMsg = 'Termination failed with the following message: ' + ex.getDmlMessage(0);
        }
    }  
}
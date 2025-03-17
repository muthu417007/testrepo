public class PS_MeetCompBulkSubmit_ctrl {
    
    public List<Meet_Comp__c> selectedMeetCompRecords {get; set;}
    public String submitResultMsg {get;set;}
    public String result {get {if (result == null) {return 'success';} else return result;} set;}
	public Boolean containsSelectedRequests {get;set;}

    public PS_MeetCompBulkSubmit_ctrl(ApexPages.StandardSetController controller){
        selectedMeetCompRecords = new List<Meet_Comp__c>();
        
        for (Meet_Comp__c mc : (List<Meet_Comp__c>)controller.getSelected()) {
            containsSelectedRequests = true;
            if(!Approval.isLocked(mc.Id)) {
                selectedMeetCompRecords.add(mc);   
            }       
        }
    }

    public void submitForApproval() {
        if(selectedMeetCompRecords.size() == 0) {
            submitResultMsg = 'None of the selected records are valid for approval.';
            result = 'info';
            return;
        }

    	List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            submitResultMsg = 'The following Meet Comp records were submitted for approval: \n';
            
        for(Meet_Comp__c mt: selectedMeetCompRecords) { 
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Bulk Submitted by' + userInfo.getName()); 
            req.setObjectId(mt.Id); 
            requests.add(req);
            submitResultMsg += mt.Name + ' ';
        }
        try {
            Approval.ProcessResult[] processResults = Approval.process(requests);
        } catch (Exception ex) {
            result = 'error';
            submitResultMsg = 'Submittion failed with the following message: ' + ex.getMessage();
        }
    }  
}
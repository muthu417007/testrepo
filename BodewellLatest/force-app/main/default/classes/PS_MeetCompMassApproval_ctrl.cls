public class PS_MeetCompMassApproval_ctrl {

    public String submitResultMsg {get;set;}
    public String result {get {if (result == null) {return 'success';} else return result;} set;}
	public Boolean containsSelectedRequests {get;set;}
    private List<ProcessInstanceWorkitem> processItems {get; set;}
    public Boolean userHasAccess {get;set;}
	public String comments {get;set;}
    public boolean displayPopup {get; set;}
    public PS_MeetCompMassApproval_ctrl(ApexPages.StandardSetController controller){
 		userHasAccess = [SELECT  Count() FROM GroupMember 
                         WHERE Group.Type = 'Queue' AND Group.DeveloperName= 'Pricing_Team_Meet_Comp' AND UserOrGroupId = :UserInfo.getUserId()] > 0;

        Set<Id> selected = new Set<Id>();
 
        for (Meet_Comp__c mc : (List<Meet_Comp__c>)controller.getSelected()) {
        	selected.add(mc.Id);
        }
        processItems = [Select ProcessInstance.TargetObject.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :selected];
        containsSelectedRequests = !processItems.isEmpty(); 
    }
    
    public void approveRecords () {
        processRecords('Approve');
    }
    
    public void rejectRecords () {
        processRecords('Reject');
    }
    
    public void processRecords(String action) {
        if(processItems.size() == 0) {
            submitResultMsg = 'None of the selected records are valid for approval / rejection.';
            result = 'info';
            return;
        }

        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        submitResultMsg = action == 'Approve' ? 'The following Meet Comp records were approved: \n' :
        	'The following Meet Comp records were rejected: \n';
        
        for(ProcessInstanceWorkitem workItem  : processItems) {
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
			req2.setComments(comments);
			req2.setAction(action);
			req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
			req2.setWorkitemId(workItem.Id);
            requests.add(req2);
            submitResultMsg += workItem.ProcessInstance.TargetObject.Name + ' ';
       }
        
        try {
            Approval.ProcessResult[] processResults = Approval.process(requests);
        } catch (Exception ex) {
            result = 'error';
            submitResultMsg = 'Approval failed with the following message: ' + ex.getMessage();
        }
    }     
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
}
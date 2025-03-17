public class PendingApprovalItemsController {
	@AuraEnabled
	public static List<ProcessInstance> getPendingApprovals() {
		String currentUser = UserInfo.getUserId();
		List<ProcessInstance> approvals = [
            SELECT 
            	Id, CreatedById, Status, TargetObjectId, TargetObject.Name, CreatedDate 
            FROM 
            	ProcessInstance 
            WHERE 
            	CreatedById = :currentUser
            	AND (Status = 'In Progress' OR Status = 'Pending')            	
        ];
      
		if (approvals == null || approvals.isEmpty()) {
			return null;
		}
        return approvals;
    }
}
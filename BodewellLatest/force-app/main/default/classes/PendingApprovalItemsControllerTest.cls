@isTest
private class PendingApprovalItemsControllerTest {
	@isTest
    private static void getPendingApprovalsTest() {
        List<ProcessInstance> approvals = new List<ProcessInstance>();
        approvals = PendingApprovalItemsController.getPendingApprovals();
        
        //System.assert(approvals.isEmpty());
        //System.assertEquals(null, approvals);
    }
}
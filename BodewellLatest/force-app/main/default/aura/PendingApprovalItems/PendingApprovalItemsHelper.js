({
	refreshFlowList: function(component) {
    	var action = component.get("c.getPendingApprovals");
    	action.setCallback(this, function(response) {
        	var approvals = response.getReturnValue();
        	if (Array.isArray(approvals) && approvals.length) {
        		component.set("v.pendingApprovals", approvals);
        		component.set("v.noPendingApprovalsAvailable", false);
        	} else {
        		component.set("v.noPendingApprovalsAvailable", true);
        	}
    	});
    	$A.enqueueAction(action);
    },
})
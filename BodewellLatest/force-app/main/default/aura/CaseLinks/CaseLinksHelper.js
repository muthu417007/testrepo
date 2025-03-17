({
	getCase : function(cmp, event, helper)
	{
		var action = cmp.get("c.queryCase");
        
        action.setParams({  caseId : cmp.get("v.recordId") });
		
		action.setCallback(this, function(response){
			cmp.set("v.case", response.getReturnValue());
		});
		$A.enqueueAction(action);
	}
})
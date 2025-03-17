({
	myAction : function(component, event, helper) {
		
        component.set("v.Columns", [
            {label:"Id", fieldName:"Id", type:"text"},
            {label:"NewFI__c", fieldName:"NewFI__c", type:"text"},
            {label:"NewFI_Redirect_URL__c", fieldName:"NewFI_Redirect_URL__c", type:"text"}
        ]);
        
        var action = component.get("c.getNewFIURL");
		action.setParams({
    	recordId: component.get("v.recordId")
});
	action.setCallback(this, function(data) {
    component.set("v.WorkOrder", data.getReturnValue());
});
	$A.enqueueAction(action);

	}
})
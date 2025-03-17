({
	init: function(component, event, helper) {
    	helper.refreshFlowList(component);
	},
    
    navigateToRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": event.target.dataset.value,
          "slideDevName": "detail"
        });
        navEvt.fire();
    }
})
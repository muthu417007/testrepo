({
	doInit : function(component, event, helper) {
        helper.getCase(component, event, helper);
	},
    
    handleTrackAndTrace : function (component, event, helper) 
	{
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:TrackAndTraceIntegration",
            componentAttributes: {
                //trackingNumber : component.get("v.case.Id")
            }
        });
        evt.fire();
	},    
    handleCybersource : function (component, event, helper) 
	{
		/*var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CybersourceIntegration",
            componentAttributes: {
                contactId : component.get("v.case.ContactId")
            }
        });        
        evt.fire();*/
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url" : "/apex/CybersourceSign?Id="+component.get("v.recordId")
        });        
        urlEvent.fire();
	},    
    handleConvey : function (component, event, helper) 
	{
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ConveyIntegration",
            componentAttributes: {
                contactId : component.get("v.case.ContactId")
            }
        });
        evt.fire();
	},
    
    handleHistory : function (component, event, helper) 
	{
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:serviceOrderHistory",
            componentAttributes: {
                contactId : component.get("v.case.ContactId")
            }
        });
        evt.fire();
	}
    
})
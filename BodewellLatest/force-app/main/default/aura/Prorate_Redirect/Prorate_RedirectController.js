({    

	invoke : function(component, event, helper) {
   // Get the record ID attribute
   var record = component.get("v.RecordId");
   
   // Get the Lightning event that opens a record in a new tab
   var urlEvent = $A.get("e.force:navigateToSObject");
   
   // Pass the record ID to the event
   urlEvent.setParams({
      "url": '/flow/Prorate_Calculator_Headless'+record+'/view',
            "slideDevName":"detail",
   });
        
   // Open the record
   urlEvent.fire();
}})
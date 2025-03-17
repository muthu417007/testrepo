({    

	invoke : function(component, event, helper) {
   // Get the record ID attribute
   var record = component.get("v.recordId");
   
   // Get the Lightning event that opens a record in a new tab
   var urlEvent = $A.get("e.force:navigateToSObject");
   
   // Pass the record ID to the event
   urlEvent.setParams({
      //"url": '/lightning/r/Concession__c/'+record+'/view',
            //"slideDevName":"detail",
      "recordId": record
   });
        
   // Open the record
   urlEvent.fire();
}})
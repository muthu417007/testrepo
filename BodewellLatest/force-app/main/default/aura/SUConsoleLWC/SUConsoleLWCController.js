({
    doInit : function(component, event, helper) {
       var newRecordId = component.get("v.recordId");
    	var action = component.get("v.record.Id");
        var a = component.get('c.getCaseRecord');
        $A.enqueueAction(a);
    

	},
    getCaseRecord : function(component, event, helper) {
        var action = component.get("c.getCurrentCaseSubject");
        action.setParams({ 
            idd : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
        //  System.debug('we get this response'+response+response.getReturnValue());
          component.set("v.caseSub", response.getReturnValue());
        });
     $A.enqueueAction(action);
        //execute lwc method
       // component.find('sU_SearchClientLWCContainer').executeFromAura();
    }
   

})
({
    doInit: function(component, event, helper) {        
        var action = component.get("c.getRecordTypeValues");
        var OppId = component.get("v.recordId");
        console.log(OppId);
        component.set("v.OpprecordId", OppId);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var recordTypes = result.contactRecordTypes;
                var recordtypeMap = [];
                for(var key in recordTypes){
                    recordtypeMap.push({label: recordTypes[key], value: key});
                }
                component.set("v.recordTypeMap", recordtypeMap);
                component.set("v.selectedRecordTypeId", result.defaultRecordTypeId);
            }
        });
        $A.enqueueAction(action);
    },
     
    handleCreateRecord: function(component, event, helper) { 
        var selectedRecordTypeId = component.get("v.selectedRecordTypeId");
        var OppId = component.get("v.OpprecordId");
        if(selectedRecordTypeId){
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": 'Contact',
                "recordTypeId": selectedRecordTypeId,
                "defaultFieldValues": {
        			'Related_Opportunity__c' : OppId}
            });
            createRecordEvent.fire();
        }
    }
})
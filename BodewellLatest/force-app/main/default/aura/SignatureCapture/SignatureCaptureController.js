({
    doInit: function(component) {
        var device = $A.get("$Browser.formFactor");
        if(device === 'DESKTOP'){
            component.set("v.isDesktop", true);
        }
    },

    handleCaptured : function(component, event, helper) {
        var toastEvent= $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":'success',
            "title":'Success',
            "message":'Signature was successfully captured'
        });
        toastEvent.fire();

        var action = component.get("c.updateOwnerConsent");
        action.setParams({"caseRec": component.get("v.caseRecord")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var c = response.getReturnValue();
                component.set("v.caseRecord", c);
                $A.get('e.force:refreshView').fire();
            } else {
                console.log('There was a problem : '+ response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    goBack: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
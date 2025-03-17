({
    doInit : function(component, event, helper) {
        var getClassName = setInterval(function(){
            if(document.getElementsByClassName('su__utilityBar') && document.getElementsByClassName('su__utilityBar')[0]) {
                clearInterval(getClassName);
                component.set("v.utilityBarWidth", document.getElementsByClassName('su__utilityBar')[0].offsetWidth);
 				component.set("v.utilityBarTop", document.getElementsByClassName('su__utilityBar')[0].getBoundingClientRect().y);
            }
        }, 100);
        var a = component.get('c.getCaseRecord');
        $A.enqueueAction(a);
	},
    getCaseRecord : function(component, event, helper) {
        var action = component.get("c.getCurrentCaseSubject");
        action.setParams({ 
            idd : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
            try {
                if (response.getReturnValue()){
                    let data = JSON.parse(response.getReturnValue());
					component.set("v.caseSub", data.Subject);
					component.set("v.preSelectedValues", data);
                }
            } catch (error) {
                console.log('Error: ',error);
            }
        });
     $A.enqueueAction(action);
    }
})
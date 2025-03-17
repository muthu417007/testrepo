({
	doInit : function(cmp) {
        var action = cmp.get("c.getModelNumber");
        action.setParams({ assetId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 //alert("From server: " + response.getReturnValue());
                let tempURL =cmp.get('v.iframeUrl') + '&pq=' +response.getReturnValue();
                //alert('new url ' + tempURL);
				cmp.set('v.iframeUrl',tempURL);
           }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    
//@AuraEnabled
    //var recId = component.get("v.recordId");
    // var modelNumber = component.get('c.component.recordId.Model_Number__c');
    // var modelNumber = [SELECT Model_Number__c from GEA_Asset__c Where id= :recId];
    //var searchUrl = "https://www.ordergeapplianceparts.com/search?q=";
    //return searchUrl + modelNumber;
    }
        
        //return [SELECT Model_Number__c from GEA_Asset__c Where id];
	
})
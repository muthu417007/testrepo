({
	getresponsefs : function(component,phonenum,type) {
         phonenum=phonenum.replace('"', '');
        phonenum=phonenum.replace('"', '');
        
            var url='https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnect?phoneNumber='+phonenum;
        	console.log('url',url); 
        
        
        var action = component.get('c.getCalloutResponseContents');
        action.setParams({url : url });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ids =response.getReturnValue();
                console.log('response in init call history',ids);
                 var FSCallHistoryDetails =ids['FSCallHistoryDetails'];
                  console.log('FSCallHistoryDetails',FSCallHistoryDetails);
               	if(FSCallHistoryDetails.includes("Error"))
                {
                    component.set('v.loaded', "true");  
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        "title": "No Record Found!",
                        "message": "There are no records found for this Case."
                    });
                    toastEvent.fire(); 
                }
                else
                {
                               
                    component.set('v.loaded', "true");  
                    component.set('v.mydata', FSCallHistoryDetails);
                }
                
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
            }
        }));
        $A.enqueueAction(action);
	},
    getresponsecc : function(component,phonenum,type) {
         phonenum=phonenum.replace('"', '');
        phonenum=phonenum.replace('"', '');
        
            var url='https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnectCC?phoneNumber='+phonenum;
        	console.log('url',url); 
        
        
        var action = component.get('c.getCalloutResponseContents');
        action.setParams({url : url });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ids =response.getReturnValue();
                console.log('response in init call history',ids);
                 var CCCallHistoryDetails =ids['CCCallHistoryDetails'];
                  console.log('CCCallHistoryDetails',CCCallHistoryDetails);
               	if(CCCallHistoryDetails[0]['ErrorCode']=="ZeroCount")
                {
                    component.set('v.loadedcc', "true"); 
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        "title": "No Record Found!",
                        "message": "There are no records found for this Case."
                    });
                    toastEvent.fire(); 
                }
                else
                {
                               
                    component.set('v.loadedcc', "true");  
                    component.set('v.mydata2', CCCallHistoryDetails);
                }
                
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
            }
        }));
        $A.enqueueAction(action);
	}
})
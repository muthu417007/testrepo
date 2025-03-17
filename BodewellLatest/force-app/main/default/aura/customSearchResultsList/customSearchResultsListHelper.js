({
	getresponse : function(component,caseId) {

        
        var url='https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnectmain?casenum='+caseId;
        console.log('url',url);
        var action = component.get('c.getCalloutResponseContents');
        action.setParams({url : url });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            var norecord="";
            if (state === "SUCCESS") {
                var ids =response.getReturnValue();
                console.log('response in init',ids);
                var isrecords=ids['Status'];
                if(isrecords=="Norecords")
                {
                    norecord="true";
                    component.set('v.boolean', norecord);
                    console.log('boolean value',norecord);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        "title": "No record!",
                        "message": "There are no records found for this Case."
                    });
    				toastEvent.fire();
                }
               else
               {
                 var contactlist =ids['Consumer Details'];
                console.log('contactlist',contactlist);
                component.set('v.rec', contactlist);
                var phonenum =contactlist[0]['ph_home'];
                console.log('phonenum',phonenum);
                sessionStorage.setItem('phonenum', JSON.stringify(phonenum));
                var conactivities =ids['Consumer Activities'];
                console.log('conactivities',conactivities);
                   if(Array.isArray(conactivities) && conactivities.length)
                   {
                       component.set('v.load', "false");
                   }
                   else
                   {
                       
                       component.set('v.load', "true");   
                		component.set('v.mydata', conactivities);
                   }
                component.set('v.load', "true");   
                component.set('v.mydata', conactivities);
                var caseactivities =ids['Case Activities'];
                console.log('caseactivities',caseactivities);
                component.set('v.mydatanext', caseactivities);  
               }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
            }
        }));
        $A.enqueueAction(action);
	}
})
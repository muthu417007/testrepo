({
	getresponse : function(component,url) {        
        console.log("inside getresponse");
        console.log('url',url);
        var action = component.get('c.getCalloutResponseContents');
        action.setParams({url : url });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            var norecord="";
            if (state === "SUCCESS") {
                var ids =response.getReturnValue();
                console.log('Case list for OSC using phone',ids);
                var isrecords=ids['Status'];
                if(isrecords=="Norecords")
                {
                    norecord="true";
                    component.set('v.boolean', norecord);
                    console.log('boolean value',norecord);
                    component.set('v.loaded', "true");  
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "No Data found from OSC!"
                    });
                    toastEvent.fire();
                }
               else
               {
                 
                var searchlist =ids['Search Results'];
                console.log('searchlist',searchlist);
                component.set('v.loaded', "true");   
                component.set('v.mydata', searchlist);
                
               }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
            }
        }));
        $A.enqueueAction(action);
         
	},
    action1 : function(component,phonenum)
    {
        console.log("inside action1");
        var action1 = component.get('c.getCaseFromPhone');
            action1.setParams({
                "phoneNumber": phonenum
            });
                 
            action1.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var recordId = response.getReturnValue();
                    console.log("case list from SFDC",recordId);
                    
					           
                    if(recordId.length==0)
                    {
                        component.set('v.loadedsfdc', "true");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "No Data found from SFDC!"
                        });
                        toastEvent.fire();
                    }
                    else
                    {
                        for(var i=0;i<recordId.length;i++)
                        {
                            if(!recordId[i].First_Name__c)
                            {
                                recordId[i].First_Name__c="Not Available";
                            }
                            if(!recordId[i].Last_Name__c )
                            {
                                recordId[i].Last_Name__c ="Not Available";
                            }
                        }
                        component.set('v.mydata2', recordId);
                        console.log("case new list from SFDC",recordId);
                        component.set('v.loadedsfdc', "true");                        
                        
                    }
                    
                }
            });
            
            $A.enqueueAction(action1);
    },
    action2 : function(component,firstname,lastname,zipcode)
    {
        console.log("inside action2");
        var action2 = component.get('c.getCaseFromzipcode');
            action2.setParams({
                "firstname": firstname,
                "lastname":lastname,
                "zipcode":zipcode
            });
                 
            action2.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var recordId = response.getReturnValue();
                    console.log("case list from SFDC",recordId);
                     if(recordId.length==0)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "No Data found from SFDC!"
                        });
                        toastEvent.fire();
                    }
                    else
                    {
                        component.set("v.mydata2", recordId);
                    }
                }
            });
            
            $A.enqueueAction(action2);
    },
    action3 : function(component,street,lastname,zipcode)
    {
        console.log("inside action3");
        var action3 = component.get('c.getCaseFromstreet');
            action3.setParams({
                "street": street,
                "lastname":lastname,
                "zipcode":zipcode
            });
                 
            action3.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var recordId = response.getReturnValue();
                    console.log("case list from SFDC",recordId);
                     if(recordId.length==0)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "No Data found from SFDC!"
                        });
                        toastEvent.fire();
                    }
                    else
                    {
                        component.set("v.mydata2", recordId);
                    }
                }
            });
            
            $A.enqueueAction(action3);
    }

    
})
({
    getCaseRecord : function(component, event, helper) {
        var navService = component.find("navService");
        var caseID  = component.get('v.caseId');
        
        if(caseID==undefined)
        {
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Enter Valid OSC Case Number."
                });
                toastEvent.fire();
        }
        else
        {
            var check =caseID.search("-");
            if(check>=1)
            {
                var action = component.get('c.getCaseFromId');
                action.setParams({caseID : caseID });            
                action.setCallback(this, function(response){
                var state = response.getState();
                    if (state === 'SUCCESS') {
                      var ids = response.getReturnValue();
                       console.log('ccicasesearch ids ',caseID);
                       component.set("v.recordId", response.getReturnValue());
                      sessionStorage.setItem('ccicasesearch--recordIds', JSON.stringify(caseID));
                     
                        var pageReference = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__customSearchResultsList',
                                ccicasesearchcaseid: caseID
                            },
                            state: {
                                "firstName":"Test"
                            }
                        };
            component.set("v.pageReference", pageReference);
                            event.preventDefault();
            navService.navigate(pageReference);
                    }
            }); 
            }
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Enter a valid OSC case Number."
                });
                toastEvent.fire();
            }

            
         $A.enqueueAction(action); 
        }

       
      
    },
    getCaseRecordphone : function(component, event, helper) {
        
        console.log("inside getCaseRecordphone");
        var phoneNumber  = component.get('v.phoneNumber');
        console.log("phoneNumber ",phoneNumber);
        if(phoneNumber== undefined)
        {
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Please enter phone number."
                });
                toastEvent.fire();
        }
        else if(phoneNumber.length==10)
        {
          sessionStorage.setItem('ccicasesearch--phone', JSON.stringify(phoneNumber));
         /* var navEvt = $A.get('e.force:navigateToURL');
          navEvt.setParams({url: '/case-list'});
          navEvt.fire();*/
            var navServicephone = component.find("navServicephone");
            var pageReferencephone = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__caseList'
                            }
                        };
            component.set("v.pageReferencephone", pageReferencephone);
            event.preventDefault();
            navServicephone.navigate(pageReferencephone);
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Phonenumber length should be 10."
                });
                toastEvent.fire();
        }
        
       
      },
    getCaseRecordsearch1 : function(component,event,helper) {
        console.log("inside getCaseRecordsearch1");
    	var firstname  = component.get('v.firstname');
        console.log("firstname ",firstname);
    	var lastname  = component.get('v.lastname');
        console.log("lastname ",lastname);
    	var zipcode  = component.get('v.zipcode');
        console.log("zipcode ",zipcode);
    		if(firstname==undefined || lastname==undefined||zipcode==undefined)
    		{
    			var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Value Missing. Please Enter values in all 3 fields."
                });
                toastEvent.fire();
			}
            else
            {
                sessionStorage.setItem('ccicasesearch--firstname', JSON.stringify(firstname));
                sessionStorage.setItem('ccicasesearch--lastname', JSON.stringify(lastname));
                sessionStorage.setItem('ccicasesearch--zipcode', JSON.stringify(zipcode));
          		var navServicephone = component.find("navServicephone");
            	var pageReferencephone = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__caseList'
                            }
                        };
            component.set("v.pageReferencephone", pageReferencephone);
            event.preventDefault();
            navServicephone.navigate(pageReferencephone);
            }
	},
    getCaseRecordsearch2 : function(component,event,helper) {
    	var street  = component.get('v.street');
        console.log("street ",street);
    	var lastname  = component.get('v.lastname');
        console.log("lastname ",lastname);
    	var zipcode  = component.get('v.zipcode');
        console.log("zipcode ",zipcode);
    		if(street==undefined || lastname==undefined||zipcode==undefined)
    		{
    			var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Value Missing. Please Enter values in all 3 fields."
                });
                toastEvent.fire();
			}
            else
            {
                sessionStorage.setItem('ccicasesearch--street', JSON.stringify(street));
                sessionStorage.setItem('ccicasesearch--lastname', JSON.stringify(lastname));
                sessionStorage.setItem('ccicasesearch--zipcode', JSON.stringify(zipcode));
          		var navServicephone = component.find("navServicephone");
            var pageReferencephone = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__caseList'
                            }
                        };
            component.set("v.pageReferencephone", pageReferencephone);
            event.preventDefault();
            navServicephone.navigate(pageReferencephone);
            }
	}
})
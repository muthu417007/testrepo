({
	getContact : function(cmp, event, helper)
	{
		var action = cmp.get("c.queryContact");
        action.setParams({  conId : cmp.get("v.contactId") });
		
		action.setCallback(this, function(response){
			cmp.set("v.firstName", response.getReturnValue().FirstName);
            cmp.set("v.lastName", response.getReturnValue().LastName);
            cmp.set("v.street", response.getReturnValue().MailingStreet);
            cmp.set("v.city", response.getReturnValue().MailingCity);
            cmp.set("v.state", response.getReturnValue().MailingState);
            cmp.set("v.zipcode", response.getReturnValue().MailingPostalCode);
		});
		$A.enqueueAction(action);
	},
    
    postRequest : function(cmp, event, helper)
	{
        let action = cmp.get("c.getBody");		
        let body;
		action.setCallback(this, function(response){
            body=response.getReturnValue();
            console.log(body);  
            this.navigateToUrl(body);
		});
		$A.enqueueAction(action);
	}, 
    navigateToUrl : function(urlToGo){
        var xhr = new XMLHttpRequest();
		xhr.open("POST", 'https://secureacceptance.cybersource.com/pay', true);
		xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
		xhr.send(urlToGo);
        
        //var urlParamsEncoded = encodeURI(urlParams);
        //url += urlParamsEncoded;
        //url += urlParams;
        //console.log(url);
        //window.open(url,'_top');
        /*let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": urlToGo
        });
        urlEvent.fire();*/
    },
    secureacceptanceSign : function(cmp, event, helper)
	{
         var action = cmp.get("c.sign");
        
        action.setParams({  postData : "" });
		
		action.setCallback(this, function(response){
            //console.log(getReturnValue());
		});
		$A.enqueueAction(action);
	}, 
})
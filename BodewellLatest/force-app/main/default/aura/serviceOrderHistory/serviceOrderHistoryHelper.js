({
	getClosedCalls : function(cmp, event, helper)
	{
		//var action = cmp.get("c.historyCallout");
		var action = cmp.get("c.closedCalls");
        action.setParams({  conId : cmp.get("v.contactId") });
		
		action.setCallback(this, function(response){
            //console.dir(response.getReturnValue());
            //console.dir(response.getReturnValue().fs_callhistory);
        	cmp.set("v.closedCalls", response.getReturnValue());
            cmp.set("v.result",response.getState());
		});
		$A.enqueueAction(action);
	},
    /*,
    getClosedOrders : function(cmp, event, helper)
	{
		//var action = cmp.get("c.historyCallout");
		var action = cmp.get("c.serviceOrders");
        action.setParams({  conId : cmp.get("v.contactId") });
		
		action.setCallback(this, function(response){
            //console.dir(response.getReturnValue());
            //console.dir(response.getReturnValue().fs_callhistory);
        	cmp.set("v.serviceOrders", response.getReturnValue());
           
            console.dir(response.getReturnValue());
            //cmp.set("v.result",response.getState());
		});
		$A.enqueueAction(action);
	},*/
    getOrders : function(cmp, event, helper)
	{
		//alert('get Orders');
		var action = cmp.get("c.get360Orders");
        action.setParams({  conId : cmp.get("v.contactId") });
		
		action.setCallback(this, function(response){
            console.dir('response ' + response);
            //console.dir('response.error ' + response.getError());
            console.dir('response returnValue ' + response.getReturnValue());
            console.dir('response returnValue string ' + JSON.stringify(response.getReturnValue()));
            console.dir('response returnValue status  ' + response.getReturnValue().status);
            console.dir('response returnValue status message ' + response.getReturnValue().status.Message);
              
            if(response.getReturnValue().status.Message != 'Success'){
                console.log('set status message not null');
            	cmp.set("v.numberOrders", response.getReturnValue().status.Message);    
            } else {
                cmp.set("v.orders", response.getReturnValue());
            	cmp.set("v.numberOrders", response.getReturnValue().data.PersonById.Orders.length);    
            }
           
            //console.dir(response.getReturnValue());
            //cmp.set("v.result",response.getState());
		});
		$A.enqueueAction(action);
	},
    getOpenCalls : function(cmp, event, helper)
	{
       
		//var action = cmp.get("c.historyCallout");
		var action = cmp.get("c.openCalls");
        action.setParams({  conId : cmp.get("v.contactId") });
		
		action.setCallback(this, function(response){
            console.log('open call return');
            console.dir(response.getReturnValue());
            //console.dir(response.getReturnValue().fs_callhistory);
        	cmp.set("v.openCalls", response.getReturnValue());
            cmp.set("v.resultOpen",response.getState());
		});
		$A.enqueueAction(action);
	}
})
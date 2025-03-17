({
	doInit : function(cmp) {
		//alert(cmp.get("v.contactId"));	
        
	},
    createCase : function(cmp) {
    	var workspaceTab = cmp.find("workspace");
        cmp.destroy();
        alert(workspaceTab);
            workspaceTab.getFocusedTabInfo().then(function(response) {
            console.log('response' +JSON.stringify(response));
            var focusedTabId = response.tabId;
            workspaceTab.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log('response' +JSON.stringify(response));
            console.log(error);
        });    
    }
})
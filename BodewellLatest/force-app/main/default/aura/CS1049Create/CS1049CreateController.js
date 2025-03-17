({
	openTabWithSubtab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var rid = component.get("v.recordId");
        //var rid = "5002g000002YRC6AAO";

        workspaceAPI.openTab({
            //url: '/lightning/page/recordActionFlow?lightning__flowDevName=CS1049',
            url: '/lightning/page/recordActionFlow?lightning__flowDevName=CS1049&lightning__recordId=' + rid,
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                //url: '/lightning/page/recordActionFlow?lightning__flowDevName=CS1049',
                url: '/lightning/page/recordActionFlow?lightning__flowDevName=CS1049&lightning__recordId=' + rid,
                focus: false
            });
        })
		
        .catch(function(error) {
            console.log(error);
        });
    }
})
({
	newUser : function(component, event, helper) {
		var flow = component.find("flowId"); 
        flow.startFlow("Login_flow_for_DFS_community");
        //var elements = document.getElementsByClassName("button");
        //elements[0].style.display = 'none';
        //var toggleText = component.find("button");
        //$A.util.toggleClass(toggleText, "toggle");
        //var btnclickd = event.getSource();
		//btnclickd.set("v.disabled",true);
	},
})
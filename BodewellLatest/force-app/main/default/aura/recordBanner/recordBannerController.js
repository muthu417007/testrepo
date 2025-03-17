({
	init : function(component, event, helper) {
	        
        var casenum = sessionStorage.getItem('casenum');
        casenum = casenum.replace('"', '');
        casenum = casenum.replace('"', '');
        component.set("v.casenum", casenum);
        var owner = sessionStorage.getItem('owner');
        owner = owner.replace('"', '');
        owner = owner.replace('"', '');
        component.set("v.owner", owner);
        var recordtype = sessionStorage.getItem('recordtype');
        recordtype = recordtype.replace('"', '');
        recordtype = recordtype.replace('"', '');
        component.set("v.recordtype", recordtype);
        var priority = sessionStorage.getItem('priority');
        priority = priority.replace('"', '');
        priority = priority.replace('"', '');
        component.set("v.priority", priority);
        var status = sessionStorage.getItem('status');
        status = status.replace('"', '');
        status = status.replace('"', '');
        component.set("v.status", status);
        var cs1049rejectval = sessionStorage.getItem('cs1049rejected');
        console.log('cs1049rejectval',cs1049rejectval);
        cs1049rejectval = cs1049rejectval.replace('"', '');
        cs1049rejectval = cs1049rejectval.replace('"', '');
        
        var cs1049reject;
        if(cs1049rejectval=='true')
        {
            cs1049reject='true';
        }
        else if(cs1049rejectval=='false')
        {
            cs1049reject='false';
        }
       console.log('cs1049reject',cs1049reject);
        component.set("v.cs1049reject", cs1049reject);
        var cs1049triggerval = sessionStorage.getItem('cs1049trigger');
        console.log('cs1049triggerval',cs1049triggerval);
        cs1049triggerval = cs1049triggerval.replace('"', '');
        cs1049triggerval = cs1049triggerval.replace('"', '');
        var cs1049trigger;
        if(cs1049triggerval=='Yes')
        {
			cs1049trigger='true';            
        }
        else if(cs1049triggerval=='No')
        {
            cs1049trigger='false';
        }
        console.log('cs1049trigger',cs1049trigger);
        component.set("v.cs1049trigger", cs1049trigger);
        component.set("v.cs1049created", cs1049trigger);
	}
})
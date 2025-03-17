({
	init: function (component, event, helper) {
        var idsJson = sessionStorage.getItem('phonenum'); 
        var phonenum = idsJson.toString(); 
        phonenum=phonenum.replace('""', '');
        phonenum=phonenum.replace('/', '');
        phonenum=phonenum.replace('/', '');
        console.log('phonenum call history',phonenum);
        var type = sessionStorage.getItem('type'); 
        var type = type.toString();
        type=type.replace('"', '');
        type=type.replace('"', '');
        sessionStorage.removeItem('type'); 
        console.log('type call history',type);
        var pageReferences = component.get("v.pageReferences");
        console.log('pageReferences',pageReferences);
        if(type=='fscall')
        {
            console.log('inside if');
            component.set('v.typefs',"true");
            
        helper.getresponsefs(component,phonenum);
        }
        else
        {
            console.log('inside else');
            component.set('v.typecc',"true");
           helper.getresponsecc(component,phonenum);
        }
        
    },
    home: function (component, event, helper) {
          var navEvt = $A.get('e.force:navigateToURL');
          navEvt.setParams({url: '/'});
          navEvt.fire();
    }
})
({
	init : function(component, event, helper) {
		var email = sessionStorage.getItem('email');
        console.log('email',email);
        email = email.replace('"', '');
        email = email.replace('"', '');
        if(email=="undefined")
        {
            email="Not available";
        }
        component.set("v.email", email);
        var mobile = sessionStorage.getItem('mobile');
        mobile = mobile.replace('"', '');
        mobile = mobile.replace('"', '');
        console.log('mobile',mobile);
        if(mobile=="undefined")
        {
            mobile="Not available";
        }
        component.set("v.mobile", mobile);
        var phone = sessionStorage.getItem('phone');
        phone = phone.replace('"', '');	
        phone = phone.replace('"', '');	
        if(phone=="undefined")
        {
            phone="Not available";
        }
        component.set("v.phone", phone);
        var name = sessionStorage.getItem('name');
        name = name.replace('"', '');	
        name = name.replace('"', '');	
        if(name=="undefined")
        {
            name="Not available";
        }
        component.set("v.name", name);
        var address = sessionStorage.getItem('email');
        address = address.replace('"', '');
        address = address.replace('"', '');
        if(address=="undefined")
        {
            address="Not available";
        }
        component.set("v.address", address);
	},
    getdetails : function(component, event, helper) {
        var contactid = sessionStorage.getItem('contactid'); 
        contactid = contactid.replace('"', '');
        contactid = contactid.replace('"', '');
        component.set("v.contactId", contactid);
        console.log('conatc ID is:',contactid)
        var navEvt = $A.get('e.force:navigateToURL');
          navEvt.setParams({url: '/serviceorderhistory'});
          navEvt.fire();
        
    }
})
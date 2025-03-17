({
	doInit : function(component, event, helper) {
        
        
		if(component.get("v.contactId")!=null && component.get("v.contactId")!='')
        {
			helper.getClosedCalls(component, event, helper);
            //helper.getClosedOrders(component, event, helper);
            helper.getOrders(component, event, helper);
            helper.getOpenCalls(component, event, helper);
            
        }
        else if(sessionStorage.getItem('contactid'))
        {
             var contact = sessionStorage.getItem('contactid');
             contact=contact.replace('"', '');
            contact=contact.replace('"', '');
            console.log('inside service order',contact);
                component.set('v.contactId',contact);
            helper.getClosedCalls(component, event, helper);
            //helper.getClosedOrders(component, event, helper);
            helper.getOrders(component, event, helper);
            helper.getOpenCalls(component, event, helper);
            sessionStorage.removeItem('contactid');
            
        }
            else{
                console.log('do nothing');
            }
       
	},
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    openPop : function(component, event, helper) {
       console.log('here');
      
    var cmpTarget = component.find('pop');
    $A.util.addClass(cmpTarget, 'slds-show');
    $A.util.removeClass(cmpTarget, 'slds-hide');

    },
    
    closePop : function(component, event, helper) {
        var cmpTarget = component.find('pop');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-show');
    
    },
    handleMouseOver : function(component,event,helper){
		//console.dir(event.target);
		console.log('q1');
        console.dir(event.target.querySelector('.slds-popover'));
        console.dir(event.target.classList);
        console.log('q2');
        //console.dir(event.target.dataset.index);
        //console.log('index' + event.target.getAttribute("data-index"));
        //var id = "pop" + event.target.dataset.index;
        
        /*
        const cmpTarget = component.find("pop");
        cmpTarget.forEach(t => {
            if(event.target.dataset.index == 3){
                console.log('loop');
                $A.util.addClass(t, 'slds-show');
                $A.util.removeClass(t, 'slds-hide');
            }
        })
        */
        const popOpen = component.get("v.popOpen");
        console.log('popOpen' + popOpen);
        if(popOpen == "True"){
            var items = component.find("pop");
            if(!items.length) items = [items];
            $A.util.addClass(items[parseInt(event.target.dataset.index)],'slds-hide'); 
             component.set('v.popOpen', "False");
             component.set('v.popLabel', "Show Details");
        } else {
             var items = component.find("pop");
          if(!items.length) items = [items];
          $A.util.removeClass(items[parseInt(event.target.dataset.index)],'slds-hide');
          component.set('v.popOpen', "True"); 
          component.set('v.popLabel', "Hide Details");
        }
        
       
       // event.target.classList.add("slds-show");
        //const el = event.target.querySelector('.slds-popover');
        //el.classList.add('slds-show');
        //$A.util.addClass(el, 'slds-show');
        //$A.util.removeClass(cmpTarget, 'slds-hide');
        
       
    },
    handleMouseOut : function(component,event,helper){
    	/*
        const cmpTarget = component.find("pop");
        cmpTarget.forEach(t => {
            if(event.target.dataset.index == 3){
                console.log('loop');
                $A.util.addClass(t, 'slds-hide');
                $A.util.removeClass(t, 'slds-show');
            }
        })
 		*/
 		
 		
        var items = component.find("pop");
          if(!items.length) items = [items];
          $A.util.addClass(items[parseInt(event.target.dataset.index)],'slds-hide');
            }
})
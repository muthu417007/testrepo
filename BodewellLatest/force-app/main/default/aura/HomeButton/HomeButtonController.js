({
	home: function (component, event, helper) {
        
          var navEvt = $A.get('e.force:navigateToURL');
          navEvt.setParams({url: '/'});
          navEvt.fire();
    }
})
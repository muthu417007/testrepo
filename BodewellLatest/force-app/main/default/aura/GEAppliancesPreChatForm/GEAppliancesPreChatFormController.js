({
    /**
     * On initialization of this component, set the prechatFields attribute and render pre-chat fields.
     * 
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
	onRender: function(cmp, evt, hlp) {
		console.log("Here0.5");
        var prechatFields = cmp.find("prechatAPI").getPrechatFields();
		console.log("PrechatFields - " + JSON.stringify(prechatFields));
    },
    
    /**
     * Event which fires when start button is clicked in pre-chat
     *  
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
    handleStartButtonClick: function(component, event, helper) {
		console.log("HERE1"); 
       helper.onStartButtonClick(component, event, helper);
    }
});
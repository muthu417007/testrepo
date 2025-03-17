({
    /**
     * A method that passes the Omni channel events to the omni channel timer component
     * @param {component} component - A component instance
     * @param {event} event - An omni channel event instance
     */
    passOmniChannelEvent : function(component, event, type) {
        const omniTimer = component.find('omniChannelTimer');
        omniTimer.handleOmniChannelEvents(event, type);
    },

    /**
     * A method that passes the window before unload event to the omni channel timer component
     * @param {component} component - A component instance
     * @param {event} event - A before unload event instance
     */
    passClosingInformation : function(component, event) {
        const omniTimer = component.find('omniChannelTimer');
        omniTimer.endCurrentSession();
    },
    
})
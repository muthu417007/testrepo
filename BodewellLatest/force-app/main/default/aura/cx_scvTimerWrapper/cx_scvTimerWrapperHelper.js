({
    /**
     * A method that passes the SCV events to the scvTimer component
     * @param {component} component - A component instance
     * @param {event} event - An SCV event instance
     */
    passScvEvent : function(component, event) {
        const scvTimer = component.find('scvTimer');
        scvTimer.handleScvEvent(event);
    },

    /**
     * A method that passes the tabClosed or window before unload events to the scvTimer component
     * @param {component} component - A component instance
     * @param {event} event - A before unload event instance
     */
    passClosingInformation : function(component, event) {
        const scvTimer = component.find('scvTimer');
        scvTimer.endCurrentSession();
    },
})
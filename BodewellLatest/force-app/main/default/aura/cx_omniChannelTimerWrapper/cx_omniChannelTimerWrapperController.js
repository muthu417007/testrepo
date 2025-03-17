({
    /**
     * An init event handler that adds a listener to window (beforeunload)
     * @param {component} component - A component instance
     * @param {event} event - An event instance
     * @param {helper} helper - A helper instance
     */
    doInit : function(component, event, helper) {
        window.addEventListener('beforeunload', (windowEvent) => { helper.passClosingInformation(component, windowEvent); });
    },

    /**
     * A handler to pass the omni channel status change event to the omni channel timer component
     * @param {component} component - A component instance
     * @param {event} event - An omni channel status changed event instance
     * @param {helper} helper - A helper instance
     */
    onStatusChanged : function(component, event, helper) {
        helper.passOmniChannelEvent(component, event, 'statusChanged');
    }, 

    /**
     * A handler to pass the omni channel logout event to the omni channel timer component
     * @param {component} component - A component instance
     * @param {event} event - An omni channel logout event instance
     * @param {helper} helper - A helper instance
     */
     onLogout : function(component, event, helper) {
        helper.passOmniChannelEvent(component, event, 'logout');
    },
    
})
({
    /**
     * An init event handler that adds listeners to SCV toolkit (CALL_ENDED, HOLD AND RESUME) and window (beforeunload)
     * @param {component} component - A component instance
     * @param {event} event - An event instance
     * @param {helper} helper - A helper instance
     */
    doInit : function(component, event, helper) {
        const voiceToolkit = component.find('voiceToolkitApi');
        voiceToolkit.addTelephonyEventListener('CALL_ENDED', (voiceEvent) => { helper.passScvEvent(component, voiceEvent); });
        voiceToolkit.addTelephonyEventListener('HOLD', (voiceEvent) => { helper.passScvEvent(component, voiceEvent); });
        voiceToolkit.addTelephonyEventListener('RESUME', (voiceEvent) => { helper.passScvEvent(component, voiceEvent); });

        window.addEventListener('beforeunload', (windowEvent) => { helper.passClosingInformation(component, windowEvent); });

        const workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            component.set('v.consoleTabId', tabId);
       });

    },
    
    /**
     * An tab closed event handler that passes the event to a helper method
     * @param {component} component - A component instance
     * @param {event} event - An tab closed event instance
     * @param {helper} helper - A helper instance
     */
    onTabClosed : function(component, event, helper) {
        if(component.get('v.consoleTabId') === event.getParam('tabId')) {
            helper.passClosingInformation(component, event);
        }
    }
})
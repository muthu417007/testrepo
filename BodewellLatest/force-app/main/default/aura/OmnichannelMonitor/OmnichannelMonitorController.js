({
    onStatusChanged: function (component, event, helper) {
        console.log("[EVENT DETECTED] : Status change to " + event.getParam('statusName'));
        const payload = {
            type: 'statuschange',
            statusId : event.getParam('statusId'),
            channels: event.getParam('channels'),
            statusName: event.getParam('statusName'),
            statusApiName: event.getParam('statusApiName')
        }
        helper.publishEvent(component, event, payload);
    },
    onLogout: function (component, event, helper) {
        console.log("[EVENT DETECTED] : Logout.");
        helper.publishEvent(component, event, {
            type: 'logout'
        });
    },
    onLoginSuccess : function(component, event, helper) {
        console.log("[EVENT DETECTED] : Login.");
        helper.publishEvent(component, event, {
            type: 'login'
        });
    },
    handleReceiveMessage: function (component, event, helper) {
        if (event != null) {
            const message = event.getParam('messageBody');
            const source = event.getParam('source');
            
            if (source !== component.get('v.source')) {
                helper.log(component, event, message);
            }
        }
    }
})
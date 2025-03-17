({
	publishEvent: function (component, event, data) {
		let pLoad = data;
		if (pLoad && pLoad.type) {
			switch(pLoad.type){
                case 'login':
                    //do nothing
                    break;
                case 'logout':
                    //do nothing
                    break;
                case 'statuschange':
                    //edit payload and send only status name
					pLoad.payload = data.statusName;
                    break;
                default: //do nothing
                    break;
            }
		}
        const payload = {
            source: component.get('v.source'),
			messageBody: {
				type: pLoad.type,
				payload: pLoad.payload
			}
		};
        //window.setTimeout(
        //    $A.getCallback(function() {
        //        component.find("lmsDemohannel").publish(payload);
        //    }), 2000
        //);
        component.find("lmsDemohannel").publish(payload);
    },
    log: function (component, event, message) {
        console.log('log');
        var _log = component.get("v.log");
        var _entry = {};
        _entry.time = (new Date()).getTime();
        _entry.type = message.type;
        _entry.statusName = message.statusName;
        _log.unshift(_entry);
        component.set("v.log", _log);
        switch (message.type) {
            case 'sync-success':
		        this.setIcon(component, event, true);  
                break;
            case 'sync-failure':
		        this.setIcon(component, event, false);  
                break;
            default:
                //do nothing
        }
    },
    setIcon: function (component, event, success) {
        var utilityAPI = component.find("utilityBarAPI");
        if (success) {
            utilityAPI.setUtilityIcon({
                icon: "success",
                options: {
                    iconVariant: "success"
                }
            });
        }
        else {
            utilityAPI.setUtilityIcon({
                icon: "warning",
                options: {
                    iconVariant: "warning"
                }
            });            
        }
    }
})
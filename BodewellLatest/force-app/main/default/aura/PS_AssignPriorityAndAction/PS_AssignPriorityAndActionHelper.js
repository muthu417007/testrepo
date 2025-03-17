({
    getPicklistValuesHelper: function(component, event) {
        var action = component.get("c.getPriorityActionValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var dualListboxOptionsByFieldName = new Object();
                for(var key in result){
                    var dualListboxOptions = [];
                    for (var valueName in result[key]) {
                        dualListboxOptions.push(
                            {
                                value: valueName,
                                label: result[key][valueName]
                            }
                        );
                    }
                    dualListboxOptionsByFieldName[key] = dualListboxOptions;
                }
                component.set("v.dualListboxOptions", dualListboxOptionsByFieldName);
            }
        });
        $A.enqueueAction(action);
    },

    searchRetailStoresHelper: function(component, event) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.searchRetailStores");
        action.setParams({
            'locationTypes': component.get("v.locationTypesSelected"),
            'customerClasses': component.get("v.customerClassesSelected"),
            'buyingGroups': component.get("v.buyingGroupsSelected"),
            'nationalStoreTypes': component.get("v.nationalStoreTypesSelected"),
            'markets': component.get("v.marketAreaRegionSelected"),
            'commercialConsolidation': component.get("v.commercialConsolidation"),
            'relationshipName': component.get("v.relationshipName"),
            'relationshipRole': component.get("v.relationshipRole"),
            'onlyDs': component.get("v.onlyDs"),
            'oracleAccNumber': component.get("v.OracleAccountNumber"),
            'relationshipType': component.get("v.relationshipType"),
        });

        action.setCallback(this, function(response) {
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();;
                if (storeResponse.length == 0) {
                    toastEvent.setParams({
                        "title": "Note",
                        "type": 'info',
                        "message": "Didn't find any records for given search criteria."
                    });
                    toastEvent.fire();
                } else {
                    if (confirm('Are you sure you want to create ' + storeResponse.length + ' actions?')) {
                        this.createActionsHelper(component,storeResponse);
                } else {
                        return;
                }
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            } else if (state === "INCOMPLETE") {
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "Response is Incompleted."
                });
            } else if (state === "ERROR") {
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error'
                });
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "message": "Error message: " + errors[0].message});
                    }
                } else {
                        toastEvent.setParams({
                            "message": "Uknown error"});
                }
                toastEvent.fire();
         	}
        });
        $A.enqueueAction(action);
    },

    createActionsHelper: function(component, retailIds) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.createActions");

        action.setParams({
            'retailStoreIds': JSON.stringify(retailIds),
            'recordId' : component.get('v.recordId'),
        });

        action.setCallback(this, function(response) {
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                toastEvent.setParams({
                    "title": "Success",
                    "type": 'success',
                    "message": "Created Priority Actions."
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }  else if (state === "ERROR") {
            	toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error'
                });
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "message": "Error message: " + errors[0].message});
                    }
                } else {
                        toastEvent.setParams({
                            "message": "Uknown error"});
                }
                toastEvent.fire();
         	} else {
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "Response is Incompleted."
                });
                toastEvent.fire();
            }
    	});
    	$A.enqueueAction(action);
   },
})
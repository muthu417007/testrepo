({
    init: function (cmp, event, helper) {
        var actions = [
            { label: 'Open Contact/Account', name: 'show_details' }
            //,{ label: 'Create Case', name: 'createCaseFromList' }
            ,{ label: 'Contact Dashboard', name: 'createCaseFromListVF'}
        ],
        fetchData = {
            name : 'name'
            //,
            //author: 'name.findName',
            //published : 'address.state'
        };
        
        var archiveActions = [
            { label: 'Restore', name: 'restore' }
            //,            { label: 'Delete', name: 'delete' }
        ],
        fetchData = {
            name : 'name'
            //,
            //author: 'name.findName',
            //published : 'address.state'
        };

        cmp.set('v.columns', [
            { label: 'Name', fieldName: 'Name', type: 'text',initialWidth: 150  },
            { label: 'Phone', fieldName: 'Phone', type: 'text',initialWidth: 100 },
            { label: 'Email', fieldName: 'Email', type: 'text',initialWidth: 250 },
            { label: 'Street', fieldName: 'MailingStreet', type: 'text',initialWidth: 250 },
            { label: 'Zip', fieldName: 'MailingPostalCode', type: 'text',initialWidth: 75 },
            { type: 'action', typeAttributes: { rowActions: actions },initialWidth: 100 }
        ]);
        
        cmp.set('v.columnsArchive', [
            { label: 'Name', fieldName: 'S_Name__c', type: 'text'  },
            { label: 'Phone', fieldName: 'S_Phone__c', type: 'text' },
            { label: 'Email', fieldName: 'S_Email__c', type: 'text' },
            //{ label: 'Publishing State', fieldName: 'published', type: 'text' },
            { type: 'action', typeAttributes: { rowActions: archiveActions } }
        ]);


        //helper.fetchData(cmp, fetchData, 20);
    },
    "clearSearch" : function(cmp) {
        cmp.set('v.contacts', null);
        cmp.set('v.contactList', null);
        cmp.set('v.firstName', '');
        cmp.set('v.lastName', '');
        cmp.set('v.email', '');
        cmp.set('v.phone', '');
        cmp.set('v.street', '');
        cmp.set('v.zip', '');
    },
    "search" : function(cmp) {
        
        var action = cmp.get("c.getContacts");
        action.setParams({ "fName" : cmp.get("v.firstName"),"lName" : cmp.get("v.lastName"),"iEmail" : cmp.get("v.email"),"iPhone" : cmp.get("v.phone")
                         ,"iStreet" : cmp.get("v.street"),"iZip" : cmp.get("v.zip")});
        //action.setParams({ "lName" : cmp.get("v.lastName") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                let records = response.getReturnValue();
                //alert(records.length + ' id ' + response.getReturnValue()[0].Id );
                //alert( JSON.stringify(response.getReturnValue()) );
                
                /*
                if(records.length == 1){
                    var workspaceAPI = cmp.find("workspace");
                    workspaceAPI.openTab({
                        recordId: response.getReturnValue()[0].Id,
                        focus: true
                    }).then(function(response) {
                        workspaceAPI.getTabInfo({
                            tabId: response
                        }).then(function(tabInfo) {
                            console.log("The url for this tab is: " + tabInfo.url);
                        });
                    })
                    .catch(function(error) {
                        console.log(error);
                    }); 
                    
                    workspaceAPI.openTab({
                        recordId: response.getReturnValue()[0].AccountId,
                        focus: false
                    }).then(function(response) {
                        workspaceAPI.getTabInfo({
                            tabId: response
                        }).then(function(tabInfo) {
                            console.log("The url for this tab is: " + tabInfo.url);
                        });
                    })
                    .catch(function(error) {
                        console.log(error);
                    }); 
    				
                    
                    var utilityAPI = cmp.find("utilitybar");
                    utilityAPI.minimizeUtility();
                    return;
                }
                */
                
                
                
				cmp.set('v.contacts', response.getReturnValue());

                cmp.set('v.contactList', response.getReturnValue());

                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // 
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
        
        var action2 = cmp.get("c.getArchivedContacts");
 
        action2.setParams({ "fName" : cmp.get("v.firstName"),"lName" : cmp.get("v.lastName") });
        //action.setParams({ "lName" : cmp.get("v.lastName") });

        // Create a callback that is executed after 
        // the server-side action returns
        action2.setCallback(this, function(response2) {
            var state2 = response2.getState();
            if (state2 === "SUCCESS") {
				cmp.set('v.archivedContacts', response2.getReturnValue());
                console.dir('return ' +response2.getReturnValue() )
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state2 === "INCOMPLETE") {
                // do something
            }
            else if (state2 === "ERROR") {
                var errors2 = response2.getError();
                if (errors2) {
                    if (errors2[0] && errors2[0].message) {
                        console.log("Error message: " + 
                                 errors2[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // 
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action2);
        
    },

    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'show_details':
                cmp.set('v.contactList', null);
               
                //alert('workspace ' + cmp.find("workspace") + ' recordId ' + row.id + ' row ' + JSON.stringify(row));
				var workspaceAPI = cmp.find("workspace");
                workspaceAPI.openTab({
                    recordId: row.Id,
                    focus: true,
                    title: "Contact Dashboard"
                }).then(function(response) {
                    workspaceAPI.getTabInfo({
                        tabId: response
                    }).then(function(tabInfo) {
                        console.log("The url for this tab is: " + tabInfo.url);
                    });
                })
                .catch(function(error) {
                    console.log(error);
                }); 
                
                
				workspaceAPI.openTab({
                    recordId: row.AccountId,
                    focus: false
                }).then(function(response) {
                    workspaceAPI.getTabInfo({
                        tabId: response
                    }).then(function(tabInfo) {
                        console.log("The url for this tab is: " + tabInfo.url);
                    });
                })
                .catch(function(error) {
                    console.log(error);
                }); 
				
                
                var utilityAPI = cmp.find("utilitybar");
                utilityAPI.minimizeUtility();

                
                /*
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": row.Id,
                  "slideDevName": "related"
                });
    			navEvt.fire();
                */
                break;
            case 'createCaseFromList':
                var evt = $A.get("e.force:navigateToComponent");
                console.log('Event '+evt);
                console.log('row id' + row.Id);
                var contactFromId = row.Id;
                evt.setParams({
                    componentDef : "c:contactDetails",
                    componentAttributes: {
                        contactId : row.Id
                    }
                });
                evt.fire();
                var utilityAPI = cmp.find("utilitybar");
                utilityAPI.minimizeUtility();
                break;
            case 'createCaseFromListVF':
                console.log('row id' + row.Id);
                var contactFromId = row.Id;
                var url = '/apex/contactDashboard?id=' + contactFromId;
                var urlEvent = $A.get("e.force:navigateToURL");
                 alert (url);
                 alert (urlEvent);
                urlEvent.setParams({
                    "url": url,
                    "isredirect": "true"
                });
                urlEvent.fire();
                var utilityAPI = cmp.find("utilitybar");
                utilityAPI.minimizeUtility();
                break;    
            case 'restore':
                // restore response   0036C00000AlCpRQAV
                //Map<string,string> testrun = ceparc.DataArchivaDetailComponentController.unarchive('S_Name_Indexed__c = \'test archive\' and S_HomePhone_Indexed__c  = null and S_Id_Indexed__c = \'0036c00000ajgsuqar\'', 'Contact');
                var action = cmp.get("c.restoreContact");
              
                action.setParams({ "index1" : row.S_Name_Indexed__c,"index2" : row.S_Phone_Indexed__c,"index3" : row.S_Id_Indexed__c });
                //alert(JSON.stringify(row));
                // Create a callback that is executed after 
                // the server-side action returns
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        
                       alert('success restore ' + response.getReturnValue()); 
                        alert(' rec 1 '+ response.getReturnValue()[0]);
                        alert(' rec 2 '+ response.getReturnValue()[1]);
        				
        				/* comment out to navigate to dashboard instead
                        var workspaceAPI = cmp.find("workspace");
                        workspaceAPI.openTab({
                            recordId: response.getReturnValue()[0],
                            focus: true
                        }).then(function(response) {
                            workspaceAPI.getTabInfo({
                                tabId: response
                            }).then(function(tabInfo) {
                                console.log("The url for this tab is: " + tabInfo.url);
                            });
                        })
                        .catch(function(error) {
                            console.log(error);
                        }); 
                        
                        
        				workspaceAPI.openTab({
                            recordId: response.getReturnValue()[1],
                            focus: false
                        }).then(function(response) {
                            workspaceAPI.getTabInfo({
                                tabId: response
                            }).then(function(tabInfo) {
                                console.log("The url for this tab is: " + tabInfo.url);
                            });
                        })
                        .catch(function(error) {
                            console.log(error);
                        }); 
        				
                        */
                        
                        var url = 'apex/contactDashboard?id=' + response.getReturnValue()[0];
                        alert (url);
                        var urlEvent = $A.get("e.force:navigateToURL");
                        alert (urlEvent);
                        urlEvent.setParams({
                            "url": url,
                            "isredirect": "true"
                        });
                        urlEvent.fire();
                        
                        var utilityAPI = cmp.find("utilitybar");
                        utilityAPI.minimizeUtility();
        				
        				
        				
        				
        				//
        				//cmp.set('v.archivedContacts', response.getReturnValue());
                        //console.dir('return ' +response.getReturnValue() )
                        // You would typically fire a event here to trigger 
                        // client-side notification that the server-side 
                        // action is complete
                    }
                    else if (state === "INCOMPLETE") {
                        // do something
                        alert('incomplete');
                    }
                    else if (state === "ERROR") {
                        alert( JSON.stringify(response.getError()));
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                         errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
        
                // optionally set storable, abortable, background flag here
        
                // A client-side action could cause multiple events, 
                // which could trigger other events and 
                // other server-side action calls.
                // 
                // $A.enqueueAction adds the server-side action to the queue.
                $A.enqueueAction(action);
                
                break;
        }
    },
    "createContacts" : function(cmp) {
        let hasErrors = false;
        let errorMessage = '';
        //edit check
        if(cmp.get("v.firstName") ==  null){
            hasErrors = true;
            errorMessage = "First Name Required. \n"
        }
        if(cmp.get("v.lastName") ==  null){
            hasErrors = true;
            errorMessage += "Last Name Required. \n"
        }
        if(cmp.get("v.street") ==  null){
            hasErrors = true;
            errorMessage += "Street Name Required. \n"
        }
        if(cmp.get("v.zip") ==  null){
            hasErrors = true;
            errorMessage += "Zip Code Required. \n"
        }
        if(hasErrors){
        let toastParams = {
             title: "Missing Required Fields",
             message: errorMessage, // Default error message
             type: "error"
            };
           let toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams(toastParams);
           toastEvent.fire();
           return;
        }        
        var action = cmp.get("c.createContact");

        action.setParams({ "fName" : cmp.get("v.firstName"),"lName" : cmp.get("v.lastName"),"iEmail" : cmp.get("v.email"),"iPhone" : cmp.get("v.phone")
                         ,"iStreet" : cmp.get("v.street"),"iZip" : cmp.get("v.zip"),"createCase" : cmp.get("v.createCase")});
         // Create a callback that is executed after 
        // the server-side action returns
 
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {

                //alert( JSON.stringify(response.getReturnValue())); 
                
                    /* commented out logic to and navigate to dashboard instead....
                	var workspaceAPI = cmp.find("workspace");
                    workspaceAPI.openTab({
                        recordId: response.getReturnValue()[0],
                        focus: true
                    }).then(function(response) {
                        workspaceAPI.getTabInfo({
                            tabId: response
                        }).then(function(tabInfo) {
                            console.log("The url for this tab is: " + tabInfo.url);
                        });
                    })
                    .catch(function(error) {
                        console.log(error);
                    }); 
                    
                    workspaceAPI.openTab({
                        recordId: response.getReturnValue()[1],
                        focus: false
                    }).then(function(response) {
                        workspaceAPI.getTabInfo({
                            tabId: response
                        }).then(function(tabInfo) {
                            console.log("The url for this tab is: " + tabInfo.url);
                        });
                    })
                    .catch(function(error) {
                        console.log(error);
                    }); 
                
                    if(cmp.get("v.createCase")){
                     	workspaceAPI.openTab({
                        recordId: response.getReturnValue()[2],
                        focus: true
                    }).then(function(response) {
                        workspaceAPI.getTabInfo({
                            tabId: response
                        }).then(function(tabInfo) {
                            console.log("The url for this tab is: " + tabInfo.url);
                        });
                    })
                    .catch(function(error) {
                        console.log(error);
                    });    
                    }
    				*/
                
                    var url = '/apex/contactDashboard?id=' + response.getReturnValue()[0];
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": url
                    });
                    urlEvent.fire();
                    
                    var utilityAPI = cmp.find("utilitybar");
                    utilityAPI.minimizeUtility();
                    return;
                
   
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                alert( JSON.stringify(response.getError()));
                let toastParams = {
                 title: "Error",
                 message: response.getError(), // Default error message
                 type: "error"
                };
               let toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams(toastParams);
               toastEvent.fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
 
    }
})
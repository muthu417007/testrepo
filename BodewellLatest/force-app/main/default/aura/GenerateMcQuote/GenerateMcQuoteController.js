({    
    navigate  : function(component, event, helper) {
        if(event.getSource().getLocalId() === 'Current_Meet_Comps_Document') {
        	window.open('/apex/PS_CurrentMeetCompsDocument?id=' + component.get('v.recordId') + '&template=' + event.getSource().getLocalId(), '_blank'); 
        } else if (event.getSource().getLocalId() === 'Future_Meet_Comps_Document') {
        	window.open('/apex/PS_CurrentMeetCompsDocument?id=' + component.get('v.recordId') + '&template=' + event.getSource().getLocalId(), '_blank'); 
        } else {
            window.open('/apex/PS_CustomerMeetCompsDocument?id=' + component.get('v.recordId') + '&template=' + event.getSource().getLocalId(), '_blank'); 
        }
    }
})
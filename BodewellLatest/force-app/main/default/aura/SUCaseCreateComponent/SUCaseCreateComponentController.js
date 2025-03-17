({
    doInit: function (component, event, helper) {
        
        helper.doInitilization(component, event, helper);
    },
    handleSaveSuccess: function (component, event, helper) {
        helper.handleSaveSuccess(component, event, helper);
    },
    handleUploadFinished: function (component, event, helper) {
        helper.handleUploadFinished(component, event, helper);
    },
    getResults: function (component, event, helper) {
        helper.getResults(component, event, helper);
    },
    handleOnSubmit: function(component, event, helper){ 
        helper.handleOnSubmit(component, event, helper);
    },
    handleOnLoad: function (component, event, helper) {
        component.set("v.isLoaded", true);
        component.set("v.showSpinner", false);
    },
    handleResolved: function (component, event, helper) {
        helper.handleResolved(component, event, helper);
    },
    handleOpenResults: function (component, event, helper) {
        helper.handleOpenResults(component, event, helper);
    },
    closeModal: function (component, event, helper) {
        component.set('v.ModalOpen', false);
    },
    handleUnResolved: function (component, event, helper) {
        helper.handleUnResolved(component, event, helper);
    },
    redirectCase: function (component, event, helper) {
        window.location.href = component.get("v.caseRedirectUrl")
    },
    handleOnError: function (component, event, helper) {
        component.set("v.showSpinner", false);
    }
})
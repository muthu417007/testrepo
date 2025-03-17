({
    doInit : function(component, event, helper) {
        helper.doInit(component, event);
    },
    handlePayClick : function(component, event, helper) {
        helper.handlePayClick(component, event);
    },
    handleCardTypeChange: function (component, event) {
        component.set("v.selectedCardType", event.getParam("value"));
    },
    handleMonthChange: function (component, event) {
        component.set("v.selectedMonth", event.getParam("value"));
    },
    handleYearChange: function (component, event) {
        component.set("v.selectedYear", event.getParam("value"));
    },
    handleAddressChange: function (component, event) {
        component.set("v.selectedAddress", event.getParam("value"));
    }
})
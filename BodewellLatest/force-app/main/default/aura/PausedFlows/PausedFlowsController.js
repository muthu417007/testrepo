({
  init: function(component, event, helper) {
    helper.refreshFlowList(component);
  },

  resumeFlow: function(component, event, helper) {
    helper.showDialog(component);
    var flow = component.find("flowData");
    var flowId = event.getSource().get("v.value");
    flow.resumeFlow(flowId);
  },

  onFlowStatusChange: function(component, event, helper) {
    console.log(event.getParam("status"));
    if (
      event.getParam("status") === "WAITING" ||
      event.getParam("status") === "FINISHED" ||
      event.getParam("status") === "CLOSED"
    ) {
      setTimeout(function() {
        helper.closeDialog(component);
      }, 1000);
    }
    helper.refreshFlowList(component);
  },

  startNewOnboardingProcess: function(component, event, helper) {
    helper.showDialog(component);
    const flow = component.find("flowData");
    const type = event.getSource().get("v.value");
    component.set("v.flowType", type);
    console.log(type);
    let inputVariables = [{
        name: "flow_type",
        type: "String",
        value: component.get("v.flowType")
    }];
    //flow.startFlow("Account_Onboarding_compon_sai", inputVariables);
    //flow.startFlow("Account_Onboarding_DEV_VERSION_1_4", inputVariables);
    flow.startFlow("Connect_Lead_to_Account_Onboarding", inputVariables);

  }
});
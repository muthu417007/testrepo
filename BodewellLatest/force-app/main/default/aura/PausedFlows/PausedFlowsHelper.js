({
  refreshFlowList: function(component) {
    var action = component.get("c.getPausedInterviews");
    action.setCallback(this, function(response) {
      var interviews = response.getReturnValue();
      if (Array.isArray(interviews) && interviews.length) {
        component.set("v.pausedInterviews", interviews);
        component.set("v.noPausedInterviewsAvailable", false);
      } else {
        component.set("v.noPausedInterviewsAvailable", true);
      }
    });
    $A.enqueueAction(action);
  },
  showDialog: function(component) {
    component.set("v.flowModalOpened", true);
    this.disablePullToRefresh(component);
  },
  closeDialog: function(component) {
    component.set("v.flowModalOpened", false);
    this.reactivatePullToRefresh(component);
  },
  scrollStopPropagation: function(e) {
    e.stopPropagation();
  },
  reactivatePullToRefresh: function(component) {
    var targetEl = component.find("container").getElement();
    targetEl.removeEventListener(
      "touchmove",
      this.scrollStopPropagation,
      true
    );
  },
  disablePullToRefresh: function(component){
    var targetEl = component.find("container").getElement();
    targetEl.addEventListener(
      "touchmove",
      this.scrollStopPropagation,
      true
    );
  },

});
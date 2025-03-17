public class PausedFlowsController {
   @AuraEnabled
   public static List<FlowInterview> getPausedInterviews() {
      String currentUser = UserInfo.getUserId();
      List<FlowInterview> interviews = [SELECT Id, InterviewLabel, PauseLabel, OwnerId, CurrentElement FROM FlowInterview WHERE CreatedById = :currentUser AND InterviewLabel LIKE '%Connect Lead to Onboarding%'];
      
       if (interviews == null || interviews.isEmpty()) {
          return null;
      }
      return interviews;
   }
}
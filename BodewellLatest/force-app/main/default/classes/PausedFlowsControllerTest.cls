@isTest
private class PausedFlowsControllerTest {
    
    @isTest
    private static void getPausedInterviewsTest() {
        List<FlowInterview> interviews = new List<FlowInterview>();
        interviews = PausedFlowsController.getPausedInterviews();
        //System.assertEquals(null, interviews);

    }
}
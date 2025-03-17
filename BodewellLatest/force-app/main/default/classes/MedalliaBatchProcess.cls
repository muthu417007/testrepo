global class MedalliaBatchProcess implements Schedulable{
    /* Execute StartDateDrivenSampling when schedule is triggered */
    public Flow.Interview.MedalliaCaseSurveyBulk DateDrivenSampling {get; set;}
    
    global static void execute(SchedulableContext sc){
        Date d = date.today();
        Flow.Interview.MedalliaCaseSurveyBulk startFlow= new Flow.Interview.MedalliaCaseSurveyBulk(new Map<String, Object>());
        startFlow.start();
    }
}
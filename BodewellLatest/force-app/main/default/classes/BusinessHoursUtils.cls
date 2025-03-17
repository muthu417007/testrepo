public class BusinessHoursUtils {

    public class BHResponse {
        @InvocableVariable(required=true)
        public Boolean isOutsideWorkingTime;
    }
    
    @InvocableMethod(label='Is Outside Working Time')
    public static List<BHResponse> checkIfIsOutsideWorkingTime() {

        BusinessHours bh = getBusinessHoursForBot();
        Datetime targetTime = Datetime.now();
        
        List<BHResponse> bhResponseList = new List<BHResponse>();
        
        BHResponse bhResp = new BHResponse();
        bhResp.isOutsideWorkingTime = !BusinessHours.isWithin(bh.id, targetTime);

        bhResponseList.add(bhResp);

        return bhResponseList;
    }

    public static BusinessHours getBusinessHoursForBot(){
        return [SELECT Id FROM BusinessHours WHERE Name='AutoresponderBusinessHours'];
    }
}
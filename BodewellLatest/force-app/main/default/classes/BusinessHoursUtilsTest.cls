@IsTest
public class BusinessHoursUtilsTest {

    @IsTest
    public static void testIsOutsideWorkingHours(){

        BusinessHours bh = BusinessHoursUtils.getBusinessHoursForBot();
        Datetime targetTime = Datetime.now();

        List<BusinessHoursUtils.BHResponse> bhResp = BusinessHoursUtils.checkIfIsOutsideWorkingTime();

        System.assertEquals(bhResp.get(0).isOutsideWorkingTime,!BusinessHours.isWithin(bh.id, targetTime));
    }
    
}
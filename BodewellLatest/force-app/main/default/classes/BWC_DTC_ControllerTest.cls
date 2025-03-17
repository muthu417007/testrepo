@isTest
public class BWC_DTC_ControllerTest {
    @isTest
    static void getDTC_dataTestMethod() {
        test.startTest();
        BWC_DTC_Controller.getDTC_data('test','40222');
        test.stopTest();
    }
}
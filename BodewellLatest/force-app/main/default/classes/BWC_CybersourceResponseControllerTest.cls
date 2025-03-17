@IsTest
public class BWC_CybersourceResponseControllerTest {
    static testMethod void test() {
        PageReference myVfPage = Page.BWC_CybersourceResponse;
        Test.setCurrentPage(myVfPage);

        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('req_merchant_defined_data3','01234567');
        ApexPages.currentPage().getParameters().put('req_merchant_defined_data4','6543211');
        ApexPages.currentPage().getParameters().put('payment_token','1234567890123456');
        ApexPages.currentPage().getParameters().put('reason_code','100');

        BWC_CybersourceResponseController pc = new BWC_CybersourceResponseController();
        pageReference p1 = pc.init();
        System.assertNotEquals(null, pc.paramsJson);
    }
}
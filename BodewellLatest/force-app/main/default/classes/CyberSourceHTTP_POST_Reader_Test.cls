@isTest
public class CyberSourceHTTP_POST_Reader_Test {
    static testMethod void test() {
        PageReference myVfPage = Page.Cybersource_Response;
        Test.setCurrentPage(myVfPage);
    
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('req_merchant_defined_data3','01234567');
        ApexPages.currentPage().getParameters().put('req_merchant_defined_data4','6543211');
        ApexPages.currentPage().getParameters().put('payment_token','1234567890123456');
        ApexPages.currentPage().getParameters().put('reason_code','100');
        
        CyberSource_HTTP_POST_Reader pc = new CyberSource_HTTP_POST_Reader();
        pageReference p1 = pc.init();
    }
}
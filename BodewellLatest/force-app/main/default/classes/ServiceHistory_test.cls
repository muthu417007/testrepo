@isTest
public class ServiceHistory_test {

    static testMethod void test1() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        ServiceHistory controller = new ServiceHistory();
        searchIdResponse resp1 = ServiceHistory.get360Orders(c.id);
        //PageReference p1 = controller.contactDashboard();
        Test.stopTest();
    }
    
    static testMethod void testfetchConsumerNumbers() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        String result = serviceHistory.fetchConsumerNumbers(c.id);
        Test.stopTest();
    }
    
    static testMethod void testclosedCallsDetailsResponse() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        closedCallsDetailsResponse result = serviceHistory.closedCalls(c.id);
        Test.stopTest();
    }
    
    static testMethod void testopenCallsDetailsResponse() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        openCallsDetailsResponse result = serviceHistory.openCalls(c.id);
        Test.stopTest();
    }  
        
    static testMethod void testserviceOrderDetails() {
    	List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        serviceOrderDetailResponse result = serviceHistory.serviceOrderDetails(c.id);
        Test.stopTest();
    }
}
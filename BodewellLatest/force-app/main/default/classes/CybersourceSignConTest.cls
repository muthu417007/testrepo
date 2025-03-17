@IsTest
private class CybersourceSignConTest {
    static testMethod void test1(){
    	// Perform test
        Test.startTest();
        Concession__c c = testDataFactory.createConcession();
        
        ApexPages.StandardController stdConcession = new ApexPages.StandardController(c);
        CybersourceSignCon controller = new CybersourceSignCon(stdConcession);
        String testResult = controller.getParametersValues();
        PageReference p1 = controller.doBuild();
        PageReference p2 = controller.setVisible();
        Test.stopTest();        
    }
    
    
}
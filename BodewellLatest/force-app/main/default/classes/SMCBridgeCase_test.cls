@isTest 
private class SMCBridgeCase_test {
    static testMethod void test1() {
 
        // Perform test
        Test.startTest();
        Concession__c c = testDataFactory.createConcession();
        Case caseRec = [SELECT id
                       FROM Case
                       WHERE id = : c.Case__c LIMIT 1];
        ApexPages.StandardController stdCase = new ApexPages.StandardController(caseRec);
        SMCBridgeCase controller = new SMCBridgeCase(stdCase);
        PageReference p1 = controller.redirect();
        Test.stopTest();
        
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
}
@isTest 
private class SMCBridgeConcession_test {
    static testMethod void test1() {
 
        // Perform test
        Test.startTest();
        Concession__c c = testDataFactory.createConcession();
        c.No_Charge_Service__c = 'Yes';
        update c;
        ApexPages.StandardController stdConcession = new ApexPages.StandardController(c);
        SMCBridgeConcession controller = new SMCBridgeConcession(stdConcession);
        PageReference p1 = controller.redirect();
        Test.stopTest();
        
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }
    static testMethod void test2() {
 
        // Perform test
        Test.startTest();
        Concession__c c = testDataFactory.createConcession();
        
        update c;
        ApexPages.StandardController stdConcession = new ApexPages.StandardController(c);
        SMCBridgeConcession controller = new SMCBridgeConcession(stdConcession);
        PageReference p1 = controller.redirect();
        Test.stopTest();
        
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }  
        
    static testMethod void test3() {
 
        // Perform test
        Test.startTest();
        Concession__c c = testDataFactory.createConcession();
        c.Waive_Home_Call__c = 'No';
        c.No_Charge_Service__c = 'No';
        c.Percent_Labor_Covered__c = '25%';
        update c;
        ApexPages.StandardController stdConcession = new ApexPages.StandardController(c);
        SMCBridgeConcession controller = new SMCBridgeConcession(stdConcession);
        PageReference p1 = controller.redirect();
        Test.stopTest();
        
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    } 
    
    static testMethod void test4() {
 
        // Perform test
        Test.startTest();
        Concession__c c = testDataFactory.createConcession();
        c.Waive_Home_Call__c = 'Yes';
        c.No_Charge_Service__c = 'No';
        c.Percent_Labor_Covered__c = '25%';
        update c;
        ApexPages.StandardController stdConcession = new ApexPages.StandardController(c);
        SMCBridgeConcession controller = new SMCBridgeConcession(stdConcession);
        PageReference p1 = controller.redirect();
        Test.stopTest();
        
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    } 
    
    static testMethod void test5() {
 
        // Perform test
        Test.startTest();
        Concession__c c = testDataFactory.createConcession();
        c.Waive_Home_Call__c = 'Yes';
        c.No_Charge_Service__c = 'No';
        
        update c;
        ApexPages.StandardController stdConcession = new ApexPages.StandardController(c);
        SMCBridgeConcession controller = new SMCBridgeConcession(stdConcession);
        PageReference p1 = controller.redirect();
        Test.stopTest();
        
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    } 
    
    static testMethod void test6() {
 
        // Perform test
        Test.startTest();
        Concession__c c = testDataFactory.createConcession();
        c.Waive_Home_Call__c = 'No';
        c.No_Charge_Service__c = 'No';
        c.Percent_Labor_Covered__c = '25%';
        c.Percent_Parts_Covered__c = '25%';
        update c;
        ApexPages.StandardController stdConcession = new ApexPages.StandardController(c);
        SMCBridgeConcession controller = new SMCBridgeConcession(stdConcession);
        PageReference p1 = controller.redirect();
        Test.stopTest();
        
        // Test that the trigger correctly updated the price
        //System.assertEquals(30, test[0]);
    }   
                
    
}
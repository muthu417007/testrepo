@isTest 
private class ConcessionProrate_test {
    static testMethod void test1() {
        Prorate_Calculator__c pc = new Prorate_Calculator__c();
        pc.Billing_Postal_Code__c = '40204';
        pc.Billing_City__c = 'LOUISVILLE';
        pc.Billing_State__c = 'KY';
        pc.Prorate_Price__c = 500.00;
        List<Prorate_Calculator__c> pcList = new List<Prorate_Calculator__c>();
        pcList.add(pc);
        List<Double> test = ConcessionProrate.calculateTax(pcList);
        system.debug(test);
        
        // Test that the trigger correctly updated the price
        System.assertEquals(30, test[0]);
    }
}
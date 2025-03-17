@isTest 
private class ConcessionDelivery_test {
    static testMethod void test1() {
        Prorate_Calculator__c pc = new Prorate_Calculator__c();
        pc.Billing_Postal_Code__c = '40204';
        pc.Billing_City__c = 'LOUISVILLE';
        pc.Billing_State__c = 'KY';
        pc.Prorate_Price__c = 500.00;
        List<Prorate_Calculator__c> pcList = new List<Prorate_Calculator__c>();
        pcList.add(pc);
        List<Double> test = ConcessionDelivery.calculateTax(pcList);
        system.debug(test);
        
        // Test tax is returned
        System.assertEquals(30, test[0]);
    }
}
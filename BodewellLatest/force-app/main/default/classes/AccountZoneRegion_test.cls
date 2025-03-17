@isTest 
private class AccountZoneRegion_test {
    static testMethod void test1() {
        account a = new account();
        a.BillingPostalCode = '40225';
        List<account> alist = new List<account>();
        alist.add(a);
        List<Account> test = AccountZoneRegion.getZoneRegion(alist);
        system.debug(test);
        
        // Test tax is returned
        System.assertEquals('57', test[0].Zone__c );
    }
}
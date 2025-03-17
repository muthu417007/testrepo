@isTest 
private class AccountZone_test {
    static testMethod void test1() {
        String zip = '40225';
        List<String> alist = new List<String>();
        alist.add(zip);
        List<String> test = AccountZone.getZone(alist);
        system.debug(test);
        
        // Test tax is returned
        System.assertEquals('57', test[0] );
    }
}
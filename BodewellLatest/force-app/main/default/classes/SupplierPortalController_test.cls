@isTest 
private class SupplierPortalController_test {
    static testMethod void test1() {
        SupplierPortalController pc = new SupplierPortalController ();
        pc.username = 'test';
        pc.password = 'test';
        pageReference p1 = pc.login();
    }
}
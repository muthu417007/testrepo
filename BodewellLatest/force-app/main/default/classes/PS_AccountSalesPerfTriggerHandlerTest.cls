@isTest
private class PS_AccountSalesPerfTriggerHandlerTest {

    @isTest
    static void coverMethodsNotUsedInTrigger () {
        new PS_AccountSalesPerformanceTriggerHandler().beforeInsert(null);
        new PS_AccountSalesPerformanceTriggerHandler().beforeUpdate(null, null);
        new PS_AccountSalesPerformanceTriggerHandler().beforeDelete(null);
        new PS_AccountSalesPerformanceTriggerHandler().afterDelete(null);
        new PS_AccountSalesPerformanceTriggerHandler().afterUpdate(null, null);
    }
}
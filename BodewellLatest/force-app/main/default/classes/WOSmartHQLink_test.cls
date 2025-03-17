@isTest(SeeAllData=true)
public class WOSmartHQLink_test {
	@isTest(SeeAllData=true)
    private static void getNewFIURL_test() {
        Test.startTest();
        WorkOrder wo = new WorkOrder( subject = 'test case');
        insert wo;
		WorkOrderLineItem woli = new WorkOrderLineItem( subject = 'test case', WorkOrderId  = wo.Id );
        insert woli;
        WorkOrderLineItem wolirec = [SELECT Id,Subject FROM WorkOrderLineItem where Id =: woli.Id];
        WOSmartHQLink.getNewFIURL(wolirec.Id);
        Test.stopTest();
    }
}
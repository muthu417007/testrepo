public class WOSmartHQLink {
	@AuraEnabled
	public static List<WorkOrderLineItem> getNewFIURL(Id recordId) {
   		return [SELECT Id, NewFI_Redirect_URL__c FROM WorkOrderLineItem WHERE Id = :recordId];
	}
}
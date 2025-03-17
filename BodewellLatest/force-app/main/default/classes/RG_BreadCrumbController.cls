/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        22.03.2023
 * @description    For getting navigation menu links
 */
public class RG_BreadCrumbController {
	@AuraEnabled(cacheable=true)
    public static RG_RequestResponse getBreadCrumbs()
    {
        RG_RequestResponse response = new RG_RequestResponse();
        List<RG_Repair__mdt> breadCrumbs = New List<RG_Repair__mdt>();
        if(Schema.sObjectType.RG_Repair__mdt.fields.Id.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Label.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Page_API_Name__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Parent__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Url__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.IsLabelVisible__c.isAccessible())
        {
            breadCrumbs = [SELECT Id, Label, Page_API_Name__c, Parent__c, Url__c, IsLabelVisible__c
                            FROM RG_Repair__mdt WHERE Page_API_Name__c != ''
                            ORDER BY Label];
            response.success = true;
            response.result = breadCrumbs;
        }
        return response;   
    }
}
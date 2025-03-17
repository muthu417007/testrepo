@isTest
public class PS_MeetCompPdfGenerator_test {
    @testSetup
    static void setup() {
        PS_MeetComp_TriggerHandler.TriggerDisabled =  true;
        Meet_Comp__c[] meetComps = new List<Meet_Comp__c>();
        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;

        Contact cnt = new Contact(
            FirstName = 'testFirstName1',
            LastName = 'testLastName1',
            AccountId = acc1.id);

        insert cnt;

        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
        Product2 prod2 = new Product2(Name = 'Product 2', Family = 'Hardware', Item_Number__c = '2');
        insert new List<Product2> {prod1, prod2};

        for (integer i = 0; i < 2; i ++) {
			meetComps.add(new Meet_Comp__c(
          	GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
          	Account__c = acc1.Id,
          	Competitive_Inventory_Financing_pct__c = 5,
          	Competitive_Invoice_Price__c = 2,
          	Competitive_Other_Backside_pct__c = 5,
          	Competitive_Price_Promotional_Diff__c = 5,
          	Competitive_Sales_Campaigns_Promos__c = 5,
          	Competitive_Volume_Rebate_PIF__c =  5,
          	Contact_Name__c = cnt.Id,
          	Date_Competitive_Data_Received__c = Date.today().addDays(-3),
          	GEA_Inventory_Financing__c = 5,
          	GEA_Meet_Comp_Price__c = 5,
          	GEA_Other_Backside__c = 5,
          	GEA_Price_Promotional_Difference_PPD__c = 5,
          	GEA_Sales_Campaigns_and_Promotions__c = 5,
          	GEA_Volume_Rebate_PIF__c = 5,
			Stage_Name__c = 'Approved'
        	));
        }
        meetComps[0].MC_Type__c = 'MC';
        meetComps[0].Effective_Date__c = Date.today();
        meetComps[0].Termination_Date__c =  Date.today().addDays(2);
        meetComps[0].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(3);
        meetComps[0].GEA_Model__c = prod1.Id;

        meetComps[1].MC_Type__c = 'Promotional MC';
        meetComps[1].Effective_Date__c =  Date.today().addDays(1);
        meetComps[1].Termination_Date__c =  Date.today().addDays(2);
        meetComps[1].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(2);
        meetComps[1].GEA_Model__c = prod2.Id;

        insert meetComps;
    }

    static testMethod void constructor_shouldPullRelatedMeetComps () {
        //GIVEN
        Account ac = [SELECT Id FROM Account];
        ApexPages.StandardController stdController = new ApexPages.StandardController(ac);
        System.currentPageReference().getParameters().put('id', ac.Id);
        
        //WHEN
        System.currentPageReference().getParameters().put('template', 'Current_Meet_Comps_Document');
        PS_MeetCompPdfGenerator_ctrl ctrl = new PS_MeetCompPdfGenerator_ctrl(stdController);
        
        //THEN
        System.assertEquals(1, ctrl.meetComps.size());

        //WHEN
        System.currentPageReference().getParameters().put('template', 'Future_Meet_Comps_Document');
        ctrl = new PS_MeetCompPdfGenerator_ctrl(stdController);
        
        //THEN
        System.assertEquals(1, ctrl.meetComps.size());
        
        //WHEN
        System.currentPageReference().getParameters().put('template', 'Customer_Meet_Comps_Document');
        ctrl = new PS_MeetCompPdfGenerator_ctrl(stdController);
        
        //THEN
        System.assertEquals(2, ctrl.meetComps.size());
    }
}
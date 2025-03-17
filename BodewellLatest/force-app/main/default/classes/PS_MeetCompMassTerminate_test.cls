@isTest
public class PS_MeetCompMassTerminate_test {

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
        
        Contact cnt2 = new Contact(
            FirstName = 'testFirstName2',
            LastName = 'testLastName2',
            AccountId = acc1.id);
        
        insert new List<Contact> {cnt, cnt2};
        
        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
    	Product2 prod2 = new Product2(Name = 'Product 2', Family = 'Hardware', Item_Number__c = '2');
        insert new List<Product2>{prod1, prod2};
        
        for(integer i = 0; i < 4; i ++) {
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
              	GEA_Volume_Rebate_PIF__c = 5
            ));
        }
        
        meetComps[0].MC_Type__c = 'MC';
		meetComps[0].Effective_Date__c =  Date.today().addDays(1);
		meetComps[0].Termination_Date__c =  Date.today().addDays(2);
        meetComps[0].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(3);
        meetComps[0].GEA_Model__c = prod1.Id;
        meetComps[0].Transferred_to_Oracle__c = true;
        meetComps[0].Legacy_Approver__c = 'mc1';
        
        meetComps[1].MC_Type__c = 'Promotional MC';
		meetComps[1].Effective_Date__c =  Date.today().addDays(1);
		meetComps[1].Termination_Date__c =  Date.today().addDays(2);
        meetComps[1].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(2);
        meetComps[1].GEA_Model__c = prod2.Id;
        meetComps[1].Transferred_to_Oracle__c = false;
        meetComps[1].Legacy_Approver__c = 'mc2';

        meetComps[2].MC_Type__c = 'Net/Net MC';
		meetComps[2].Effective_Date__c =  Date.today();
		meetComps[2].Termination_Date__c =  Date.today().addDays(2);
        meetComps[2].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(2);
        meetComps[2].GEA_Model__c = prod2.Id;
        meetComps[2].Transferred_to_Oracle__c = false;
        meetComps[2].Legacy_Approver__c = 'mc3'; 
        
        meetComps[3].MC_Type__c = 'Promotional MC';
		meetComps[3].Effective_Date__c =  Date.today();
		meetComps[3].Termination_Date__c =  Date.today();
        meetComps[3].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(2);
        meetComps[3].GEA_Model__c = prod1.Id;
        meetComps[3].Transferred_to_Oracle__c = true;
        meetComps[3].Legacy_Approver__c = 'mc4'; 
        insert meetComps;
    }

    static testMethod void terminateMeetComps_shouldTerminateMeetComps () {
        //GIVEN
        Meet_Comp__c[] meetComps = [SELECT Transferred_to_Oracle__c, GEA_Prior_Invoice_Price__c, MC_Type__c, Competitive_Invoice_Price__c, GEA_Meet_Comp_Price__c, Name, Contact_Name__c, Termination_Date_of_Competitive_Data__c, Redoced__c,
        	Effective_Date__c, Termination_Date__c, Date_Competitive_Data_Received__c, GEA_Individual_who_received_the_data__c
            FROM Meet_Comp__c];
        
        Test.setCurrentPage(Page.PS_MeetCompMassTerminate);
 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(meetComps);
        stdSetController.setSelected(meetComps);
        PS_MeetCompMassTerminate_ctrl ctrl = new PS_MeetCompMassTerminate_ctrl(stdSetController);

        //WHEN
		ctrl.terminateMeetComps();
        
        //THEN
 		Meet_Comp__c mc1 = [SELECT Stage_Name__c, Operator__c FROM Meet_Comp__c WHERE Legacy_Approver__c = 'mc1'];
        System.assertEquals('Deleted', mc1.Stage_Name__c, 
        	'Should update Stage_Name__c of mc when effective date > today and Transferred_to_Oracle__c = true');
        System.assertEquals('Delete', mc1.Operator__c,
        	'Should update Operator__c of mc when effective date > today and Transferred_to_Oracle__c = true');
		
 		Meet_Comp__c mc4 = [SELECT Stage_Name__c, Operator__c FROM Meet_Comp__c WHERE Legacy_Approver__c = 'mc4'];
        System.assertEquals('Approved', mc4.Stage_Name__c, 
        	'Should update Stage_Name__c of mc when mc.Effective_Date__c <= today && mc.Termination_Date__c >= today and Transferred_to_Oracle__c = true');
        System.assertEquals('Update', mc4.Operator__c,
        	'Should update Operator__c of mc when mc.Effective_Date__c <= today && mc.Termination_Date__c >= today and Transferred_to_Oracle__c = true');
        
        System.assertEquals(0, [SELECT Count() FROM Meet_Comp__c WHERE Legacy_Approver__c = 'mc2'],
        	'Should delete mc with effective date > today and Transferred_to_Oracle__c = false');
 
        System.assertEquals(0, [SELECT Count() FROM Meet_Comp__c WHERE Legacy_Approver__c = 'mc3'],
        	'Should delete mc with effective date <= today, temrination date >= today and Transferred_to_Oracle__c = false'); 
    }

    static testMethod void terminateMeetComps_shouldThrowError () {
        //GIVEN
        Meet_Comp__c[] meetComps = [SELECT Transferred_to_Oracle__c, GEA_Prior_Invoice_Price__c, MC_Type__c, Competitive_Invoice_Price__c, GEA_Meet_Comp_Price__c, Name, Contact_Name__c, Termination_Date_of_Competitive_Data__c, Redoced__c,
        	Effective_Date__c, Termination_Date__c, Date_Competitive_Data_Received__c, GEA_Individual_who_received_the_data__c
            FROM Meet_Comp__c WHERE Legacy_Approver__c = 'mc4'];
    
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
        req.setComments('Bulk Submitted by' + userInfo.getName()); 
        req.setObjectId(meetComps[0].Id); 

        Approval.ProcessResult[] processResults = Approval.process(new List<Approval.ProcessSubmitRequest> {req});
        Test.setCurrentPage(Page.PS_MeetCompMassTerminate);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(meetComps);
        stdSetController.setSelected(meetComps);
        PS_MeetCompMassTerminate_ctrl ctrl = new PS_MeetCompMassTerminate_ctrl(stdSetController);

        //WHEN
		ctrl.terminateMeetComps();
        
        //THEN
        System.assertEquals('None of the selected records are valid for termination.', ctrl.submitResultMsg);
    }
}
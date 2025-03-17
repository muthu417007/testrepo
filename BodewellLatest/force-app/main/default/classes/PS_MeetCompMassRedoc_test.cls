@isTest
public class PS_MeetCompMassRedoc_test {

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
        
        for(integer i = 0; i < 2; i ++) {
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
        
        meetComps[1].MC_Type__c = 'Promotional MC';
		meetComps[1].Effective_Date__c =  Date.today().addDays(1);
		meetComps[1].Termination_Date__c =  Date.today().addDays(2);
        meetComps[1].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(2);
        meetComps[1].GEA_Model__c = prod2.Id;
        
        insert meetComps;
    }

    static testMethod void saveRecords_shouldCloneMeetCompsWithInputFields () {
        //GIVEN
        Meet_Comp__c[] meetComps = [SELECT GEA_Prior_Invoice_Price__c, MC_Type__c, Competitive_Invoice_Price__c, GEA_Meet_Comp_Price__c, Name, Contact_Name__c, Termination_Date_of_Competitive_Data__c, Redoced__c,
        	Effective_Date__c, Termination_Date__c, Date_Competitive_Data_Received__c, GEA_Individual_who_received_the_data__c
            FROM Meet_Comp__c WHERE MC_Type__c IN ('MC', 'Promotional MC')];
        Test.setCurrentPage(Page.PS_MeetCompMassRedoc);
        Contact cnt2 = [SELECT Id FROM Contact WHERE LastName = 'testLastName2'];
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(meetComps);
        stdSetController.setSelected(meetComps);
        PS_MeetCompMassRedoc_ctrl ctrl = new PS_MeetCompMassRedoc_ctrl(stdSetController);

        //WHEN
        ctrl.mcInput.Effective_Date__c = System.today().addDays(8);
        ctrl.mcInput.Termination_Date_of_Competitive_Data__c = System.today().addDays(9);
        ctrl.mcInput.Termination_Date__c = System.today().addDays(10);
        ctrl.mcInput.Contact_Name__c = cnt2.Id;
        
        for (Meet_Comp__c mc : (List<Meet_Comp__c>)stdSetController.getSelected()) {
        	mc.GEA_Meet_Comp_Price__c = 47;
            mc.Competitive_Invoice_Price__c = 6;
        }
        
		ctrl.saveRecords();
        
        //THEN
        Set<Id> oldMcIds = new Set<Id>();
        Meet_Comp__c mcMeetComp;
        Meet_Comp__c promotionalMeetComp;
        for(Meet_Comp__c mc : meetComps) {
            oldMcIds.add(mc.Id);
            if (mc.MC_Type__c == 'MC') {
                mcMeetComp = mc;
            } else if (mc.MC_Type__c == 'Promotional MC') {
                promotionalMeetComp = mc;
            }
        }

        for (Meet_Comp__c mc : [SELECT Redoced__c FROM Meet_Comp__c WHERE Id IN :oldMcIds]) {
            System.assertEquals(false, mc.Redoced__c, 'Should update old meet docs with Redoced = true');
        }
        
        Meet_Comp__c[] clonedMcs = [SELECT Originating_Meet_Comp__c, GEA_Meet_Comp_Price__c, Operator__c, Stage_Name__c, MC_Type__c, GEA_Prior_Invoice_Price__c, 
                                    Created_by_Redoc__c, Effective_Date__c, Termination_Date__c, Contact_Name__c, Competitive_Invoice_Price__c 
                                    FROM Meet_Comp__c WHERE Id NOT IN :oldMcIds];
        System.assertEquals(0, clonedMcs.size(), 'Should clone all of the selected meet comp records');
                                    
        for (Meet_Comp__c mc : clonedMcs) {
            System.assertEquals(true, mc.Created_by_Redoc__c, 'Should populate Created_by_Redoc__c field with true value');
            System.assertEquals(Date.today().addDays(8), mc.Effective_Date__c, 
            	'Should populate Effective_Date__c with input value');
            System.assertEquals(cnt2.Id, mc.Contact_Name__c, 
            	'Should populate Contact Name with input value.');
			System.assertEquals('Draft', mc.Stage_Name__c, 
            	'Should populate Stage_Name__c with hardcoded value');            
			System.assertEquals('Insert', mc.Operator__c, 
            	'Should populate Operator__c with hardcoded value');
			System.assertEquals(47, mc.GEA_Meet_Comp_Price__c, 
            	'Should populate GEA_Meet_Comp_Price__c with input value');           
			System.assertEquals(6, mc.Competitive_Invoice_Price__c, 
            	'Should populate GEA_Meet_Comp_Price__c with input value');               
            
            if(mc.MC_Type__c == 'MC') {
           		System.assertEquals(mcMeetComp.Id, mc.Originating_Meet_Comp__c, 
            		'Should populate Originating_Meet_Comp__c with original MeetComp Id');       
            } else if (mc.MC_Type__c == 'Promotional MC') {
             	System.assertEquals(promotionalMeetComp.Id, mc.Originating_Meet_Comp__c, 
            		'Should populate Originating_Meet_Comp__c with original MeetComp Id');               
            }
        }
    }

    static testMethod void saveRecords_shouldCloneMeetCompsWithoutInputFields () {
        //GIVEN
        Meet_Comp__c[] meetComps = [SELECT GEA_Model__c, GEA_Prior_Invoice_Price__c, MC_Type__c, Competitive_Invoice_Price__c, GEA_Meet_Comp_Price__c, Name, Contact_Name__c, Termination_Date_of_Competitive_Data__c, Redoced__c,
        	Effective_Date__c, Termination_Date__c, Date_Competitive_Data_Received__c, GEA_Individual_who_received_the_data__c
            FROM Meet_Comp__c WHERE MC_Type__c = 'MC'];
        Test.setCurrentPage(Page.PS_MeetCompMassRedoc);
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(meetComps);
        stdSetController.setSelected(meetComps);
        PS_MeetCompMassRedoc_ctrl ctrl = new PS_MeetCompMassRedoc_ctrl(stdSetController);

        //WHEN
        ctrl.mcInput.Termination_Date_of_Competitive_Data__c = System.today().addDays(9);
        ctrl.mcInput.Termination_Date__c = System.today().addDays(10);
		ctrl.saveRecords();
        
        //THEN

        for (Meet_Comp__c mc : [SELECT Redoced__c FROM Meet_Comp__c WHERE Id = :meetComps[0].Id]) {
            System.assertEquals(false, mc.Redoced__c, 'Should update old meet docs with Redoced = true');
        }
        
        Meet_Comp__c[] clonedMcs = [SELECT Originating_Meet_Comp__c, GEA_Meet_Comp_Price__c, Operator__c, Stage_Name__c, MC_Type__c, GEA_Prior_Invoice_Price__c, 
                                    Created_by_Redoc__c, Effective_Date__c, Termination_Date__c, Contact_Name__c, Competitive_Invoice_Price__c 
                                    FROM Meet_Comp__c WHERE Id  != :meetComps[0].Id AND MC_Type__c = 'MC'];
        System.assertEquals(0, clonedMcs.size(), 'Should clone all of the selected meet comp records');
                                    
        for (Meet_Comp__c mc : clonedMcs) {
            System.assertEquals(true, mc.Created_by_Redoc__c, 'Should populate Created_by_Redoc__c field with true value');
            System.assertEquals(Date.today().addDays(3), mc.Effective_Date__c, 
            	'Should populate Effective_Date__c with old Mc termination Date + 1 day if user input for Effective Date = null.');
            System.assertEquals(meetComps[0].Contact_Name__c, mc.Contact_Name__c, 
            	'Should populate Contact Name with Conact_Name__c of clonned records.');
			System.assertEquals('Draft', mc.Stage_Name__c, 
            	'Should populate Stage_Name__c with hardcoded value');            
			System.assertEquals('Insert', mc.Operator__c, 
            	'Should populate Operator__c with hardcoded value');
			System.assertEquals(5, mc.GEA_Meet_Comp_Price__c, 
            	'Should populate GEA_Meet_Comp_Price__c with value from original record');           
			System.assertEquals(2, mc.Competitive_Invoice_Price__c, 
            	'Should populate GEA_Meet_Comp_Price__c with value from original record');
            System.assertEquals(meetComps[0].Id, mc.Originating_Meet_Comp__c, 
            		'Should populate Originating_Meet_Comp__c with original MeetComp Id');       
            
        }
    }

    @isTest
    static void shoulCheckMeetCompsWhenTheyAreEligible() {
        Account acc = [SELECT Id FROM Account][0];
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = 'testLastName1'];
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];

        List<Meet_Comp__c> meetComps = new List<Meet_Comp__c>();
        meetComps.add(
            new Meet_Comp__c(
                GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                Account__c = acc.Id,
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
                MC_Type__c = 'MC',
                Effective_Date__c =  Date.today().addDays(5),
                Termination_Date__c =  Date.today().addDays(6),
                Termination_Date_of_Competitive_Data__c =  Date.today().addDays(7),
                GEA_Model__c = prod1.Id,
                Stage_Name__c = 'Approved',
                Redoced__c = false
            )
        );
        meetComps.add(
            new Meet_Comp__c(
                GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                Account__c = acc.Id,
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
                MC_Type__c = 'Promotional MC',
                Effective_Date__c =  Date.today().addDays(29),
                Termination_Date__c =  Date.today().addDays(30),
                Termination_Date_of_Competitive_Data__c =  Date.today().addDays(31),
                GEA_Model__c = prod2.Id,
                Stage_Name__c = 'Approved and Transferred',
                Redoced__c = false
            )
        );

        insert meetComps;

        Set<Id> meetCompsIds = new Set<Id>();

        for (Meet_Comp__c mc : meetComps) {
            meetCompsIds.add(mc.Id);
        }

        PS_MeetCompMassRedoc_ctrl ctrl = new PS_MeetCompMassRedoc_ctrl();
        System.assertEquals(true, ctrl.isMeetCompsEligible(meetCompsIds));
    }

    @isTest
    static void shoulCheckMeetCompsWhenTheyAreNotEligibleByTerminationDate() {
        Account acc = [SELECT Id FROM Account][0];
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = 'testLastName1'];
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];

        List<Meet_Comp__c> meetComps = new List<Meet_Comp__c>();
        meetComps.add(
            new Meet_Comp__c(
                GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                Account__c = acc.Id,
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
                MC_Type__c = 'MC',
                Effective_Date__c =  Date.today().addDays(5),
                Termination_Date__c =  Date.today().addDays(6),
                Termination_Date_of_Competitive_Data__c =  Date.today().addDays(7),
                GEA_Model__c = prod1.Id,
                Stage_Name__c = 'Approved',
                Redoced__c = false
            )
        );
        meetComps.add(
            new Meet_Comp__c(
                GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                Account__c = acc.Id,
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
                MC_Type__c = 'Promotional MC',
                Effective_Date__c =  Date.today().addDays(30),
                Termination_Date__c =  Date.today().addDays(31),
                Termination_Date_of_Competitive_Data__c =  Date.today().addDays(32),
                GEA_Model__c = prod2.Id,
                Stage_Name__c = 'Approved and Transferred',
                Redoced__c = false
            )
        );

        insert meetComps;

        Set<Id> meetCompsIds = new Set<Id>();

        for (Meet_Comp__c mc : meetComps) {
            meetCompsIds.add(mc.Id);
        }
        PS_MeetCompMassRedoc_ctrl ctrl = new PS_MeetCompMassRedoc_ctrl();
        System.assertEquals(false, ctrl.isMeetCompsEligible(meetCompsIds));
    }

    @isTest
    static void shoulCheckMeetCompsWhenTheyAreNotEligibleByStageName() {
        Account acc = [SELECT Id FROM Account][0];
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = 'testLastName1'];
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];

        List<Meet_Comp__c> meetComps = new List<Meet_Comp__c>();
        meetComps.add(
            new Meet_Comp__c(
                GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                Account__c = acc.Id,
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
                MC_Type__c = 'MC',
                Effective_Date__c =  Date.today().addDays(5),
                Termination_Date__c =  Date.today().addDays(6),
                Termination_Date_of_Competitive_Data__c =  Date.today().addDays(7),
                GEA_Model__c = prod1.Id,
                Stage_Name__c = 'Approved',
                Redoced__c = false
            )
        );
        meetComps.add(
            new Meet_Comp__c(
                GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                Account__c = acc.Id,
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
                MC_Type__c = 'Promotional MC',
                Effective_Date__c =  Date.today().addDays(29),
                Termination_Date__c =  Date.today().addDays(30),
                Termination_Date_of_Competitive_Data__c =  Date.today().addDays(31),
                GEA_Model__c = prod2.Id,
                Stage_Name__c = 'Awaiting Approval',
                Redoced__c = false
            )
        );

        insert meetComps;

        Set<Id> meetCompsIds = new Set<Id>();

        for (Meet_Comp__c mc : meetComps) {
            meetCompsIds.add(mc.Id);
        }
        PS_MeetCompMassRedoc_ctrl ctrl = new PS_MeetCompMassRedoc_ctrl();
        System.assertEquals(false, ctrl.isMeetCompsEligible(meetCompsIds));
    }

}
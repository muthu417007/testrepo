@isTest
public class PS_MeetCompMassApproval_test {

    @testSetup
    static void setup() {
        PS_MeetComp_TriggerHandler.TriggerDisabled =  true;
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        Meet_Comp__c[] meetComps = new List<Meet_Comp__c>();
        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;

        Contact cnt = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            Phone = '4155551212',
            AccountId = acc1.id);
        insert cnt;

        for (integer i = 0; i < 20; i ++) {
            meetComps.add(new Meet_Comp__c(
                GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                Account__c = acc1.Id,
                Competitive_Inventory_Financing_pct__c = 5,
                Competitive_Invoice_Price__c = 5,
                Competitive_Other_Backside_pct__c = 5,
                Competitive_Price_Promotional_Diff__c = 5,
                Competitive_Sales_Campaigns_Promos__c = 5,
                Competitive_Volume_Rebate_PIF__c =  5,
                Contact_Name__c = cnt.Id,
                Date_Competitive_Data_Received__c = Date.today().addDays(-3),
                Effective_Date__c = Date.today().addDays(3),
                GEA_Inventory_Financing__c = 5,
                GEA_Meet_Comp_Price__c = 5,
                GEA_Other_Backside__c = 5,
                GEA_Price_Promotional_Difference_PPD__c = 5,
                GEA_Sales_Campaigns_and_Promotions__c = 5,
                GEA_Volume_Rebate_PIF__c = 5,
                Termination_Date_of_Competitive_Data__c = Date.today().addDays(5),
                Termination_Date__c = Date.today().addDays(7)
            ));
        }
        insert meetComps;

        for (Meet_Comp__c mt : meetComps) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Bulk Submitted by' + userInfo.getName());
            req.setObjectId(mt.Id);
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
    }

    static testMethod void approveRecords_shouldApproveRecords () {
        //GIVEN
        Meet_Comp__c[] meetComps = [SELECT Id, Name FROM Meet_Comp__c ORDER BY Name ASC LIMIT 10];
        Set<Id> selected = new Set<Id>();

        for (Meet_Comp__c mc : meetComps) {
            selected.add(mc.Id);
        }

        Test.setCurrentPage(Page.PS_MeetCompMassApproval);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(meetComps);
        stdSetController.setSelected(meetComps);
        PS_MeetCompMassApproval_ctrl ctrl = new PS_MeetCompMassApproval_ctrl(stdSetController);

        ProcessInstance[] processItems = [Select ProcessDefinition.Type, Status FROM ProcessInstance  WHERE ProcessInstance.TargetObjectId IN :selected];
        for (ProcessInstance ps : processItems) {
            System.assertEquals('Pending', ps.Status);
        }

        //WHEN
        ctrl.approveRecords();

        processItems = [Select ProcessDefinition.Type, Status FROM ProcessInstance  WHERE ProcessInstance.TargetObjectId IN :selected];
        for (ProcessInstance ps : processItems) {
            System.assertEquals('Approved', ps.Status);
        }

        processItems = [Select ProcessDefinition.Type, Status FROM ProcessInstance  WHERE ProcessInstance.TargetObjectId NOT IN :selected];
        for (ProcessInstance ps : processItems) {
            System.assertEquals('Pending', ps.Status);
        }
    }

    static testMethod void rejectRecords_shouldRejectRecords () {
        //GIVEN
        Meet_Comp__c[] meetComps = [SELECT Id, Name FROM Meet_Comp__c ORDER BY Name ASC LIMIT 10];
        Set<Id> selected = new Set<Id>();

        for (Meet_Comp__c mc : meetComps) {
            selected.add(mc.Id);
        }

        Test.setCurrentPage(Page.PS_MeetCompMassApproval);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(meetComps);
        stdSetController.setSelected(meetComps);
        PS_MeetCompMassApproval_ctrl ctrl = new PS_MeetCompMassApproval_ctrl(stdSetController);

        ProcessInstance[] processItems = [Select ProcessDefinition.Type, Status FROM ProcessInstance  WHERE ProcessInstance.TargetObjectId IN :selected];
        for (ProcessInstance ps : processItems) {
            System.assertEquals('Pending', ps.Status);
        }
        
        //WHEN
        ctrl.rejectRecords();
        ctrl.showPopup();
		ctrl.closePopup();
        processItems = [Select ProcessDefinition.Type, Status FROM ProcessInstance  WHERE ProcessInstance.TargetObjectId IN :selected];
        for (ProcessInstance ps : processItems) {
            System.assertEquals('Rejected', ps.Status);
        }

        processItems = [Select ProcessDefinition.Type, Status FROM ProcessInstance  WHERE ProcessInstance.TargetObjectId NOT IN :selected];
        for (ProcessInstance ps : processItems) {
            System.assertEquals('Pending', ps.Status);
        }
    }
}
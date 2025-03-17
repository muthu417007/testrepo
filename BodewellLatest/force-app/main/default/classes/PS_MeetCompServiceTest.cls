@isTest
private class PS_MeetCompServiceTest {
    
    @testSetup
    static void setup() {
        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;

        Contact cnt = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            Phone = '4155551212',
            AccountId = acc1.id);
        insert cnt;
    }

    @isTest
    static void onInsert_setOriginatingMeetCompFieldIfTheRecordIsCloned() {
            
        Account acc = [SELECT Id FROM Account];
        Contact ctc = [SELECT Id FROM Contact];
        
        Meet_Comp__c mc = new Meet_Comp__c(
            GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
            Account__c = acc.Id,
            Competitive_Inventory_Financing_pct__c = 5,
            Competitive_Invoice_Price__c = 5,
            Competitive_Other_Backside_pct__c = 5,
            Competitive_Price_Promotional_Diff__c = 5,
            Competitive_Sales_Campaigns_Promos__c = 5,
            Competitive_Volume_Rebate_PIF__c =  5,
            Contact_Name__c = ctc.Id,
            Date_Competitive_Data_Received__c = Date.today().addDays(-3),
            GEA_Inventory_Financing__c = 5,
            GEA_Meet_Comp_Price__c = 5,
            GEA_Other_Backside__c = 5,
            GEA_Price_Promotional_Difference_PPD__c = 5,
            GEA_Sales_Campaigns_and_Promotions__c = 5,
            GEA_Volume_Rebate_PIF__c = 5
        );
        insert mc;
        
        Test.startTest();

        Meet_Comp__c clone = mc.clone();
        insert clone;

        Test.stopTest();

        System.assertEquals(true, clone.isClone());
        System.assertEquals(mc.Id, clone.getCloneSourceId());
        Meet_Comp__c clonedMc = [SELECT Id, Originating_Meet_Comp__c FROM Meet_Comp__c WHERE Id = :clone.Id];
        System.assertEquals(mc.Id, clonedMc.Originating_Meet_Comp__c);
    }

    @isTest
    static void onInsert_doNotSetOriginatingMeetCompFieldIfTheRecordIsNotCloned() {
            
        Account acc = [SELECT Id FROM Account];
        Contact ctc = [SELECT Id FROM Contact];
        
        Meet_Comp__c mc = new Meet_Comp__c(
            GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
            Account__c = acc.Id,
            Competitive_Inventory_Financing_pct__c = 5,
            Competitive_Invoice_Price__c = 5,
            Competitive_Other_Backside_pct__c = 5,
            Competitive_Price_Promotional_Diff__c = 5,
            Competitive_Sales_Campaigns_Promos__c = 5,
            Competitive_Volume_Rebate_PIF__c =  5,
            Contact_Name__c = ctc.Id,
            Date_Competitive_Data_Received__c = Date.today().addDays(-3),
            GEA_Inventory_Financing__c = 5,
            GEA_Meet_Comp_Price__c = 5,
            GEA_Other_Backside__c = 5,
            GEA_Price_Promotional_Difference_PPD__c = 5,
            GEA_Sales_Campaigns_and_Promotions__c = 5,
            GEA_Volume_Rebate_PIF__c = 5
        );
        insert mc;
        
        Test.startTest();

        Meet_Comp__c clone = new Meet_Comp__c(
            GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
            Account__c = acc.Id,
            Competitive_Inventory_Financing_pct__c = 5,
            Competitive_Invoice_Price__c = 5,
            Competitive_Other_Backside_pct__c = 5,
            Competitive_Price_Promotional_Diff__c = 5,
            Competitive_Sales_Campaigns_Promos__c = 5,
            Competitive_Volume_Rebate_PIF__c =  5,
            Contact_Name__c = ctc.Id,
            Date_Competitive_Data_Received__c = Date.today().addDays(-3),
            GEA_Inventory_Financing__c = 5,
            GEA_Meet_Comp_Price__c = 5,
            GEA_Other_Backside__c = 5,
            GEA_Price_Promotional_Difference_PPD__c = 5,
            GEA_Sales_Campaigns_and_Promotions__c = 5,
            GEA_Volume_Rebate_PIF__c = 5
        );
        insert clone;

        Test.stopTest();

        System.assertEquals(false, clone.isClone());
        System.assertEquals(null, clone.getCloneSourceId());
        Meet_Comp__c clonedMc = [SELECT Id, Originating_Meet_Comp__c FROM Meet_Comp__c WHERE Id = :clone.Id];
        System.assertEquals(null, clonedMc.Originating_Meet_Comp__c);
    }
}
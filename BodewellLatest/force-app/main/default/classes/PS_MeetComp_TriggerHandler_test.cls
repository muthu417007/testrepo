@isTest
public class PS_MeetComp_TriggerHandler_test {

    final static String PROFILE_NAME_BASE_SALES_CONTRACT = 'Base Sales - Contract';
    
    @testSetup
    static void setup() {
        
        Meet_Comp__c[] meetComps = new List<Meet_Comp__c>();
        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;

        Contact cnt = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            Phone = '4155551212',
            AccountId = acc1.id);
        insert cnt;
        
        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
        Product2 prod2 = new Product2(Name = 'Product 2', Family = 'Hardware', Item_Number__c = '2');
        insert new List<Product2>{prod1, prod2};
        
        for(integer i = 0; i < 3; i ++) {
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
        meetComps[1].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(3);
        meetComps[1].GEA_Model__c = prod1.Id;
        
        meetComps[2].MC_Type__c = 'Net/Net MC';
        meetComps[2].Effective_Date__c =  Date.today().addDays(4);
        meetComps[2].Termination_Date__c =  Date.today().addDays(5);
        meetComps[2].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(6);
        meetComps[2].GEA_Model__c = prod1.Id;
        
        insert meetComps;

        Profile prof = [select Id from profile where name LIKE '%System Administrator%'];
        Id baseSalesContractProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_BASE_SALES_CONTRACT].Id;
        List<User> users = new List<User>();
        users.add(new User(
            firstName = 'Abc',
            lastName = 'xyz',
            Alias = 'abcbc',
            profileId = prof.id,
            username = 'abcabc.xyz@test.com',
            email = 'test@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        users.add(new User(
            firstName = 'Abcd',
            lastName = 'xyza',
            Alias = 'abcbd',
            profileId = prof.id,
            username = 'abcabc.xyz2@test.com',
            email = 'test2@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        users.add(new User(
            firstName = 'Abcde',
            lastName = 'xyzb',
            Alias = 'abcbe',
            profileId = baseSalesContractProfileId,
            username = 'abcabc.xyz3@test.com',
            email = 'test3@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        insert users;
    }
    
    static testMethod void onUpdate_shouldPreventUpdateVsOldMeetComps () {
        //GIVEN
        Meet_Comp__c mc = [SELECT MC_Type__c FROM Meet_Comp__c WHERE MC_Type__c = 'Promotional MC'];
        
        //WHEN
        try {
            mc.MC_Type__c = 'Net/Net MC';
            update mc;
            System.assertEquals(false, true, 'Should not update Meet Comp Records');
        }

        //THEN
        catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.PS_OVERLAPPING_WITH_EXISTING_MC);
            System.AssertEquals(expectedExceptionThrown, true, 'Should prevent update when updated values (MC Type) would cause duplicate with old Meet Comps');
        }
        
        //WHEN
        mc = [SELECT MC_Type__c FROM Meet_Comp__c WHERE MC_Type__c = 'Net/Net MC'];
        try {
            mc.Effective_Date__c = System.today().addDays(2);
            update mc;
            System.assertEquals(false, true, 'Should not update Meet Comp Records');
        }

        //THEN
        catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.PS_OVERLAPPING_WITH_EXISTING_MC);
            System.AssertEquals(expectedExceptionThrown, true, 'Should prevent update when updated values would cause duplicate with old Meet Comps');
        }
    }
    
    static testMethod void onUpdate_shouldPreventUpdateVsCurrentMeetComps () {
        //GIVEN
        Meet_Comp__c[] mcsToUpdate = [SELECT MC_Type__c FROM Meet_Comp__c WHERE MC_Type__c = 'Net/Net MC' OR MC_Type__c = 'MC'];
        
        //WHEN
        try {
            for (Meet_Comp__c mc : mcsToUpdate) {
                mc.Effective_Date__c = System.today().addDays(10);
                mc.Termination_Date__c = System.today().addDays(14);
                mc.Termination_Date_of_Competitive_Data__c = System.today().addDays(13);
            }
            update mcsToUpdate;
            System.assertEquals(false, true, 'Should not update Meet Comp Records');
        }

        //THEN
        catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.PS_OVERLAPPING_WITH_MC_TO_REDOC);
            System.AssertEquals(expectedExceptionThrown, true, 'Should prevent update when updated values (Dates) would cause duplicate with current Meet Comps');
        }
    }
    
    static testMethod void onUpdate_shouldAllowUpdateVsCurrentMeetComps () {
        //GIVEN
        Meet_Comp__c[] mcsToUpdate = [SELECT MC_Type__c FROM Meet_Comp__c WHERE MC_Type__c = 'Net/Net MC' OR MC_Type__c = 'MC'];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        
        //WHEN
        for (Meet_Comp__c mc : mcsToUpdate) {
            mc.Effective_Date__c = System.today().addDays(10);
            mc.Termination_Date__c = System.today().addDays(14);
            mc.Termination_Date_of_Competitive_Data__c = System.today().addDays(13);
        }
        mcsToUpdate[0].GEA_Model__c = prod2.Id;
        update mcsToUpdate;
        
        //THEN
        for (Meet_Comp__c mc : [SELECT Effective_Date__c FROM Meet_Comp__c WHERE MC_Type__c = 'Net/Net MC' OR MC_Type__c = 'MC']) {
            System.assertEquals(System.today().addDays(10), mc.Effective_Date__c, 'Should allow update of Meet Comp Records if they have same dates but different product');  
        }
    }
    
    static testMethod void onUpdate_shouldAllowUpdateVsOldMeetComps () {
        //GIVEN
        Meet_Comp__c mc = [SELECT MC_Type__c FROM Meet_Comp__c WHERE MC_Type__c = 'Net/Net MC'];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        
        //WHEN
        mc.Effective_Date__c = System.today().addDays(2);
        mc.Termination_Date_of_Competitive_Data__c = System.today().addDays(3);
        mc.GEA_Model__c = prod2.Id;
        update mc;
        
        //THEN
         mc = [SELECT Effective_Date__c FROM Meet_Comp__c WHERE MC_Type__c = 'Net/Net MC'];
         System.assertEquals(System.today().addDays(2), mc.Effective_Date__c, 
            'Should allow update of Meet Comp Record of the same scope as old MC, if product is different.');  
    }
    
    static testMethod void onInsert_shouldPreventInsertVsCurrentMeetComps () {
        //GIVEN
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Meet_Comp__c[] meetComps = new List<Meet_Comp__c>();
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'Account 1'];
        Contact cnt = [SELECT Id FROM contact WHERE LastName = 'Smith'];
        
        for(integer i = 0; i < 20; i ++) {
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
                GEA_Inventory_Financing__c = 5,
                GEA_Meet_Comp_Price__c = 5,
                GEA_Other_Backside__c = 5,
                GEA_Price_Promotional_Difference_PPD__c = 5,
                GEA_Sales_Campaigns_and_Promotions__c = 5,
                GEA_Volume_Rebate_PIF__c = 5,
                MC_Type__c = 'MC',
                Effective_Date__c = Date.today().addDays(8),
                Termination_Date__c = Date.today().addDays(9),
                Termination_Date_of_Competitive_Data__c = Date.today().addDays(10),
                GEA_Model__c = prod1.Id
            ));
        }
                
        //WHEN
        try {
            insert meetComps;
            System.assertEquals(false, true, 'Should not insert Meet Comp Records');
        }

        //THEN
        catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.PS_OVERLAPPING_WITH_MC_TO_REDOC);
            System.AssertEquals(expectedExceptionThrown, true, 
                'Should prevent insert when values of currently processed records match as duplicate against each other.');
        }
    }
    
    static testMethod void onInsert_shouldPreventInsertVsOldMeetComps () {
        //GIVEN
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Meet_Comp__c[] meetComps = new List<Meet_Comp__c>();
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'Account 1'];
        Contact cnt = [SELECT Id FROM contact WHERE LastName = 'Smith'];
        
        for(integer i = 0; i < 20; i ++) {
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
                GEA_Inventory_Financing__c = 5,
                GEA_Meet_Comp_Price__c = 5,
                GEA_Other_Backside__c = 5,
                GEA_Price_Promotional_Difference_PPD__c = 5,
                GEA_Sales_Campaigns_and_Promotions__c = 5,
                GEA_Volume_Rebate_PIF__c = 5,
                MC_Type__c = 'MC',
                Effective_Date__c = Date.today().addDays(1),
                Termination_Date__c = Date.today().addDays(2),
                Termination_Date_of_Competitive_Data__c = Date.today().addDays(3),
                GEA_Model__c = prod1.Id
            ));
        }
                
        //WHEN
        try {
            insert meetComps;
            System.assertEquals(false, true, 'Should not insert Meet Comp Records');
        }

        //THEN
        catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.PS_OVERLAPPING_WITH_EXISTING_MC);
            System.AssertEquals(expectedExceptionThrown, true, 
                'Should prevent insert when values of currently processed records match as duplicate against each other.');
        }
    }
    
    static testMethod void onInsert_shouldAllowInsertVsOldMeetComps () {
        //GIVEN
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Meet_Comp__c[] meetComps = new List<Meet_Comp__c>();
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'Account 1'];
        Contact cnt = [SELECT Id FROM contact WHERE LastName = 'Smith'];
        Date watermark = System.today().addDays(7);
        for(integer i = 0; i < 4; i ++) {
            Meet_Comp__c mc = new Meet_Comp__c(
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
                GEA_Inventory_Financing__c = 5,
                GEA_Meet_Comp_Price__c = 5,
                GEA_Other_Backside__c = 5,
                GEA_Price_Promotional_Difference_PPD__c = 5,
                GEA_Sales_Campaigns_and_Promotions__c = 5,
                GEA_Volume_Rebate_PIF__c = 5,
                MC_Type__c = 'MC',
                Effective_Date__c = watermark.addDays(1),
                Termination_Date__c = watermark.addDays(3),
                Termination_Date_of_Competitive_Data__c = watermark.addDays(2),
                GEA_Model__c = prod1.Id);
            meetComps.add(mc);
            watermark = mc.Termination_Date__c;
        }
                
        //WHEN
        Database.SaveResult[] saveResults = Database.insert(meetComps);
        for (Database.SaveResult sr : saveResults) { 
            System.assertEquals(true, sr.isSuccess(), 'Should insert new Meet Comp records if dates are not overlaping with new or old Meet Comps');
        }
    }
    
    static testMethod void onInsert_shouldAllowInsertWhenDifferentKey () {
        //GIVEN
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2'];
        Meet_Comp__c[] meetComps = new List<Meet_Comp__c>();
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'Account 1'];
        Contact cnt = [SELECT Id FROM contact WHERE LastName = 'Smith'];
        
        for(integer i = 0; i < 2; i ++) {
            Meet_Comp__c mc = new Meet_Comp__c(
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
                GEA_Inventory_Financing__c = 5,
                GEA_Meet_Comp_Price__c = 5,
                GEA_Other_Backside__c = 5,
                GEA_Price_Promotional_Difference_PPD__c = 5,
                GEA_Sales_Campaigns_and_Promotions__c = 5,
                GEA_Volume_Rebate_PIF__c = 5,
                MC_Type__c = 'MC',
                Effective_Date__c = System.Today().addDays(10),
                Termination_Date__c = System.Today().addDays(13),
                Termination_Date_of_Competitive_Data__c = System.Today().addDays(12));
            meetComps.add(mc);
        }
        meetComps[0].GEA_Model__c = prod1.Id;
        meetComps[1].GEA_Model__c = prod2.Id;
                
        //WHEN
        Database.SaveResult[] saveResults = Database.insert(meetComps);
        for (Database.SaveResult sr : saveResults) { 
            System.assertEquals(true, sr.isSuccess(), 'Should insert new Meet Comp records if dates are not overlaping with new or old Meet Comps');
        }
    }

    @isTest
    static void onDelete_shouldPreventDeletionWhenTransferredToOracle () {
        User baseSalesContractUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz3@test.com'];

        List<Meet_Comp__c> meetComps = new List<Meet_Comp__c>();

        System.runAs(baseSalesContractUser) {
            Account acc = new Account(Name = 'Account 3', Meet_Comp_Eligibility__c = 'National');
            insert acc;

            Contact cnt = new Contact(
                FirstName = 'Joe',
                LastName = 'Smith2',
                Phone = '4155551212',
                AccountId = acc.id);
            insert cnt;

            Product2 prod = new Product2(Name = 'Product 3', Family = 'Hardware', Item_Number__c = '1');
            meetComps.add(
                new Meet_Comp__c(
                    GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                    Account__c = acc.Id,
                    Competitive_Inventory_Financing_pct__c = 5,
                    Competitive_Invoice_Price__c = 5,
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
                    Effective_Date__c = System.Today(),
                    Transferred_to_Oracle__c = true,
                    Termination_Date__c = System.Today().addDays(2),
                    Termination_Date_of_Competitive_Data__c = System.Today().addDays(1),
                    GEA_Model__c = prod.Id
                )
            );

            insert meetComps;

            List<Database.DeleteResult> deleteResults = Database.delete(meetComps, false);

            Integer unsuccessfulDeletionsCount = 0;
            for (Database.DeleteResult result : deleteResults) {
                if (!result.isSuccess()) {
                    unsuccessfulDeletionsCount++;
                    System.debug('ERROR MESSAGE ' + result.getErrors()[0].getMessage());
                    System.assert(
                        result.getErrors()[0].getMessage().contains(Label.PS_CANNOT_DELETE_MEET_COMP),
                        'Exception message should contain: \'' + Label.PS_CANNOT_DELETE_MEET_COMP + '\''
                    );
                }
            }
            System.assertEquals(
                meetComps.size(),
                unsuccessfulDeletionsCount,
                'Number of unsuccessful deletions should be equals ' + meetComps.size()
            );
        }
    }

    @isTest
    static void onDelete_shouldAllowDeletion() {
        User baseSalesContractUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz3@test.com'];

        List<Meet_Comp__c> meetComps = new List<Meet_Comp__c>();

        System.runAs(baseSalesContractUser) {
            Account acc = new Account(Name = 'Account 3', Meet_Comp_Eligibility__c = 'National');
            insert acc;

            Contact cnt = new Contact(
                FirstName = 'Joe',
                LastName = 'Smith2',
                Phone = '4155551212',
                AccountId = acc.id);
            insert cnt;

            Product2 prod3 = new Product2(Name = 'Product 3', Family = 'Hardware', Item_Number__c = '1');
            Product2 prod4 = new Product2(Name = 'Product 4', Family = 'Hardware', Item_Number__c = '1');

            for (Integer i = 0; i < 2; i++) {
                Meet_Comp__c mc = new Meet_Comp__c(
                    GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                    Account__c = acc.Id,
                    Competitive_Inventory_Financing_pct__c = 5,
                    Competitive_Invoice_Price__c = 5,
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
                    Transferred_to_Oracle__c = false,
                    Termination_Date_of_Competitive_Data__c = System.Today().addDays(12));
                meetComps.add(mc);
            }
            meetComps[0].GEA_Model__c = prod3.Id;
            meetComps[0].Effective_Date__c = System.Today().addDays(1);
            meetComps[0].Termination_Date__c = System.Today().addDays(2);


            meetComps[1].GEA_Model__c = prod4.Id;
            meetComps[1].Effective_Date__c = System.Today();
            meetComps[1].Termination_Date__c = System.Today().addDays(1);

            insert meetComps;

            Set<Id> meetCompIds = new Set<Id>();
            for(Meet_Comp__c meetComp : meetComps) {
                meetCompIds.add(meetComp.Id);
            }

            delete meetComps;

            List<Meet_Comp__c> deletedMeetComps = [SELECT Id, IsDeleted FROM Meet_Comp__c WHERE Id = :meetCompIds ALL ROWS];
            for (Meet_Comp__c deletedMeetComp : deletedMeetComps) {
                System.assert(deletedMeetComp.IsDeleted, 'Meet Comp should be deleted by B2B Sales user');
            }
        }
    }

}
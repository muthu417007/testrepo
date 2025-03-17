@isTest
private class PS_AccountTeamMember_TriggerHandler_Test {

    @testSetup
    static void setup() {

        Profile prof = [select Id from profile where name LIKE '%System Administrator%'];
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
        insert users;

        System.runAs(users[1]) {
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
            insert new PermissionSetAssignment(
                PermissionSetId = permSet.Id,
                AssigneeId = users[0].Id
            );
            insert new PermissionSetAssignment(
                PermissionSetId = permSet.Id,
                AssigneeId = users[1].Id
            );
        }
    }

    static testMethod void onDelete_ShouldDeleteSharesForRecordsRelatedToAccount () {
        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;
        Contact cnt = new Contact(FirstName = 'Joe', LastName = 'Smith', Phone = '4155551212', AccountId = acc1.id);
        insert cnt;
        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
        insert prod1;
        Schema.Location testLocation = new Schema.Location(Name = 'test');
        insert testLocation;
        RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = acc1.Id, LocationId = testLocation.Id);
        insert rs1;

        Meet_Comp__c meetComp = new Meet_Comp__c(
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
            Effective_Date__c =  Date.today().addDays(1),
            Termination_Date__c =  Date.today().addDays(2),
            Termination_Date_of_Competitive_Data__c =  Date.today().addDays(3),
            GEA_Model__c = prod1.Id
        );
        insert meetComp;

        Customer_Agreement__c customerAgreement = new Customer_Agreement__c(
            Account_Name__c = acc1.Id
        );
        insert customerAgreement;

        StoreProduct sp1 = new StoreProduct(
            Account__c = acc1.Id,
            ProductId = prod1.Id,
            RetailStoreId = rs1.Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3)
        );
        insert sp1;

        Program_Request__c request = new Program_Request__c(
            Account__c = acc1.Id,
            Start_Date__c = System.today().addDays(-3),
            End_Date__c = System.today().addDays(3)
        );
        insert request;

        Account_Sales_Performance__c salesPerf = new Account_Sales_Performance__c(
            Account__c = acc1.Id
        );

        insert salesPerf;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        System.assertEquals(1, [SELECT count() FROM Meet_Comp__Share]);
        System.assertEquals(1, [SELECT count() FROM Program_Request__Share]);
        System.assertEquals(1, [SELECT count() FROM StoreProductShare]);
        System.assertEquals(1, [SELECT count() FROM Customer_Agreement__Share]);
        System.assertEquals(1, [SELECT count() FROM Account_Sales_Performance__Share]);

        AccountTeamMember member;

        System.runAs(user) {
            member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc1.Id,
                UserId = user2.Id
            );
            insert member;
        }
        List<SObject> sharesToInsert = new List<SObject>();
        sharesToInsert.add(new Account_Sales_Performance__Share(
            RowCause = Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = salesPerf.Id
        ));
        sharesToInsert.add(new Customer_Agreement__Share(
            RowCause = Schema.Customer_Agreement__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = customerAgreement.Id
        ));
        sharesToInsert.add(new Program_Request__Share(
            RowCause = Schema.Program_Request__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = request.Id
        ));
        sharesToInsert.add(new Meet_Comp__Share(
            RowCause = Schema.Meet_Comp__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = meetComp.Id
        ));
        sharesToInsert.add(new StoreProductShare(
            RowCause = Schema.StoreProductShare.RowCause.Manual,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = sp1.Id
        ));
        insert sharesToInsert;

        System.assertEquals(2, [SELECT count() FROM Meet_Comp__Share]);
        System.assertEquals(2, [SELECT count() FROM Program_Request__Share]);
        System.assertEquals(2, [SELECT count() FROM StoreProductShare]);
        System.assertEquals(2, [SELECT count() FROM Customer_Agreement__Share]);
        System.assertEquals(2, [SELECT count() FROM Account_Sales_Performance__Share]);

        Test.startTest();
        System.runAs(user) {
            delete member;
        }
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Meet_Comp__Share]);
        System.assertEquals(1, [SELECT count() FROM Program_Request__Share]);
        System.assertEquals(1, [SELECT count() FROM StoreProductShare]);
        System.assertEquals(1, [SELECT count() FROM Customer_Agreement__Share]);
        System.assertEquals(1, [SELECT count() FROM Account_Sales_Performance__Share]);
    }

    static testMethod void onDelete_ShouldDeleteSharesForRecordsRelatedToAccountExceptOwnershipShare () {
        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;
        Contact cnt = new Contact(FirstName = 'Joe', LastName = 'Smith', Phone = '4155551212', AccountId = acc1.id);
        insert cnt;
        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
        insert prod1;
        Schema.Location testLocation = new Schema.Location(Name = 'test');
        insert testLocation;
        RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = acc1.Id, LocationId = testLocation.Id);
        insert rs1;

        Meet_Comp__c meetComp = new Meet_Comp__c(
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
            Effective_Date__c =  Date.today().addDays(1),
            Termination_Date__c =  Date.today().addDays(2),
            Termination_Date_of_Competitive_Data__c =  Date.today().addDays(3),
            GEA_Model__c = prod1.Id
        );
        insert meetComp;

        Customer_Agreement__c customerAgreement = new Customer_Agreement__c(
            Account_Name__c = acc1.Id
        );
        insert customerAgreement;

        StoreProduct sp1 = new StoreProduct(
            Account__c = acc1.Id,
            ProductId = prod1.Id,
            RetailStoreId = rs1.Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3)
        );
        insert sp1;

        Program_Request__c request = new Program_Request__c(
            Account__c = acc1.Id,
            Start_Date__c = System.today().addDays(-3),
            End_Date__c = System.today().addDays(3)
        );
        insert request;

        Account_Sales_Performance__c salesPerf = new Account_Sales_Performance__c(
            Account__c = acc1.Id
        );
        insert salesPerf;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        System.assertEquals(1, [SELECT count() FROM Meet_Comp__Share]);
        System.assertEquals(1, [SELECT count() FROM Program_Request__Share]);
        System.assertEquals(1, [SELECT count() FROM StoreProductShare]);
        System.assertEquals(1, [SELECT count() FROM Customer_Agreement__Share]);
        System.assertEquals(1, [SELECT count() FROM Account_Sales_Performance__Share]);

        AccountTeamMember member;

        System.runAs(user) {
            member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc1.Id,
                UserId = user.Id
            );
            insert member;
            insert new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc1.Id,
                UserId = user2.Id
            );
        }
        List<SObject> sharesToInsert = new List<SObject>();
        sharesToInsert.add(new Account_Sales_Performance__Share(
            RowCause = Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c,
            UserOrGroupId = user.Id,
            AccessLevel = 'Edit',
            ParentId = salesPerf.Id
        ));
        sharesToInsert.add(new Customer_Agreement__Share(
            RowCause = Schema.Customer_Agreement__Share.RowCause.Account_Team__c,
            UserOrGroupId = user.Id,
            AccessLevel = 'Edit',
            ParentId = customerAgreement.Id
        ));
        sharesToInsert.add(new Program_Request__Share(
            RowCause = Schema.Program_Request__Share.RowCause.Account_Team__c,
            UserOrGroupId = user.Id,
            AccessLevel = 'Edit',
            ParentId = request.Id
        ));
        sharesToInsert.add(new Meet_Comp__Share(
            RowCause = Schema.Meet_Comp__Share.RowCause.Account_Team__c,
            UserOrGroupId = user.Id,
            AccessLevel = 'Edit',
            ParentId = meetComp.Id
        ));
        sharesToInsert.add(new StoreProductShare(
            RowCause = Schema.StoreProductShare.RowCause.Manual,
            UserOrGroupId = user.Id,
            AccessLevel = 'Edit',
            ParentId = sp1.Id
        ));

        sharesToInsert.add(new Account_Sales_Performance__Share(
            RowCause = Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = salesPerf.Id
        ));
        sharesToInsert.add(new Customer_Agreement__Share(
            RowCause = Schema.Customer_Agreement__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = customerAgreement.Id
        ));
        sharesToInsert.add(new Program_Request__Share(
            RowCause = Schema.Program_Request__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = request.Id
        ));
        sharesToInsert.add(new Meet_Comp__Share(
            RowCause = Schema.Meet_Comp__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = meetComp.Id
        ));
        sharesToInsert.add(new StoreProductShare(
            RowCause = Schema.StoreProductShare.RowCause.Manual,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = sp1.Id
        ));
        insert sharesToInsert;

        System.assertEquals(3, [SELECT count() FROM Meet_Comp__Share]);
        System.assertEquals(3, [SELECT count() FROM Program_Request__Share]);
        System.assertEquals(3, [SELECT count() FROM StoreProductShare]);
        System.assertEquals(3, [SELECT count() FROM Customer_Agreement__Share]);
        System.assertEquals(3, [SELECT count() FROM Account_Sales_Performance__Share]);

        Test.startTest();

        System.runAs(user) {
            delete member;
        }

        Test.stopTest();

        System.assertEquals(2, [SELECT count() FROM Meet_Comp__Share]);
        System.assertEquals(2, [SELECT count() FROM Program_Request__Share]);
        System.assertEquals(2, [SELECT count() FROM StoreProductShare]);
        System.assertEquals(2, [SELECT count() FROM Customer_Agreement__Share]);
        System.assertEquals(2, [SELECT count() FROM Account_Sales_Performance__Share]);
    }

    static testMethod void testEmptyMethods () {
        new PS_AccountTeamMember_TriggerHandler().beforeInsert(null);
        new PS_AccountTeamMember_TriggerHandler().beforeUpdate(null, null);
        new PS_AccountTeamMember_TriggerHandler().beforeDelete(null);
        new PS_AccountTeamMember_TriggerHandler().afterUpdate(null, null);
    }
}
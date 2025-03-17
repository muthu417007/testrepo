@isTest
private class PS_DeleteSharesBatchTest {

    @testSetup
    static void setup() {
        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;

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

    @isTest
    static void shouldDeleteMeetCompSharesForRecordsRelatedToAccount () {
        Account acc1  = [SELECT Id FROM Account];

        Contact cnt = new Contact(FirstName = 'Joe', LastName = 'Smith', Phone = '4155551212', AccountId = acc1.id);
        insert cnt;
        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
        insert prod1;

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

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        System.assertEquals(1, [SELECT count() FROM Meet_Comp__Share]);

        AccountTeamMember member;

        System.runAs(user) {
            member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc1.Id,
                UserId = user2.Id
            );
            insert member;
        }

        insert new Meet_Comp__Share(
            RowCause = Schema.Meet_Comp__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = meetComp.Id
        );

        System.assertEquals(2, [SELECT count() FROM Meet_Comp__Share]);

        Test.startTest();
        System.runAs(user) {
            Database.executeBatch(
                new PS_DeleteSharesBatch(
                    new Set<Id>{member.UserId},
                    new Set<Id>{member.AccountId},
                    GEA_Constants.OBJECT_API_NAME_MEET_COMP_SHARE,
                    GEA_Constants.FIELD_API_NAME_MEET_COMP_SHARE_PARENT_ACCOUNT,
                    Schema.Meet_Comp__Share.RowCause.Account_Team__c
                )
            );
        }
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Meet_Comp__Share]);
    }

    @isTest
    static void shouldDeleteProgramRequestSharesForRecordsRelatedToAccount () {
        Account acc1  = [SELECT Id FROM Account];

        Program_Request__c request = new Program_Request__c(
            Account__c = acc1.Id,
            Start_Date__c = System.today().addDays(-3),
            End_Date__c = System.today().addDays(3)
        );
        insert request;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        System.assertEquals(1, [SELECT count() FROM Program_Request__Share]);

        AccountTeamMember member;

        System.runAs(user) {
            member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc1.Id,
                UserId = user2.Id
            );
            insert member;
        }

        insert new Program_Request__Share(
            RowCause = Schema.Program_Request__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = request.Id
        );

        System.assertEquals(2, [SELECT count() FROM Program_Request__Share]);

        Test.startTest();
        System.runAs(user) {
            Database.executeBatch(
                new PS_DeleteSharesBatch(
                    new Set<Id>{member.UserId},
                    new Set<Id>{member.AccountId},
                    GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST_SHARE,
                    GEA_Constants.FIELD_API_NAME_PROGRAM_REQUEST_SHARE_PARENT_ACCOUNT,
                    Schema.Program_Request__Share.RowCause.Account_Team__c
                )
            );
        }
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Program_Request__Share]);
    }

    @isTest
    static void shouldDeleteStoreProductSharesForRecordsRelatedToAccount () {
        Account acc1  = [SELECT Id FROM Account];

        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
        insert prod1;
        Schema.Location testLocation = new Schema.Location(Name = 'test');
        insert testLocation;
        RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = acc1.Id, LocationId = testLocation.Id);
        insert rs1;

        StoreProduct sp1 = new StoreProduct(
            Account__c = acc1.Id,
            ProductId = prod1.Id,
            RetailStoreId = rs1.Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3)
        );
        insert sp1;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        System.assertEquals(1, [SELECT count() FROM StoreProductShare]);

        AccountTeamMember member;

        System.runAs(user) {
            member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc1.Id,
                UserId = user2.Id
            );
            insert member;
        }

        insert new StoreProductShare(
            RowCause = Schema.StoreProductShare.RowCause.Manual,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = sp1.Id
        );

        System.assertEquals(2, [SELECT count() FROM StoreProductShare]);

        Test.startTest();
        System.runAs(user) {
            Database.executeBatch(
                new PS_DeleteSharesBatch(
                    new Set<Id>{member.UserId},
                    new Set<Id>{member.AccountId},
                    GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT_SHARE,
                    GEA_Constants.FIELD_API_NAME_STORE_PRODUCT_SHARE_PARENT_ACCOUNT,
                    Schema.StoreProductShare.RowCause.Manual
                )
            );
        }
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM StoreProductShare]);
    }

    @isTest
    static void shouldDeleteCustomerAgreementSharesForRecordsRelatedToAccount () {
        Account acc1  = [SELECT Id FROM Account];

        Customer_Agreement__c customerAgreement = new Customer_Agreement__c(
            Account_Name__c = acc1.Id
        );
        insert customerAgreement;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        System.assertEquals(1, [SELECT count() FROM Customer_Agreement__Share]);

        AccountTeamMember member;

        System.runAs(user) {
            member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc1.Id,
                UserId = user2.Id
            );
            insert member;
        }

        insert new Customer_Agreement__Share(
            RowCause = Schema.Customer_Agreement__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = customerAgreement.Id
        );

        System.assertEquals(2, [SELECT count() FROM Customer_Agreement__Share]);

        Test.startTest();
        System.runAs(user) {
            Database.executeBatch(
                new PS_DeleteSharesBatch(
                    new Set<Id>{member.UserId},
                    new Set<Id>{member.AccountId},
                    GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT_SHARE,
                    GEA_Constants.FIELD_API_NAME_CUSTOMER_AGREEMENT_SHARE_PARENT_ACCOUNT,
                    Schema.Customer_Agreement__Share.RowCause.Account_Team__c
                )
            );
        }
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Customer_Agreement__Share]);
    }

    @isTest
    static void shouldDeleteSalesPerfSharesForRecordsRelatedToAccount () {
        Account acc1  = [SELECT Id FROM Account];

        Account_Sales_Performance__c salesPerf = new Account_Sales_Performance__c(
            Account__c = acc1.Id
        );
        insert salesPerf;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

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

        insert new Account_Sales_Performance__Share(
            RowCause = Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = salesPerf.Id
        );

        System.assertEquals(2, [SELECT count() FROM Account_Sales_Performance__Share]);

        Test.startTest();
        System.runAs(user) {
            Database.executeBatch(
                new PS_DeleteSharesBatch(
                    new Set<Id>{member.UserId},
                    new Set<Id>{member.AccountId},
                    GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE_SHARE,
                    GEA_Constants.FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_SHARE_PARENT_ACCOUNT,
                    Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c
                )
            );
        }
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Account_Sales_Performance__Share]);
    }

}
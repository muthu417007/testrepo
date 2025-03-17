@isTest
private class PS_ShareNewRecordsToAtmBatchTest {

    private static DateTime dateTimeFrom = Datetime.now().addHours(-1);
    private static DateTime dateTimeTo = Datetime.now().addHours(1);

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

        Schema.Location testLocation = new Schema.Location(Name = 'test');
        insert testLocation;

        Product2 nonGeProduct = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1', Brand__c = 'Amana');
        Product2 geProduct = new Product2(Name = 'Product 2', Family = 'Hardware', Item_Number__c = '2', Brand__c = 'GE');
        insert new List<Product2>{nonGeProduct, geProduct};

        RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = acc1.Id, LocationId = testLocation.Id);
        RetailStore rs2 = new RetailStore(Name = 'rs2', AccountId = acc1.Id, LocationId = testLocation.Id);
        insert new List<RetailStore> {rs1, rs2};

        StoreProduct sp1 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp2 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp3 = new StoreProduct(ProductId = geProduct.Id, RetailStoreId = rs1.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp4 = new StoreProduct(ProductId = geProduct.Id, RetailStoreId = rs2.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp5 = new StoreProduct(ProductId = geProduct.Id, RetailStoreId = rs2.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp6 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs2.Id, StartDate = System.today().addDays(-3), EndDate = System.today().addDays(3));
        StoreProduct sp7 = new StoreProduct(ProductId = nonGeProduct.Id, RetailStoreId = rs2.Id, StartDate = System.today().addDays(4));
        insert new List<StoreProduct>{sp1, sp2, sp3, sp4, sp5, sp6, sp7};

        List<Meet_Comp__c> meetComps = new List<Meet_Comp__c>();
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
        meetComps[0].GEA_Model__c = geProduct.Id;

        meetComps[1].MC_Type__c = 'Promotional MC';
        meetComps[1].Effective_Date__c =  Date.today().addDays(1);
        meetComps[1].Termination_Date__c =  Date.today().addDays(2);
        meetComps[1].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(3);
        meetComps[1].GEA_Model__c = geProduct.Id;

        meetComps[2].MC_Type__c = 'Net/Net MC';
        meetComps[2].Effective_Date__c =  Date.today().addDays(4);
        meetComps[2].Termination_Date__c =  Date.today().addDays(5);
        meetComps[2].Termination_Date_of_Competitive_Data__c =  Date.today().addDays(6);
        meetComps[2].GEA_Model__c = geProduct.Id;

        insert meetComps;

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
    }

    @isTest
    static void shouldCreateMeetCompSharingsForAccountTeamMembers () {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        System.runAs(user) {

            Account acc = [SELECT Id FROM Account];
            Contact ctc = [SELECT Id FROM Contact];

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc.Id,
                UserId = user2.Id
            );
            insert member;

            System.assertEquals(3, [SELECT count() FROM Meet_Comp__Share]);

            insert new Meet_Comp__c(
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
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_MEET_COMP,
                GEA_Constants.FIELD_API_NAME_MEET_COMP_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(8, [SELECT count() FROM Meet_Comp__Share]);
    }

    @isTest
    static void shouldNotTryToCreateDuplicatedMeetCompSharingAccountOwner () {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        System.runAs(user) {

            Account acc = [SELECT Id FROM Account];
            Contact ctc = [SELECT Id FROM Contact];

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc.Id,
                UserId = user.Id
            );
            insert member;

            System.assertEquals(3, [SELECT count() FROM Meet_Comp__Share]);

            insert new Meet_Comp__c(
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
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_MEET_COMP,
                GEA_Constants.FIELD_API_NAME_MEET_COMP_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(7, [SELECT count() FROM Meet_Comp__Share]);
    }

    @isTest
    static void shouldCreateProgramRequestSharingsForAccountTeamMembers() {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        System.runAs(user) {

            Account account = [SELECT Id FROM Account];

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = account.Id,
                UserId = user2.Id
            );
            insert member;

            System.assertEquals(0, [SELECT count() FROM Program_Request__Share WHERE RowCause = :Schema.Program_Request__Share.RowCause.Account_Team__c]);

            Program_Request__c request = new Program_Request__c(
                Account__c = account.Id,
                Start_Date__c = System.today().addDays(-3),
                End_Date__c = System.today().addDays(3)
            );
            insert request;
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST,
                GEA_Constants.FIELD_API_NAME_PROGRAM_REQUEST_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Program_Request__Share WHERE RowCause = :Schema.Program_Request__Share.RowCause.Account_Team__c]);
    }

    @isTest
    static void shouldNotTryToCreateDuplicatedProgramRequestSharingsForAccountOwner () {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        System.runAs(user) {

            Account account = [SELECT Id FROM Account];

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = account.Id,
                UserId = user.Id
            );
            insert member;

            System.assertEquals(0, [SELECT count() FROM Program_Request__Share]);

            Program_Request__c request = new Program_Request__c(
                Account__c = account.Id,
                Start_Date__c = System.today().addDays(-3),
                End_Date__c = System.today().addDays(3)
            );
            insert request;
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST,
                GEA_Constants.FIELD_API_NAME_PROGRAM_REQUEST_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Program_Request__Share]);
    }

    @isTest
    static void shouldCreateStoreProductSharingsForAccountTeamMembers () {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        System.runAs(user) {

            Account account = [SELECT Id FROM Account];
            Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
            RetailStore rs1 = [SELECT Id FROM RetailStore WHERE Name = 'rs1'];

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = account.Id,
                UserId = user2.Id
            );
            insert member;

            System.assertEquals(7, [SELECT count() FROM StoreProductShare]);

            StoreProduct sp1 = new StoreProduct(
                Account__c = account.Id,
                ProductId = prod.Id,
                RetailStoreId = rs1.Id,
                StartDate = System.today().addDays(-3),
                EndDate = System.today().addDays(3)
            );
            insert sp1;
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT,
                GEA_Constants.FIELD_API_NAME_STORE_PRODUCT_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(16, [SELECT count() FROM StoreProductShare]);
    }

    @isTest
    static void shouldNotTryToCreateRepeatedStoreProductSharingForAccountOwner () {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        System.runAs(user) {

            Account account = [SELECT Id FROM Account];
            Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Product 1'];
            RetailStore rs1 = [SELECT Id FROM RetailStore WHERE Name = 'rs1'];

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = account.Id,
                UserId = user.Id
            );
            insert member;

            System.assertEquals(7, [SELECT count() FROM StoreProductShare]);

            StoreProduct sp1 = new StoreProduct(
                Account__c = account.Id,
                ProductId = prod.Id,
                RetailStoreId = rs1.Id,
                StartDate = System.today().addDays(-3),
                EndDate = System.today().addDays(3)
            );
            insert sp1;
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT,
                GEA_Constants.FIELD_API_NAME_STORE_PRODUCT_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(15, [SELECT count() FROM StoreProductShare]);
    }

    @isTest
    static void shouldCreateCustomerAgreementSharingsForAccountTeamMembers() {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        System.runAs(user) {

            Account account = [SELECT Id FROM Account];

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = account.Id,
                UserId = user2.Id
            );
            insert member;

            System.assertEquals(0, [SELECT count() FROM Customer_Agreement__Share]);

            insert new Customer_Agreement__c(
                Account_Name__c = account.Id
            );
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT,
                GEA_Constants.FIELD_API_NAME_CUSTOMER_AGREEMENT_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(2, [SELECT count() FROM Customer_Agreement__Share]);
    }

    @isTest
    static void shouldNotTryToCreateCustomerAgreementSharingsForRecordOwner() {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        System.runAs(user) {

            Account account = [SELECT Id FROM Account];

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = account.Id,
                UserId = user.Id
            );
            insert member;

            System.assertEquals(0, [SELECT count() FROM Customer_Agreement__Share]);

            insert new Customer_Agreement__c(
                Account_Name__c = account.Id
            );
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT,
                GEA_Constants.FIELD_API_NAME_CUSTOMER_AGREEMENT_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Customer_Agreement__Share]);
    }

    @isTest
    static void shouldCreateSalesPerfSharesForAccountTeamMembers() {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        Account acc = [SELECT Id FROM Account];
        Account_Sales_Performance__c salesPerf;

        System.runAs(user) {

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc.Id,
                UserId = user2.Id
            );
            insert member;

            System.assertEquals(0, [SELECT count() FROM Account_Sales_Performance__Share]);

            salesPerf = new Account_Sales_Performance__c(
                Account__c = acc.Id
            );
            insert salesPerf;
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE,
                GEA_Constants.FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(2, [SELECT count() FROM Account_Sales_Performance__Share]);
        List<Account_Sales_Performance__Share> perfShares = [SELECT Id, RowCause, UserOrGroupId, AccessLevel, ParentId FROM Account_Sales_Performance__Share];
        if (perfShares[0].RowCause == Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c) {
            System.assertEquals('Edit', perfShares[0].AccessLevel);
            System.assertEquals(salesPerf.Id, perfShares[0].ParentId);
            System.assertEquals(user2.Id, perfShares[0].UserOrGroupId);

            System.assertEquals('Owner', perfShares[1].RowCause);
            System.assertEquals('All', perfShares[1].AccessLevel);
            System.assertEquals(salesPerf.Id, perfShares[1].ParentId);
            System.assertEquals(user.Id, perfShares[1].UserOrGroupId);
        } else {
            System.assertEquals('Owner', perfShares[0].RowCause);
            System.assertEquals('All', perfShares[0].AccessLevel);
            System.assertEquals(salesPerf.Id, perfShares[0].ParentId);
            System.assertEquals(user.Id, perfShares[0].UserOrGroupId);

            System.assertEquals(Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c, perfShares[1].RowCause);
            System.assertEquals('Edit', perfShares[1].AccessLevel);
            System.assertEquals(salesPerf.Id, perfShares[1].ParentId);
            System.assertEquals(user2.Id, perfShares[1].UserOrGroupId);
        }
    }

    @isTest
    static void shouldNotCreateDuplicateSalesPerfSharingsForRecordOwner() {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];

        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = user.Id
        );
        insert psa;

        Account acc = [SELECT Id FROM Account];
        Account_Sales_Performance__c salesPerf;

        System.runAs(user) {

            AccountTeamMember member = new AccountTeamMember(
                AccountAccessLevel = 'Edit',
                AccountId = acc.Id,
                UserId = user.Id
            );
            insert member;

            System.assertEquals(0, [SELECT count() FROM Account_Sales_Performance__Share]);

            salesPerf = new Account_Sales_Performance__c(
                Account__c = acc.Id
            );
            insert salesPerf;
        }

        Test.startTest();
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE,
                GEA_Constants.FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_ACCOUNT,
                dateTimeFrom,
                dateTimeTo,
                true
            )
        );
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Account_Sales_Performance__Share]);
        Account_Sales_Performance__Share perfShare = [SELECT Id, RowCause, UserOrGroupId, AccessLevel, ParentId FROM Account_Sales_Performance__Share];
        System.assertEquals('Owner', perfShare.RowCause);
        System.assertEquals('All', perfShare.AccessLevel);
        System.assertEquals(salesPerf.Id, perfShare.ParentId);
        System.assertEquals(user.Id, perfShare.UserOrGroupId);
    }

}
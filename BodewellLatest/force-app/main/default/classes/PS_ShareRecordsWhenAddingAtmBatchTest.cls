@isTest
private class PS_ShareRecordsWhenAddingAtmBatchTest {

    private static DateTime dateTimeFrom = Datetime.now().addHours(-1);
    private static DateTime dateTimeTo = Datetime.now().addHours(1);

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

    @isTest
    static void shouldCreateShareForMeetComp() {

        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;
        Contact cnt = new Contact(FirstName = 'Joe', LastName = 'Smith', Phone = '4155551212', AccountId = acc1.id);
        insert cnt;
        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
        insert prod1;

        List<Meet_Comp__c> meetComps = new List<Meet_Comp__c>();
        for (Integer i = 0; i < 15; i++) {
            meetComps.add(
                new Meet_Comp__c(
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
                    Effective_Date__c =  Date.today().addDays(1 + i * 2),
                    Termination_Date__c =  Date.today().addDays(1 + i * 2),
                    Termination_Date_of_Competitive_Data__c =  Date.today().addDays(2 + i * 2),
                    GEA_Model__c = prod1.Id
                )
            );
        }

        insert meetComps;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        System.runAs(user) {

            System.assertEquals(15, [SELECT count() FROM Meet_Comp__Share]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user2.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_MEET_COMP, GEA_Constants.FIELD_API_NAME_MEET_COMP_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(30, [SELECT count() FROM Meet_Comp__Share]);
    }

    @isTest
    static void shouldNotCreateDuplicateShareForMeetCompOwner () {

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        Account acc1;
        Contact cnt;
        Product2 prod1;
        System.runAs(user) {
            acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
            insert acc1;
            cnt = new Contact(FirstName = 'Joe', LastName = 'Smith', Phone = '4155551212', AccountId = acc1.id);
            insert cnt;
            prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
            insert prod1;

            List<Meet_Comp__c> meetComps = new List<Meet_Comp__c>();
            for (Integer i = 0; i < 15; i++) {
                meetComps.add(
                    new Meet_Comp__c(
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
                        Effective_Date__c =  Date.today().addDays(1 + i * 2),
                        Termination_Date__c =  Date.today().addDays(1 + i * 2),
                        Termination_Date_of_Competitive_Data__c =  Date.today().addDays(2 + i * 2),
                        GEA_Model__c = prod1.Id
                    )
                );
            }

            insert meetComps;
        }

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        System.runAs(user) {

            System.assertEquals(15, [SELECT count() FROM Meet_Comp__Share]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_MEET_COMP, GEA_Constants.FIELD_API_NAME_MEET_COMP_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(15, [SELECT count() FROM Meet_Comp__Share]);
    }

    @isTest
    static void shouldCreateShareForProgramRequest () {

        Account acc1 = new Account(Name = 'Account 1');
        insert acc1;

        List<Program_Request__c> requests = new List<Program_Request__c>();
        for (Integer i = 0; i < 200; i++) {
            requests.add(
                new Program_Request__c(
                    Account__c = acc1.Id,
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3)
                )
            );
        }

        insert requests;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];


        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();

        System.runAs(user) {

            System.assertEquals(200, [SELECT count() FROM Program_Request__Share]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user2.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST, GEA_Constants.FIELD_API_NAME_PROGRAM_REQUEST_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(400, [SELECT count() FROM Program_Request__Share]);
    }

    @isTest
    static void shouldNotCreateDuplicateShareForProgramRequestOwner () {

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        Account acc1;
        System.runAs(user) {
            acc1 = new Account(Name = 'Account 1');
            insert acc1;

            List<Program_Request__c> requests = new List<Program_Request__c>();
            for (Integer i = 0; i < 200; i++) {
                requests.add(
                    new Program_Request__c(
                        Account__c = acc1.Id,
                        Start_Date__c = System.today().addDays(-3),
                        End_Date__c = System.today().addDays(3)
                    )
                );
            }

            insert requests;
        }

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();

        System.runAs(user2) {

            System.assertEquals(200, [SELECT count() FROM Program_Request__Share]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST, GEA_Constants.FIELD_API_NAME_PROGRAM_REQUEST_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(200, [SELECT count() FROM Program_Request__Share]);
    }

    @isTest
    static void shouldCreateShareForStoreProduct () {

        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;
        Schema.Location testLocation = new Schema.Location(Name = 'test');
        insert testLocation;
        RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = acc1.Id, LocationId = testLocation.Id);
        insert rs1;
        Product2 prod = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1', Brand__c = 'Amana');
        insert prod;

        List<StoreProduct> storeProducts = new List<StoreProduct>();
        for (Integer i = 0; i < 200; i++) {
            storeProducts.add(
                new StoreProduct(
                    Account__c = acc1.Id,
                    ProductId = prod.Id,
                    RetailStoreId = rs1.Id,
                    StartDate = System.today().addDays(-3),
                    EndDate = System.today().addDays(3)
                )
            );
        }

        insert storeProducts;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();

        System.runAs(user) {

            System.assertEquals(200, [SELECT count() FROM StoreProductShare]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user2.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT, GEA_Constants.FIELD_API_NAME_STORE_PRODUCT_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(400, [SELECT count() FROM StoreProductShare]);
    }

    @isTest
    static void shouldNotCreateDuplicateShareForStoreProductOwner () {

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        Account acc1;
        System.runAs(user) {
            acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
            insert acc1;
            Schema.Location testLocation = new Schema.Location(Name = 'test');
            insert testLocation;
            RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = acc1.Id, LocationId = testLocation.Id);
            insert rs1;
            Product2 prod = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1', Brand__c = 'Amana');
            insert prod;

            List<StoreProduct> storeProducts = new List<StoreProduct>();
            for (Integer i = 0; i < 200; i++) {
                storeProducts.add(
                    new StoreProduct(
                        Account__c = acc1.Id,
                        ProductId = prod.Id,
                        RetailStoreId = rs1.Id,
                        StartDate = System.today().addDays(-3),
                        EndDate = System.today().addDays(3)
                    )
                );
            }

            insert storeProducts;
        }

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();

        System.runAs(user2) {

            System.assertEquals(200, [SELECT count() FROM StoreProductShare]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT, GEA_Constants.FIELD_API_NAME_STORE_PRODUCT_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(200, [SELECT count() FROM StoreProductShare]);
    }

    @isTest
    static void shouldCreateShareForCustomerAgreement () {

        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        List<Customer_Agreement__c> customerAgreements = new List<Customer_Agreement__c>();
        for (Integer i = 0; i < 200; i++) {
            customerAgreements.add(
                new Customer_Agreement__c(
                    Account_Name__c = acc1.Id
                )
            );
        }

        insert customerAgreements;

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();

        System.runAs(user) {

            System.assertEquals(200, [SELECT count() FROM Customer_Agreement__Share]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user2.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT, GEA_Constants.FIELD_API_NAME_CUSTOMER_AGREEMENT_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(400, [SELECT count() FROM Customer_Agreement__Share]);
    }

    @isTest
    static void shouldNotCreateDuplicateShareForCustomerAgreementOwner () {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        Account acc1;
        System.runAs(user) {
            acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
            insert acc1;

            List<Customer_Agreement__c> customerAgreements = new List<Customer_Agreement__c>();
            for (Integer i = 0; i < 200; i++) {
                customerAgreements.add(
                    new Customer_Agreement__c(
                        Account_Name__c = acc1.Id
                    )
                );
            }

            insert customerAgreements;
        }

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();

        System.runAs(user2) {

            System.assertEquals(200, [SELECT count() FROM Customer_Agreement__Share]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT, GEA_Constants.FIELD_API_NAME_CUSTOMER_AGREEMENT_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(200, [SELECT count() FROM Customer_Agreement__Share]);
    }

    @isTest
    static void shouldCreateShareForAccountSalesPerformance () {

        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        insert acc1;

        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        List<Account_Sales_Performance__c> salesPerfs = new List<Account_Sales_Performance__c>();
        for (Integer i = 0; i < 200; i++) {
            salesPerfs.add(
                new Account_Sales_Performance__c(
                    Account__c = acc1.Id
                )
            );
        }

        insert salesPerfs;

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();

        System.runAs(user) {

            System.assertEquals(200, [SELECT count() FROM Account_Sales_Performance__Share]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user2.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE, GEA_Constants.FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(400, [SELECT count() FROM Account_Sales_Performance__Share]);
    }

    @isTest
    static void shouldNotCreateDuplicateShareForAccountSalesPerformanceOwner () {
        User user = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User user2 = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        Account acc1;
        System.runAs(user) {
            acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
            insert acc1;

            List<Account_Sales_Performance__c> salesPerfs = new List<Account_Sales_Performance__c>();
            for (Integer i = 0; i < 200; i++) {
                salesPerfs.add(
                    new Account_Sales_Performance__c(
                        Account__c = acc1.Id
                    )
                );
            }
            insert salesPerfs;
        }

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();

        System.runAs(user2) {

            System.assertEquals(200, [SELECT count() FROM Account_Sales_Performance__Share]);

            accountTeamMembers.add(
                new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = acc1.Id,
                    UserId = user.Id
                )
            );
            insert accountTeamMembers;
        }

        Test.startTest();

        PS_ShareNewRecordsToAtmBatch.runShareRecordsWhenAddingAtmBatch(
            GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE, GEA_Constants.FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_ACCOUNT, dateTimeFrom, dateTimeTo
        );
        Test.stopTest();

        System.assertEquals(200, [SELECT count() FROM Account_Sales_Performance__Share]);
    }

}
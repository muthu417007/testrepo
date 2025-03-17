@isTest
public class PS_RelatedAccountsPropagator_Test {

    final static String PROFILE_NAME_SYSTEM_ADMINISTRATOR = 'System Administrator';
    final static String PROFILE_NAME_BASE_SALES_CONTRACT = 'Base Sales - Contract';

    @testSetup
    static void setup() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
		Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');

        Account retailAccount = new Account(Name = 'retailAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL));
        Account retailNationalAccount = new Account(Name = 'retailNationalAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL));
        Account contractDirectAccount = new Account(
            Name = 'contractDirectAccount',
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT)
        );
    	Account contractDistributorAccount = new Account(
            Name = 'contractDistributorAccount',
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR)
        );
        Account partyAccount1 = new Account(Name = 'partyAccount1', Party_Name__c = 'partyName1', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY));
        Account partyAccount2 = new Account(Name = 'partyAccount2', Party_Name__c = 'partyName2',RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY));
        Account locationAccount = new Account(Name = 'locationAccount');
        insert new List<Account> {retailAccount, locationAccount, retailNationalAccount, contractDirectAccount, contractDistributorAccount, partyAccount1, partyAccount2};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        Id systemAdministratorProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_SYSTEM_ADMINISTRATOR].Id;
        Id baseSalesContractProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_BASE_SALES_CONTRACT].Id;


        List<User> users = new List<User>();
        users.add(
            new User(
                firstName = 'Abc',
                lastName = 'xyz',
                Alias = 'abcbc',
                profileId = systemAdministratorProfileId,
                username = 'abcabc.xyz@test.com',
                email = 'test@test.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            )
        );
        users.add(
            new User(
                firstName = 'Abcd',
                lastName = 'xyza',
                Alias = 'abcbd',
                profileId = baseSalesContractProfileId,
                username = 'abcabc.xyz2@test.com',
                email = 'test2@test.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US')
            );
        insert users;
    }

    @isTest
	static void siteShouldSetAddressOnParent () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account contractDirectAccount = [SELECT Id FROM Account WHERE Name = 'contractDirectAccount'];
        Account contractDistributorAccount = [SELECT Id FROM Account WHERE Name = 'contractDistributorAccount'];

		Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
        	BillingStreet = 'site 1 billingStreet',
            BillingCity = 'site 1 billingCity',
            ShippingStreet = 'site 1 shippingStreet',
            ShippingCity = 'site 1 shippingCity',
            Purpose__c = '',
            Purpose_Primary_Flag__c = 'SHip_to'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site2',
        	BillingStreet = 'site 2 billingStreet',
            BillingCity = 'site 2 billingCity',
            ShippingStreet = 'site 2 shippingStreet',
            ShippingCity = 'site 2 shippingCity',
            Status__c = 'A',
            Purpose__c = '',
            Purpose_Primary_Flag__c = 'SHIP_TO'
        );
		Account site3 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site3',
        	BillingStreet = 'site 3 billingStreet',
            BillingCity = 'site 3 billingCity',
            ShippingStreet = 'site 3 shippingStreet',
            ShippingCity = 'site 3 shippingCity',
            Status__c = 'A',
            Purpose__c = 'bill_to',
            Purpose_Primary_Flag__c = 'bill_to'
        );
		Account site4 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site4',
        	BillingStreet = 'site 4 billingStreet',
            BillingCity = 'site 4 billingCity',
            ShippingStreet = 'site 4 shippingStreet',
            ShippingCity = 'site 4 shippingCity',
            Status__c = 'A',
            Purpose__c = '',
            Purpose_Primary_Flag__c = 'ship_To'
        );
		Account site5 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site5',
        	BillingStreet = 'site 5 billingStreet',
            BillingCity = 'site 5 billingCity',
            ShippingStreet = 'site 5 shippingStreet',
            ShippingCity = 'site 5 shippingCity',
            Status__c = 'A',
            Purpose__c = 'sold_To',
            Purpose_Primary_Flag__c = 'sold_To'
        );

        //WHEN
        insert new List<Account>{site1, site2, site3, site4, site5};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site3.BillingStreet, contractDirectAccount.BillingStreet);
        System.assertEquals(site2.ShippingStreet, contractDirectAccount.ShippingStreet);
        System.assertEquals(site5.BillingStreet, contractDistributorAccount.BillingStreet);
        System.assertEquals(site4.ShippingStreet ,contractDistributorAccount.ShippingStreet);

        //WHEN
        site1.Status__c = 'A';
        site5.Status__c = null;
        update new List<Account>{site1, site5};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site3.BillingStreet, contractDirectAccount.BillingStreet);
        System.assertEquals(site1.ShippingStreet, contractDirectAccount.ShippingStreet);
        System.assertEquals(null, contractDistributorAccount.BillingStreet);
        System.assertEquals(site4.ShippingStreet ,contractDistributorAccount.ShippingStreet);
    }

    @isTest
	static void siteWithoutPurposePrimaryFlagShouldSetAddressOnParent () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account contractDirectAccount = [SELECT Id FROM Account WHERE Name = 'contractDirectAccount'];
        Account contractDistributorAccount = [SELECT Id FROM Account WHERE Name = 'contractDistributorAccount'];
		Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
        	BillingStreet = 'site 1 billingStreet',
            BillingCity = 'site 1 billingCity',
            ShippingStreet = 'site 1 shippingStreet',
            ShippingCity = 'site 1 shippingCity',
            Purpose__c = '',
            Purpose_Primary_Flag__c = 'ship_To'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site2',
        	BillingStreet = 'site 2 billingStreet',
            BillingCity = 'site 2 billingCity',
            ShippingStreet = 'site 2 shippingStreet',
            ShippingCity = 'site 2 shippingCity',
            Status__c = 'A',
            Purpose__c = 'sold_to'
        );
		Account site3 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site3',
        	BillingStreet = 'site 3 billingStreet',
            BillingCity = 'site 3 billingCity',
            ShippingStreet = 'site 3 shippingStreet',
            ShippingCity = 'site 3 shippingCity',
            Status__c = 'A',
            Purpose__c = 'bill_to'
        );
		Account site4 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site4',
        	BillingStreet = 'site 4 billingStreet',
            BillingCity = 'site 4 billingCity',
            ShippingStreet = 'site 4 shippingStreet',
            ShippingCity = 'site 4 shippingCity',
            Status__c = 'A',
            Purpose__c = 'ship_To'
        );
		Account site5 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site5',
        	BillingStreet = 'site 5 billingStreet',
            BillingCity = 'site 5 billingCity',
            ShippingStreet = 'site 5 shippingStreet',
            ShippingCity = 'site 5 shippingCity',
            Status__c = 'A',
            Purpose__c = 'sold_To'
        );

        //WHEN
        insert new List<Account>{site1, site2, site3, site4, site5};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site3.BillingStreet, contractDirectAccount.BillingStreet);
        System.assertEquals(site2.ShippingStreet, contractDirectAccount.ShippingStreet);
        System.assertEquals(site5.BillingStreet, contractDistributorAccount.BillingStreet);
        System.assertEquals(site4.ShippingStreet ,contractDistributorAccount.ShippingStreet);

        //WHEN
        site1.Status__c = 'A';
        site5.Status__c = null;
        update new List<Account>{site1, site5};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site3.BillingStreet, contractDirectAccount.BillingStreet);
        System.assertEquals(site1.ShippingStreet, contractDirectAccount.ShippingStreet);
        System.assertEquals(null, contractDistributorAccount.BillingStreet);
        System.assertEquals(site4.ShippingStreet ,contractDistributorAccount.ShippingStreet);
    }

    @isTest
	static void siteShouldNotSetAddressOnParent () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account contractDirectAccount = [SELECT Id FROM Account WHERE Name = 'contractDirectAccount'];

		Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
        	BillingStreet = 'site 1 billingStreet',
            BillingCity = 'site 1 billingCity',
            ShippingStreet = 'site 1 shippingStreet',
            ShippingCity = 'site 1 shippingCity',
            Purpose__c = 'bill_To',
            Purpose_Primary_Flag__c = 'bill_To'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site2',
        	BillingStreet = 'site 2 billingStreet',
            BillingCity = 'site 2 billingCity',
            ShippingStreet = 'site 2 shippingStreet',
            ShippingCity = 'site 2 shippingCity',
            Status__c = 'A',
            Purpose_Primary_Flag__c = 'dummy_flag'
        );

		Account site3 = new Account (
            ParentId = contractDirectAccount.Id,
            Name = 'site3',
        	BillingStreet = 'site 3 billingStreet',
            BillingCity = 'site 3 billingCity',
            ShippingStreet = 'site 3 shippingStreet',
            ShippingCity = 'site 3 shippingCity',
            Status__c = 'A',
            Purpose__c = 'ship_To',
            Purpose_Primary_Flag__c = 'ship_To'
        );

        //WHEN
        insert new List<Account>{site1, site2, site3};

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];

        System.assertEquals(null, contractDirectAccount.BillingStreet);
        System.assertEquals(null, contractDirectAccount.ShippingStreet);

        //WHEN
        site1.Status__c = 'A';
        contractDirectAccount.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE);

        update new List<Account>{site1, contractDirectAccount};

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];

        System.assertEquals(null, contractDirectAccount.BillingStreet,
        	'Shouldnt set billingAddress on Parent if child Account is not active, doesnt have Site record type, or proper Purpose__c');
        System.assertEquals(null, contractDirectAccount.ShippingStreet,
        	'Shouldnt set billingAddress on Parent if child Account is not active, doesnt have Site record type, or proper Purpose__c');
    }

    @isTest
	static void siteShouldRemoveAddressOnParent () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account contractDirectAccount = [SELECT Id FROM Account WHERE Name = 'contractDirectAccount'];
        Account contractDistributorAccount = [SELECT Id FROM Account WHERE Name = 'contractDistributorAccount'];
        Account partyAccount1 = [SELECT Id FROM Account WHERE Name = 'contractDistributorAccount'];
		Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
        	BillingStreet = 'site 1 billingStreet',
            BillingCity = 'site 1 billingCity',
            ShippingStreet = 'site 1 shippingStreet',
            ShippingCity = 'site 1 shippingCity',
            Purpose__c = 'ship_to , Bill_to,sOld_TO ',
            Purpose_Primary_Flag__c = 'ship_to , Bill_to,sOld_TO ',
            Status__c = 'A'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site2',
        	BillingStreet = 'site 2 billingStreet',
            BillingCity = 'site 2 billingCity',
            ShippingStreet = 'site 2 shippingStreet',
            ShippingCity = 'site 2 shippingCity',
            Status__c = 'A',
            Purpose__c = 'Where',
            Purpose_Primary_Flag__c = 'Where to buy'
        );

		Account site3 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site5',
        	BillingStreet = 'site 5 billingStreet',
            BillingCity = 'site 5 billingCity',
            ShippingStreet = 'site 5 shippingStreet',
            ShippingCity = 'site 5 shippingCity',
            Status__c = 'A',
            Purpose_Primary_Flag__c = 'sold_To'
        );

        //WHEN
        insert new List<Account>{site1, site2, site3};

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site1.BillingStreet, contractDirectAccount.BillingStreet);
        System.assertEquals(site1.ShippingStreet, contractDirectAccount.ShippingStreet);
        System.assertEquals(site3.BillingStreet, contractDistributorAccount.BillingStreet);
        System.assertEquals(site3.ShippingStreet ,contractDistributorAccount.ShippingStreet);

        //WHEN
        delete new List<Account>{site2, site3};

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site1.BillingStreet, contractDirectAccount.BillingStreet);
        System.assertEquals(site1.ShippingStreet, contractDirectAccount.ShippingStreet);
        System.assertEquals(null, contractDistributorAccount.BillingStreet);
        System.assertEquals(null, contractDistributorAccount.ShippingStreet);
    }

    @isTest
	static void siteShouldSetWhereToBuyLocator () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account contractDirectAccount = [SELECT Id FROM Account WHERE Name = 'contractDirectAccount'];
        Account contractDistributorAccount = [SELECT Id FROM Account WHERE Name = 'contractDistributorAccount'];
		Account retailNationalAccount = [SELECT Id FROM Account WHERE Name = 'retailNationalAccount'];

		Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
            Status__c = 'A',
            Purpose__c = 'Ship_To'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site2',
            Status__c = 'A',
            Purpose__c = 'Where to Buy'
        );

		Account site3 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site3',
            Status__c = 'A',
            Purpose__c = 'Where to Buy'
        );

		Account site4 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = retailNationalAccount.Id,
            Name = 'site4',
            Status__c = 'A',
            Purpose__c = 'Where to Buy'
        );

        //WHEN on insert
        insert new List<Account>{site1, site2, site3, site4};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount = [SELECT Where_To_Buy_Locator__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT Where_To_Buy_Locator__c FROM Account WHERE Name = 'contractDistributorAccount'];
        retailNationalAccount = [SELECT Where_To_Buy_Locator__c FROM Account WHERE Name = 'retailNationalAccount'];

        System.assertEquals('No', contractDirectAccount.Where_To_Buy_Locator__c, 'Shouldnt set Where_To_Buy_Locator__c on Contract Direct account');
        System.assertEquals('Yes', contractDistributorAccount.Where_To_Buy_Locator__c, 'Should set Where to Buy Locator on Contract Distributor Account');
		System.assertEquals('Yes', retailNationalAccount.Where_To_Buy_Locator__c, 'Should set Where to Buy Locator on Retail National Account');

        //WHEN on update
        site4.Purpose__c = 'Sold_To';
        update site4;
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;


        //THEN
		retailNationalAccount = [SELECT Where_To_Buy_Locator__c FROM Account WHERE Name = 'retailNationalAccount'];
        System.assertEquals('No', retailNationalAccount.Where_To_Buy_Locator__c,
        	'Should set Where to Buy Locator on Retail National Account to No when no Site child Account has Where to buy Purpose');

        //WHEN on update
        delete new List<Account>{site3, site4};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
		contractDistributorAccount = [SELECT Where_To_Buy_Locator__c FROM Account WHERE Name = 'contractDistributorAccount'];
        System.assertEquals('No', contractDistributorAccount.Where_To_Buy_Locator__c,
        	'Should set Where to Buy Locator to No on Contract Distributor Account when none of Site child accounts has Where to Buy purpose');
    }

    @isTest
	static void siteShouldSetSiteLogicFieldsOnParent () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account contractDirectAccount = [SELECT Id FROM Account WHERE Name = 'contractDirectAccount'];
        Account contractDistributorAccount = [SELECT Id FROM Account WHERE Name = 'contractDistributorAccount'];
		Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
        	Region_Name__c = 'region1',
            Invoice_Aggregators__c = 'invoice aggregators1',
            Purpose__c = 'Ship_To',
            Status__c = 'A',
            Identifying_Address__c = 'Y'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site2',
			Region_Name__c = 'region2',
            Invoice_Aggregators__c = 'invoice aggregators2',
            Status__c = 'A',
            Identifying_Address__c = 'N',
            Purpose__c = 'Where to Buy xyz'
        );
		Account site3 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site3',
		    Region_Name__c = 'region2',
            Invoice_Aggregators__c = 'invoice aggregators3',
            Purpose__c = 'Bill_To, xyz',
            Identifying_Address__c = 'Y'
        );
		Account site4 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site4',
			Region_Name__c = 'region4',
            Invoice_Aggregators__c = 'invoice aggregators4',
            Status__c = 'A',
            Purpose__c = 'Ship_To',
            Identifying_Address__c = 'Y'
        );
		Account site5 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site5',
        	Region_Name__c = 'region5',
            Invoice_Aggregators__c = 'invoice aggregators5',
            Purpose__c = 'Sold_To xyz',
            Status__c = 'A',
            Identifying_Address__c = 'N'
        );

        //WHEN on insert
        insert new List<Account> {site1, site2, site3, site4, site5};

        Map<String, String> rtByFieldName = new Map<String, String>();
        for(PS_AccountSiteLogic__mdt asl : [SELECT FieldName__c, RtToProcess__c FROM PS_AccountSiteLogic__mdt]) {
            rtByFieldName.put(asl.FieldName__c, asl.RtToProcess__c);
        }

        //Should not assert if PS_AccountSiteLogic__mdt is not configured to match test data
        if (
        	!((rtByFieldName.containsKey('Region_Name__c') && rtByFieldName.get('Region_Name__c').replace(' ','').split(';').contains(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT))
        	&& (rtByFieldName.get('Region_Name__c').replace(' ','').split(';').contains(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR))
            && (rtByFieldName.containsKey('Invoice_Aggregators__c') && rtByFieldName.get('Invoice_Aggregators__c').replace(' ','').split(';').contains(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT))
            && !(rtByFieldName.get('Invoice_Aggregators__c').replace(' ','').split(';').contains(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR)))
        ) {
            return;
        }

        //THEN
        contractDirectAccount = [SELECT Region_Name__c, Invoice_Aggregators__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT Region_Name__c, Invoice_Aggregators__c FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site1.Region_Name__c, contractDirectAccount.Region_Name__c);
        System.assertEquals(site1.Invoice_Aggregators__c, contractDirectAccount.Invoice_Aggregators__c);
        System.assertEquals(site4.Region_Name__c, contractDistributorAccount.Region_Name__c);
        System.assertEquals(null ,contractDistributorAccount.Invoice_Aggregators__c);

        //WHEN on update
        site1.Status__c = null;
        site4.Status__c = null;
        update new List<Account> {site1, site4};

        //THEN
        contractDirectAccount = [SELECT Region_Name__c, Invoice_Aggregators__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT Region_Name__c, Invoice_Aggregators__c FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site2.Region_Name__c, contractDirectAccount.Region_Name__c);
        System.assertEquals(site2.Invoice_Aggregators__c, contractDirectAccount.Invoice_Aggregators__c);
        System.assertEquals(site5.Region_Name__c, contractDistributorAccount.Region_Name__c);
        System.assertEquals(null ,contractDistributorAccount.Invoice_Aggregators__c);

        //WHEN on delete

        delete new List<Account> {site1, site2, site4, site5};

        //THEN
        contractDirectAccount = [SELECT Region_Name__c, Invoice_Aggregators__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT Region_Name__c, Invoice_Aggregators__c FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site3.Region_Name__c, contractDirectAccount.Region_Name__c);
        System.assertEquals(site3.Invoice_Aggregators__c, contractDirectAccount.Invoice_Aggregators__c);
        System.assertEquals(null, contractDistributorAccount.Region_Name__c);
        System.assertEquals(null ,contractDistributorAccount.Invoice_Aggregators__c);
    }

    @isTest
	static void siteShouldSetBrandsAllowedOnParent () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account contractDirectAccount = [SELECT Id FROM Account WHERE Name = 'contractDirectAccount'];
        Account contractDistributorAccount = [SELECT Id FROM Account WHERE Name = 'contractDistributorAccount'];

		Account site0 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
            Purpose__c = 'Ship_To something',
            Status__c = 'A',
            Identifying_Address__c = 'Y',
            Brands_Not_Allowed__c = 'Haier, GE'
        );

        Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
            Purpose__c = 'Ship_to,Sold_To',
            Status__c = 'A',
            Identifying_Address__c = 'Y',
            Brands_Not_Allowed__c = 'GE Profile Series'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site2',
            Status__c = 'A',
            Identifying_Address__c = 'N',
            Purpose__c = 'Where to Buy something',
            Brands_Not_Allowed__c = 'Hotpoint, Monogram'
        );

		Account site4 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site4',
            Status__c = 'A',
            Purpose__c = 'Ship_To, something',
            Identifying_Address__c = 'Y',
            Brands_Not_Allowed__c = 'Haier, GE'
        );

        //WHEN on insert
        insert new List<Account> {site0, site1, site2, site4};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount = [SELECT Brands_Allowed__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT Brands_Allowed__c FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assert(!contractDirectAccount.Brands_Allowed__c.split(';').contains('GE Profile Series'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('Haier'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('GE'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('Monogram'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('Hotpoint'));
        System.assert(!contractDistributorAccount.Brands_Allowed__c.split(';').contains('Haier'));
        System.assert(!contractDistributorAccount.Brands_Allowed__c.split(';').contains('GE'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('Monogram'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('Hotpoint'));

        //WHEN on update
        site1.Status__c = '';
        site1.Purpose__c = 'Ship_to';
        site4.Brands_Not_Allowed__c = '';
        update new List<Account>{site1, site4};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount = [SELECT Brands_Allowed__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT Brands_Allowed__c FROM Account WHERE Name = 'contractDistributorAccount'];
        System.assert(!contractDirectAccount.Brands_Allowed__c.split(';').contains('Haier'));
        System.assert(!contractDirectAccount.Brands_Allowed__c.split(';').contains('GE'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('Monogram'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('Hotpoint'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('GE Profile Series'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('Haier'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('GE'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('Monogram'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('Hotpoint'));

        //WHEN on delete
        delete new List<Account>{site0, site1, site2, site4};

        //THEN
        contractDirectAccount = [SELECT Brands_Allowed__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT Brands_Allowed__c FROM Account WHERE Name = 'contractDistributorAccount'];
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('Haier'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('GE'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('Monogram'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('Hotpoint'));
        System.assert(contractDirectAccount.Brands_Allowed__c.split(';').contains('GE Profile Series'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('Haier'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('GE'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('Monogram'));
        System.assert(contractDistributorAccount.Brands_Allowed__c.split(';').contains('Hotpoint'));
    }

    @isTest
	static void partyShouldPopulateFieldsOnChildren () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account contractDirectAccount = [SELECT ParentId FROM Account WHERE Name = 'contractDirectAccount'];
        Account contractDistributorAccount = [SELECT ParentId FROM Account WHERE Name = 'contractDistributorAccount'];
        Account retailAccount = [SELECT ParentId FROM Account WHERE Name = 'retailAccount'];
        Account partyAccount1 = [SELECT Party_Name__c FROM Account WHERE Name = 'partyAccount1'];
        Account partyAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'partyAccount2'];

		Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site1',
        	BillingStreet = 'site 1 billingStreet',
            BillingCity = 'site 1 billingCity',
            ShippingStreet = 'site 1 shippingStreet',
            ShippingCity = 'site 1 shippingCity',
            Purpose__c = 'Bill_To, something',
            Identifying_Address__c = 'Y',
            Status__c = 'A'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDirectAccount.Id,
            Name = 'site2',
        	BillingStreet = 'site 2 billingStreet',
            BillingCity = 'site 2 billingCity',
            ShippingStreet = 'site 2 shippingStreet',
            ShippingCity = 'site 2 shippingCity',
            Status__c = 'A',
            Purpose__c = 'Where to Buy something',
            Identifying_Address__c = 'Y'
        );

		Account site3 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site3',
        	BillingStreet = 'site 3 billingStreet',
            BillingCity = 'site 3 billingCity',
            ShippingStreet = 'site 3 shippingStreet',
            ShippingCity = 'site 3 shippingCity',
            Status__c = 'A',
            Purpose__c = 'Bill_To',
            Identifying_Address__c = 'Y'
        );

        contractDirectAccount.ParentId = partyAccount1.Id;
        contractDistributorAccount.ParentId = partyAccount1.Id;
        retailAccount.ParentId = partyAccount2.Id;
        upsert new List<Account>{site1, site2, site3, contractDirectAccount, contractDistributorAccount, retailAccount};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //WHEN
        partyAccount1.Party_Name__c = 'Party1';
        partyAccount2.Party_Name__c = 'Party2';

        site1.BillingStreet = 'Updated Billing Street 1';
        site1.Region_Name__c = 'Updated region 1';

        site2.BillingStreet = 'Updated Billing Street 2';
        site2.Region_Name__c = 'Updated region 2';

        site3.BillingStreet = 'Updated Billing Street 3';
        site3.Region_Name__c = 'Updated region 3';

        update new List<Account> {partyAccount1, partyAccount2, site1, site2, site3};
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount = [SELECT BillingStreet, Region_Name__c, Party_Name__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, Region_Name__c, Party_Name__c FROM Account WHERE Name = 'contractDistributorAccount'];
        retailAccount = [SELECT BillingStreet, Party_Name__c FROM Account WHERE Name = 'retailAccount'];

        System.assertEquals(site1.BillingStreet, contractDirectAccount.BillingStreet);
        System.assertEquals(site3.BillingStreet, contractDistributorAccount.BillingStreet);
        System.assertEquals(site1.Region_Name__c, contractDirectAccount.Region_Name__c);
        System.assertEquals(site3.Region_Name__c, contractDistributorAccount.Region_Name__c);

        System.assertEquals(partyAccount1.Party_Name__c, contractDirectAccount.Party_Name__c);
        System.assertEquals(partyAccount1.Party_Name__c, contractDistributorAccount.Party_Name__c);
        System.assertEquals(partyAccount2.Party_Name__c, retailAccount.Party_Name__c);

       	//WHEN
        delete new List<Account> {partyAccount1, partyAccount2};

        //THEN
        contractDirectAccount = [SELECT BillingStreet, Region_Name__c, Party_Name__c FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, Region_Name__c, Party_Name__c FROM Account WHERE Name = 'contractDistributorAccount'];
        retailAccount = [SELECT BillingStreet, Party_Name__c FROM Account WHERE Name = 'retailAccount'];

        System.assertEquals(null, contractDirectAccount.Party_Name__c);
        System.assertEquals(null, contractDistributorAccount.Party_Name__c);
        System.assertEquals(null, retailAccount.Party_Name__c);
    }

    @isTest
	static void partyShouldPopulateFieldsOnChildInsertAndUpdate () {
        //GIVEN
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account partyAccount1 = [SELECT Party_Name__c FROM Account WHERE Name = 'partyAccount1'];
        Account partyAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'partyAccount2'];

		Account site1 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            Name = 'site1',
            Purpose__c = 'Bill_To,test',
            Identifying_Address__c = 'Y',
            Status__c = 'A'
        );

		Account site2 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            Name = 'site2',
            Status__c = 'A',
            Purpose__c = 'Where to Buy',
            Identifying_Address__c = 'Y'
        );

		Account site3 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            Name = 'site3',
            Status__c = 'A',
            Purpose__c = 'Bill_To',
            Identifying_Address__c = 'Y'
        );

        Account retailAccount2 = new Account(Name = 'retailAccount2', ParentId = partyAccount2.Id, RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL));
        Account contractDistributorAccount2 = new Account(Name = 'contractDistributorAccount2', ParentId = partyAccount1.Id, RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR));
        Account contractDirectAccount2 = new Account(Name = 'contractDirectAccount2', ParentId = partyAccount1.Id, RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT));

        //WHEN
        insert new List<Account>{site1, site2, site3, contractDirectAccount2, contractDistributorAccount2, retailAccount2};

        //THEN
        contractDirectAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'contractDirectAccount2'];
        contractDistributorAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'contractDistributorAccount2'];
        retailAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'retailAccount2'];

        System.assertEquals(partyAccount1.Party_Name__c, contractDirectAccount2.Party_Name__c);
        System.assertEquals(partyAccount1.Party_Name__c, contractDistributorAccount2.Party_Name__c);
        System.assertEquals(partyAccount2.Party_Name__c, retailAccount2.Party_Name__c);

        //WHEN
        retailAccount2.ParentId = partyAccount1.Id;
        contractDirectAccount2.ParentId = partyAccount2.Id;
        contractDistributorAccount2.ParentId = partyAccount2.Id;

        update new List<Account> {retailAccount2, contractDirectAccount2, contractDistributorAccount2};

        //THEN
        contractDirectAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'contractDirectAccount2'];
        contractDistributorAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'contractDistributorAccount2'];
        retailAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'retailAccount2'];

        System.assertEquals(partyAccount2.Party_Name__c, contractDirectAccount2.Party_Name__c);
        System.assertEquals(partyAccount2.Party_Name__c, contractDistributorAccount2.Party_Name__c);
        System.assertEquals(partyAccount1.Party_Name__c, retailAccount2.Party_Name__c);
    }

    @isTest
    static void shouldAllowToDeleteAccount() {
        User systemAdministratorUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User baseSalesContractUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');

        List<Account> accounts = new List<Account>();

        System.runAs(systemAdministratorUser) {
            accounts.add(
                new Account(
                    RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
                    Name = 'site1',
                    Purpose__c = 'Bill_To,test',
                    Identifying_Address__c = 'Y',
                    Status__c = 'A'
                )
            );
            accounts.add(
                new Account(
                    RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
                    Name = 'site2',
                    Status__c = 'A',
                    Purpose__c = 'Bill_To',
                    Identifying_Address__c = 'Y'
                )
            );

            insert accounts;

            Set<Id> accountIds = new Set<Id>();
            for(Account acc : accounts) {
                accountIds.add(acc.Id);
            }

            delete accounts;

            List<Account> deletedAccounts = [SELECT Id, IsDeleted FROM Account WHERE Id = :accountIds ALL ROWS];
            for (Account deletedAccount : deletedAccounts) {
                System.assert(deletedAccount.IsDeleted, 'Account should be deleted by System Administrator');
            }
        }

        accounts.clear();

        System.runAs(baseSalesContractUser) {
            accounts.add(
                new Account(
                    Name = 'prospectAccountToDelete1',
                    RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PROSPECT)
                )
            );
            accounts.add(
                new Account(
                    Name = 'prospectAccountToDelete2',
                    RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PROSPECT)
                )
            );

            insert accounts;

            Set<Id> accountIds = new Set<Id>();
            for(Account acc : accounts) {
                accountIds.add(acc.Id);
            }

            delete accounts;

            List<Account> deletedAccounts = [SELECT Id, IsDeleted FROM Account WHERE Id = :accountIds ALL ROWS];
            for (Account deletedAccount : deletedAccounts) {
                System.assert(deletedAccount.IsDeleted, 'Account should be deleted by not System Administrator user');
            }
        }
    }

    @isTest
    static void shouldDisallowToDeleteAccount() {
        User baseSalesContractUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');

        Account acc = new Account(
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            Name = 'site1',
            Purpose__c = 'Bill_To,test',
            Identifying_Address__c = 'Y',
            Status__c = 'A'
        );
        System.runAs(baseSalesContractUser) {
            insert acc;

            try {
                delete acc;
            } catch (Exception ex) {
                System.assert(
                    ex.getMessage().contains(Label.PS_CANNOT_DELETE_ACCOUNT),
                    'Exception message should contain: \'' + Label.PS_CANNOT_DELETE_ACCOUNT + '\''
                );
            }
        }
    }
}
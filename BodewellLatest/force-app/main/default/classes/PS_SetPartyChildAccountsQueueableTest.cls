@isTest
private class PS_SetPartyChildAccountsQueueableTest {

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
    }

    @isTest
	static void partyShouldPopulateFieldsOnChildren() {
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

        PS_RelatedAccountsPropagator.LIMIT_PARTY_CHILD_NUMBER_TO_PROCESS_WITHOUT_QUEUABLE_IN_TRIGGER = 0;
        Test.startTest();
        update new List<Account> {partyAccount1, partyAccount2, site1, site2, site3};
        Test.stopTest();
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
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

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

        PS_RelatedAccountsPropagator.LIMIT_PARTY_CHILD_NUMBER_TO_PROCESS_WITHOUT_QUEUABLE_IN_TRIGGER = 0;
        Test.startTest();
        update new List<Account> {retailAccount2, contractDirectAccount2, contractDistributorAccount2};
        Test.stopTest();
        PS_AccountTriggerHandler.relatedAccountsPopulated = false;

        //THEN
        contractDirectAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'contractDirectAccount2'];
        contractDistributorAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'contractDistributorAccount2'];
        retailAccount2 = [SELECT Party_Name__c FROM Account WHERE Name = 'retailAccount2'];

        System.assertEquals(partyAccount2.Party_Name__c, contractDirectAccount2.Party_Name__c);
        System.assertEquals(partyAccount2.Party_Name__c, contractDistributorAccount2.Party_Name__c);
        System.assertEquals(partyAccount1.Party_Name__c, retailAccount2.Party_Name__c);
    }

}
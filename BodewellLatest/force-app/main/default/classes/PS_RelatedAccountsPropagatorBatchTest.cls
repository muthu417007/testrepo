@isTest
private class PS_RelatedAccountsPropagatorBatchTest {

    @testSetup
    static void setup() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
		Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');

        Account contractDirectAccount = new Account(
            Name = 'contractDirectAccount',
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT)
        );
    	Account contractDistributorAccount = new Account(
            Name = 'contractDistributorAccount',
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR)
        );

        insert new List<Account> {contractDirectAccount, contractDistributorAccount};
    }

    @IsTest
    static void shouldPopulateRelatedAccountInBatchContext() {
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
            Purpose__c = 'SHip_to',
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
            Purpose__c = '',
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
            Purpose__c = 'ship_To',
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
        Account site6 = new Account (
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            ParentId = contractDistributorAccount.Id,
            Name = 'site6',
            BillingStreet = 'site 6 billingStreet',
            BillingCity = 'site 6 billingCity',
            ShippingStreet = 'site 6 shippingStreet',
            ShippingCity = 'site 6 shippingCity',
            Status__c = 'A',
            Purpose__c = 'sold_To'
        );

        //WHEN
        insert new List<Account>{site1, site2, site3, site4, site5, site6};

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(null, contractDirectAccount.BillingStreet);
        System.assertEquals(null, contractDirectAccount.ShippingStreet);
        System.assertEquals(null, contractDistributorAccount.BillingStreet);
        System.assertEquals(null, contractDistributorAccount.ShippingStreet);

        //WHEN
        Test.StartTest();
        Database.executebatch(new PS_RelatedAccountsPropagatorBatch());
        Test.StopTest();

        //THEN
        contractDirectAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDirectAccount'];
        contractDistributorAccount = [SELECT BillingStreet, ShippingStreet FROM Account WHERE Name = 'contractDistributorAccount'];

        System.assertEquals(site3.BillingStreet, contractDirectAccount.BillingStreet);
        System.assertEquals(site2.ShippingStreet, contractDirectAccount.ShippingStreet);
        System.assertEquals(site5.BillingStreet, contractDistributorAccount.BillingStreet);
        System.assertEquals(site4.ShippingStreet, contractDistributorAccount.ShippingStreet);

    }

}
@isTest
public class PS_PartyRelationshipPropagator_Test {
    @testSetup
    static void setup() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
		Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
 
        Account partyAccount1 = new Account(Name = 'partyAccount1', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY));
        Account partyAccount2 = new Account(Name = 'partyAccount2', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY));
        insert new List<Account> {partyAccount1, partyAccount2};

        Account retailAccount = new Account(ParentId = partyAccount1.Id, Name = 'retailAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL));
        Account retailNationalAccount = new Account(ParentId = partyAccount1.Id, Name = 'retailNationalAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL));
        Account contractDirectAccount = new Account(ParentId = partyAccount2.Id, Name = 'contractDirectAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT));
    	Account contractDistributorAccount = new Account(ParentId = partyAccount2.Id, Name = 'contractDistributorAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR));
        insert new List<Account> {retailAccount, retailNationalAccount, contractDirectAccount, contractDistributorAccount};
    }
    
    @isTest
	static void onInsert_ShouldPopulatePartyChildAccounts () {
        //GIVEN
        Account partyAccount1 = [SELECT Id FROM Account WHERE Name = 'partyAccount1'];
        Account partyAccount2 = [SELECT Id FROM Account WHERE Name = 'partyAccount2'];
        Map<String, Account> childAccountsByName = new Map<String, Account>();
        Party_Relationship__c pr1 = new Party_Relationship__c (
        	Party__c = partyAccount1.Id,
            Status__c = 'A',
            Relationship_Type__c = 'waive freight',
            Party_Relationship_Name__c = 'party relationship Name 1',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );
        
        Party_Relationship__c pr2 = new Party_Relationship__c (
        	Party__c = partyAccount2.Id,
            Status__c = 'A',
            Relationship_Type__c = 'commercial consolidation',
            Party_Relationship_Name__c = 'party relationship Name 2',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );

        //WHEN
        insert new List<Party_Relationship__c> {pr1, pr2};

		//THEN
        for (Account a : [SELECT Name, Certified_Adv_Reseller__c, Buying_Group__c, Direct_Sales_PTS__c, Prestige_Distributor__c,
            Exclusive_GEA_Reseller__c, Commercial_Consolidation_Relationship__c, Freight__c, Handling__c FROM Account]) {
            childAccountsByName.put(a.Name, a);
        }

        System.assertEquals('waive freight', childAccountsByName.get('retailAccount').Freight__c);
        System.assertEquals('waive freight', childAccountsByName.get('retailNationalAccount').Freight__c);
        
        System.assertEquals('party relationship Name 1', childAccountsByName.get('retailAccount').Buying_Group__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Buying_Group__c);
        
		System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDirectAccount').Commercial_Consolidation_Relationship__c);
        System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDistributorAccount').Commercial_Consolidation_Relationship__c);
		System.assertEquals(null, childAccountsByName.get('contractDirectAccount').Freight__c);
        System.assertEquals(null, childAccountsByName.get('contractDistributorAccount').Freight__c);

		//WHEN
        Party_Relationship__c pr3 = new Party_Relationship__c (
        	Party__c = partyAccount1.Id,
            Relationship_Type__c = 'waive handling',
            Party_Relationship_Name__c = 'party relationship Name 3',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );
        
        Party_Relationship__c pr4 = new Party_Relationship__c (
        	Party__c = partyAccount2.Id,
            Status__c = 'A',
            Relationship_Type__c = 'Prestige GE Appliances Group',
            Party_Relationship_Name__c = 'party relationship Name 2',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );

        insert new List<Party_Relationship__c> {pr3, pr4};

        //THEN
        for (Account a : [SELECT Name, Certified_Adv_Reseller__c, Buying_Group__c, Direct_Sales_PTS__c, Prestige_Distributor__c,
            Exclusive_GEA_Reseller__c, Commercial_Consolidation_Relationship__c, Freight__c, Handling__c FROM Account]) {
            childAccountsByName.put(a.Name, a);
        }

        System.assertEquals('waive freight', childAccountsByName.get('retailAccount').Freight__c);
        System.assertEquals('waive freight', childAccountsByName.get('retailNationalAccount').Freight__c);
        
        System.assertEquals('party relationship Name 1', childAccountsByName.get('retailAccount').Buying_Group__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Buying_Group__c);
        
		System.assertEquals(false, childAccountsByName.get('contractDirectAccount').Prestige_Distributor__c);
        System.assertEquals(true, childAccountsByName.get('contractDistributorAccount').Prestige_Distributor__c);
		System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDirectAccount').Commercial_Consolidation_Relationship__c);
        System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDistributorAccount').Commercial_Consolidation_Relationship__c);
    }
    @isTest
	static void onUpdate_ShouldPopulatePartyChildAccounts () {
        //GIVEN
        Account partyAccount1 = [SELECT Id FROM Account WHERE Name = 'partyAccount1'];
        Account partyAccount2 = [SELECT Id FROM Account WHERE Name = 'partyAccount2'];
        Map<String, Account> childAccountsByName = new Map<String, Account>();

        Party_Relationship__c pr1 = new Party_Relationship__c (
        	Party__c = partyAccount1.Id,
            Relationship_Type__c = 'waive freight',
            Party_Relationship_Name__c = 'party relationship Name 1',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );
        
        Party_Relationship__c pr2 = new Party_Relationship__c (
        	Party__c = partyAccount2.Id,
            Relationship_Type__c = 'commercial consolidation',
            Party_Relationship_Name__c = 'party relationship Name 2',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );
        
        Party_Relationship__c pr3 = new Party_Relationship__c (
        	Party__c = partyAccount2.Id,
            Relationship_Type__c = 'Prestige GE Appliances Group',
            Party_Relationship_Name__c = 'party relationship Name 2',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );

        //WHEN
        insert new List<Party_Relationship__c> {pr1, pr2, pr3};
            
        for (Account a : [SELECT Name, Certified_Adv_Reseller__c, Buying_Group__c, Direct_Sales_PTS__c, Prestige_Distributor__c,
            Exclusive_GEA_Reseller__c, Commercial_Consolidation_Relationship__c, Freight__c, Handling__c FROM Account]) {
            childAccountsByName.put(a.Name, a);
        }

        //THEN
        System.assertEquals(null, childAccountsByName.get('retailAccount').Freight__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Freight__c);
        
        System.assertEquals(null, childAccountsByName.get('retailAccount').Buying_Group__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Buying_Group__c);
        
		System.assertEquals(null, childAccountsByName.get('contractDirectAccount').Commercial_Consolidation_Relationship__c);
        System.assertEquals(null, childAccountsByName.get('contractDistributorAccount').Commercial_Consolidation_Relationship__c);
		System.assertEquals(null, childAccountsByName.get('contractDirectAccount').Freight__c);
        System.assertEquals(null, childAccountsByName.get('contractDistributorAccount').Freight__c);
        
        //WHEN
        pr1.Status__c = 'A';
        pr2.Status__c = 'A';
        pr3.Status__c = 'A';
        update new List<Party_Relationship__c> {pr1, pr2, pr3};
            
        //THEN
        for (Account a : [SELECT Name, Certified_Adv_Reseller__c, Buying_Group__c, Direct_Sales_PTS__c, Prestige_Distributor__c,
            Exclusive_GEA_Reseller__c, Commercial_Consolidation_Relationship__c, Freight__c, Handling__c FROM Account]) {
            childAccountsByName.put(a.Name, a);
        }

        System.assertEquals('waive freight', childAccountsByName.get('retailAccount').Freight__c);
        System.assertEquals('waive freight', childAccountsByName.get('retailNationalAccount').Freight__c);
        
        System.assertEquals('party relationship Name 1', childAccountsByName.get('retailAccount').Buying_Group__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Buying_Group__c);
        
		System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDirectAccount').Commercial_Consolidation_Relationship__c);
        System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDistributorAccount').Commercial_Consolidation_Relationship__c);
		System.assertEquals(null, childAccountsByName.get('contractDirectAccount').Freight__c);
        System.assertEquals(null, childAccountsByName.get('contractDistributorAccount').Freight__c);
		System.assertEquals(false, childAccountsByName.get('contractDirectAccount').Prestige_Distributor__c);
        System.assertEquals(true, childAccountsByName.get('contractDistributorAccount').Prestige_Distributor__c);
        
        //WHEN
        pr1.Relationship_Role__c = 'DIRECT_SALE_PTS_GROUP_FOR';
        pr1.Relationship_Type__c = 'DIRECT_SALE_PTS_GROUP';
		pr1.Party_Relationship_Name__c = 'Direct Sales PTS';
        pr2.Relationship_Type__c = 'gea dealer exc';
        pr3.Status__c = null;
        
        update new List<Party_Relationship__c> {pr1, pr2, pr3};

        //THEN
        for (Account a : [SELECT Name, Certified_Adv_Reseller__c, Buying_Group__c, Direct_Sales_PTS__c, Prestige_Distributor__c,
            Exclusive_GEA_Reseller__c, Commercial_Consolidation_Relationship__c, Freight__c, Handling__c FROM Account]) {
            childAccountsByName.put(a.Name, a);
        }

        System.assertEquals('Yes', childAccountsByName.get('retailAccount').Direct_Sales_PTS__c);
        System.assertEquals(null, childAccountsByName.get('retailAccount').Exclusive_GEA_Reseller__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Direct_Sales_PTS__c);

		System.assertEquals(null, childAccountsByName.get('contractDirectAccount').Exclusive_GEA_Reseller__c);
        System.assertEquals('Yes', childAccountsByName.get('contractDistributorAccount').Exclusive_GEA_Reseller__c);

        System.assertEquals(null, childAccountsByName.get('retailAccount').Freight__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Freight__c);
        
        System.assertEquals(null, childAccountsByName.get('retailAccount').Buying_Group__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Buying_Group__c);
        
		System.assertEquals(null, childAccountsByName.get('contractDirectAccount').Commercial_Consolidation_Relationship__c);
        System.assertEquals(null, childAccountsByName.get('contractDistributorAccount').Commercial_Consolidation_Relationship__c);
		System.assertEquals(null, childAccountsByName.get('contractDirectAccount').Freight__c);
        System.assertEquals(null, childAccountsByName.get('contractDistributorAccount').Freight__c);
        
		System.assertEquals(false, childAccountsByName.get('contractDirectAccount').Prestige_Distributor__c);
        System.assertEquals(false, childAccountsByName.get('contractDistributorAccount').Prestige_Distributor__c);
	}
    
    @isTest
	static void onDelete_ShouldPopulatePartyChildAccounts () {
        //GIVEN
        Account partyAccount1 = [SELECT Id FROM Account WHERE Name = 'partyAccount1'];
        Account partyAccount2 = [SELECT Id FROM Account WHERE Name = 'partyAccount2'];
        Map<String, Account> childAccountsByName = new Map<String, Account>();
        Party_Relationship__c pr1 = new Party_Relationship__c (
        	Party__c = partyAccount1.Id,
            Status__c = 'A',
            Relationship_Type__c = 'waive freight',
            Party_Relationship_Name__c = 'party relationship Name 1',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );
        
        Party_Relationship__c pr2 = new Party_Relationship__c (
        	Party__c = partyAccount2.Id,
            Status__c = 'A',
            Relationship_Type__c = 'commercial consolidation',
            Party_Relationship_Name__c = 'party relationship Name 2',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );

        Party_Relationship__c pr3 = new Party_Relationship__c (
        	Party__c = partyAccount2.Id,
            Status__c = 'A',
            Relationship_Type__c = 'waive freight',
            Party_Relationship_Name__c = 'party relationship Name 2',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );
        
        insert new List<Party_Relationship__c> {pr1, pr2, pr3};

        for (Account a : [SELECT Name, Certified_Adv_Reseller__c, Buying_Group__c, Direct_Sales_PTS__c, Prestige_Distributor__c,
            Exclusive_GEA_Reseller__c, Commercial_Consolidation_Relationship__c, Freight__c, Handling__c FROM Account]) {
            childAccountsByName.put(a.Name, a);
        }

        System.assertEquals('waive freight', childAccountsByName.get('retailAccount').Freight__c);
        System.assertEquals('waive freight', childAccountsByName.get('retailNationalAccount').Freight__c);
        
        System.assertEquals('party relationship Name 1', childAccountsByName.get('retailAccount').Buying_Group__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Buying_Group__c);
        
		System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDirectAccount').Commercial_Consolidation_Relationship__c);
        System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDistributorAccount').Commercial_Consolidation_Relationship__c);
		System.assertEquals('waive freight', childAccountsByName.get('contractDirectAccount').Freight__c);
        System.assertEquals('waive freight', childAccountsByName.get('contractDistributorAccount').Freight__c);
        
        //WHEN
        delete new List<Party_Relationship__c> {pr1, pr3};

		//THEN
        for (Account a : [SELECT Name, Certified_Adv_Reseller__c, Buying_Group__c, Direct_Sales_PTS__c, Prestige_Distributor__c,
            Exclusive_GEA_Reseller__c, Commercial_Consolidation_Relationship__c, Freight__c, Handling__c FROM Account]) {
            childAccountsByName.put(a.Name, a);
        }

        System.assertEquals(null, childAccountsByName.get('retailAccount').Freight__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Freight__c);
        
        System.assertEquals(null, childAccountsByName.get('retailAccount').Buying_Group__c);
        System.assertEquals(null, childAccountsByName.get('retailNationalAccount').Buying_Group__c);
        
		System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDirectAccount').Commercial_Consolidation_Relationship__c);
        System.assertEquals('party relationship Name 2', childAccountsByName.get('contractDistributorAccount').Commercial_Consolidation_Relationship__c);
		System.assertEquals(null, childAccountsByName.get('contractDirectAccount').Freight__c);
        System.assertEquals(null, childAccountsByName.get('contractDistributorAccount').Freight__c);
    }
}
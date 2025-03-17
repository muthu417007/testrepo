@isTest
public class PS_AccountRecordTypeSetter_Test {

    @isTest
	static void shouldSetRecordTypeOnAccounts () {
    	//GIVEN
        Account retailAccount = new Account(Name = 'retailAccount', Oracle_Type__c = GEA_Constants.ORACLE_TYPE_ACCOUNT, Channel__c = GEA_Constants.ACCOUNT_CHANNEL_RETAIL);
        Account retailNationalAccount = new Account(Name = 'retailNationalAccount', Oracle_Type__c = GEA_Constants.ORACLE_TYPE_ACCOUNT, Channel__c = GEA_Constants.ACCOUNT_CHANNEL_RETAIL, National_Account_Indicator__c = 'Yes');
        Account contractDirectAccount = new Account(Name = 'contractDirectAccount', Oracle_Type__c = GEA_Constants.ORACLE_TYPE_ACCOUNT, Channel__c = GEA_Constants.ACCOUNT_CHANNEL_HQ, Market_Area_Name__c = 'Eastern Contract');
    	Account contractDistributorAccount = new Account(Name = 'contractDistributorAccount', Oracle_Type__c = GEA_Constants.ORACLE_TYPE_ACCOUNT, Channel__c = GEA_Constants.ACCOUNT_CHANNEL_HQ, Customer_Class__c = 'Apartment Replacement Distributor (ARD)');
        Account partyAccount = new Account(Name = 'partyAccount', Oracle_Type__c = GEA_Constants.ORACLE_TYPE_PARTY);
        Account siteAccount = new Account(Name = 'siteAccount', Oracle_Type__c = GEA_Constants.ORACLE_TYPE_SITE);
        
        //WHEN
        insert new List<Account> {retailAccount, retailNationalAccount, contractDirectAccount, contractDistributorAccount, partyAccount, siteAccount};
        
        Map<String, String> accountRtByName = new Map<String, String>();

        for (Account a : [SELECT Name, RecordType.DeveloperName FROM Account]) {
            accountRtByName.put(a.Name, a.RecordType.DeveloperName);
        }
        
        //THEN
		System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT, accountRtByName.get('contractDirectAccount'));
    	System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR, accountRtByName.get('contractDistributorAccount'));
        System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL, accountRtByName.get('retailAccount'));
        System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL, accountRtByName.get('retailNationalAccount'));
        System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY, accountRtByName.get('partyAccount'));
        System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE, accountRtByName.get('siteAccount'));
        
        //WHEN
        retailAccount.Channel__c = GEA_Constants.ACCOUNT_CHANNEL_CONTRACT;
        retailAccount.Customer_Class__c = 'Apartment Replacement Distributor (ARD)';
        retailNationalAccount.Channel__c = GEA_Constants.ACCOUNT_CHANNEL_CONTRACT;
        
        contractDirectAccount.Channel__c = GEA_Constants.ACCOUNT_CHANNEL_HQ;
        contractDirectAccount.National_Account_Indicator__c = 'Yes';
        contractDirectAccount.Market_Area_Name__c = '';
        contractDistributorAccount.Channel__c = GEA_Constants.ACCOUNT_CHANNEL_HQ;
        contractDistributorAccount.Customer_Class__c = '';
        
        update new List<Account> {retailAccount, retailNationalAccount, contractDirectAccount, contractDistributorAccount};
        
        //THEN
        for (Account a : [SELECT Name, RecordType.DeveloperName,channel__c,Market_Area_Name__c FROM Account]) {
            accountRtByName.put(a.Name, a.RecordType.DeveloperName);
        }
        
		System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL, accountRtByName.get('contractDirectAccount'));
    	System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL, accountRtByName.get('contractDistributorAccount'));
        System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR, accountRtByName.get('retailAccount'));
        System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT, accountRtByName.get('retailNationalAccount'));
		
		
		contractDirectAccount.channel__c=GEA_Constants.ACCOUNT_CHANNEL_INTERNATIONAL;
		
		retailAccount.channel__c=GEA_Constants.ACCOUNT_CHANNEL_NATIONAL;
		retailAccount.Market_Area_Name__c='Eastern Contract';
		
		contractDistributorAccount.channel__c=GEA_Constants.ACCOUNT_CHANNEL_NATIONAL;
		contractDistributorAccount.Market_Area_Name__c='Southern Contract';
		
		update new List<Account> {retailAccount, contractDirectAccount, contractDistributorAccount};
		for (Account a : [SELECT Name, RecordType.DeveloperName,channel__c,Market_Area_Name__c FROM Account]) {
            accountRtByName.put(a.Name, a.RecordType.DeveloperName);
        }
		
		System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL, accountRtByName.get('contractDirectAccount'));
    	System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL, accountRtByName.get('contractDistributorAccount'));
        System.assertEquals(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT, accountRtByName.get('retailAccount'));
    }
}
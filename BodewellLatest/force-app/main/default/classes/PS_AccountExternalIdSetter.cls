public class PS_AccountExternalIdSetter {
	/*Legacy Code moved from accountAfterInsertorUpdate*/
	private static Set<String> accountRecordTypesToOmmit = new Set<String> {
		GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT,
		GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR,
		GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL,
		GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL,
		GEA_Constants.RECORD_TYPE_ACCOUNT_SITE,
		GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY,
		GEA_Constants.RECORD_TYPE_ACCOUNT_PROSPECT,
		GEA_Constants.RECORD_TYPE_ACCOUNT_RESELLER_PROSPECT
	};

	public static void setExternalId (List<Account> accountinfolist) {
		if (triggerCountaccount.getRunTimes() < 2) {

			List<Account> updaccountinfo = new List<Account>();
			for (Account a1 : accountinfolist ) {
                if(accountRecordTypesToOmmit.contains(a1.Record_Type_Name__c)) {
                    continue;
                }
				Account newaccountinfo = new Account();
				newaccountinfo.id = a1.id;
				if (a1.locationid__c != NULL && a1.locationid__c != a1.Heroku_Ext_ID__c)
					newaccountinfo.Heroku_Ext_ID__c = a1.locationID__c;
				else if (a1.locationid__c == NULL)
					newaccountinfo.Heroku_Ext_ID__c = a1.id;
				updaccountinfo.add(newaccountinfo);
			}
			triggerCountaccount.setRunTimes();
			update(updaccountinfo);
		}
	}
}
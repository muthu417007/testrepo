public class PS_AccountRecordTypeSetter {
    private  Long nowTime;
    private  Integer counter;
    private  Long randomLong;
    private Boolean useCreatedDate = false;
    
    public static Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
    
    
    
    public static void setRecordTypes(Map<Id, Account> newAccountsById, Map<Id, Account> oldAccountsById) {
        Account[] accountsToUpdate = new List<Account>();
        for (Id key : newAccountsById.keySet()) {
            if (newAccountsById.get(key).Channel__c != oldAccountsById.get(key).Channel__c
                || newAccountsById.get(key).Oracle_Type__c != oldAccountsById.get(key).Oracle_Type__c
                || newAccountsById.get(key).Market_Area_Name__c != oldAccountsById.get(key).Market_Area_Name__c
                || newAccountsById.get(key).Customer_Class__c != oldAccountsById.get(key).Customer_Class__c
                || newAccountsById.get(key).National_Account_Indicator__c != oldAccountsById.get(key).National_Account_Indicator__c) {
                    accountsToUpdate.add(newAccountsById.get(key));
                }
        }
        if (!accountsToUpdate.isEmpty()) {
            setRecordTypes(accountsToUpdate);
        }
    }
    public PS_AccountRecordTypeSetter() {
        initVariables(false);
    }
    
    public PS_AccountRecordTypeSetter(Boolean useCreatedDate) {
        initVariables(useCreatedDate);
    }
    public  void setContactsGlobalIds(List<Account> Accounts) {
        for (Account acc : Accounts) {
            system.debug('@@in setContactsGlobalIds acc:'+acc.CreatedDate);
            if (String.isBlank(acc.Global_Customer_Id__c)) {
                String globalId = (useCreatedDate ?Datetime.valueOf(acc.CreatedDate).getTime() : nowTime) + '-';
                globalId += counter++ + '-';
                globalId += randomLong;
                acc.Global_Customer_Id__c = globalId;
                acc.Global_Customer_Id__pc = globalId;
            }
        }
    }
    
    private void initVariables(Boolean useCreatedDate) {
        nowTime = System.Datetime.now().getTime();
        counter = 100;
        randomLong = Crypto.getRandomLong();
        if (randomLong < 0) {
            randomLong *= -1;
        }
        this.useCreatedDate = useCreatedDate;
    }
    
    public static void setRecordTypes(List<Account> newAccounts) {
        Set<String> contractDistributorClasses = new Set<String>();
        Set<String> contractDirectClasses = new Set<String>();
        for (PS_Stored_Constants__mdt sc : [SELECT Value__c, MasterLabel FROM PS_Stored_Constants__mdt WHERE MasterLabel IN ('Contract Direct Classes', 'Contract Distributor Classes')]) {
            if (sc.MasterLabel == 'Contract Distributor Classes' && sc.value__c != null) {
                contractDistributorClasses = (Set<String>)System.JSON.deserialize(sc.value__c, Set<String>.class);
            } else if (sc.MasterLabel == 'Contract Direct Classes' && sc.value__c != null) {
                contractDirectClasses = (Set<String>)System.JSON.deserialize(sc.value__c, Set<String>.class);
            }
        }
        
        for(Account a : newAccounts) {
            if(a.Oracle_Type__c == GEA_Constants.ORACLE_TYPE_ACCOUNT) {
                if(a.Channel__c == GEA_Constants.ACCOUNT_CHANNEL_RETAIL) {
                    if (a.National_Account_Indicator__c == 'Yes' || a.Market_Area_Name__c == 'National' || a.Customer_Class__c=='National Account' || a.Customer_Class__c=='National Acct') {
                        a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL);
                    } else {
                        a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL);
                    }
                } else if (a.Channel__c == GEA_Constants.ACCOUNT_CHANNEL_CONTRACT || a.Channel__c == GEA_Constants.ACCOUNT_CHANNEL_PROCHANNEL) {
                    if (contractDistributorClasses.contains(a.Customer_Class__c)) {
                        a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR);
                    } else {
                        a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT);
                    }
                } else if (a.Channel__c == GEA_Constants.ACCOUNT_CHANNEL_INTERNATIONAL) {
                    a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL);
                } else if (a.Channel__c == GEA_Constants.ACCOUNT_CHANNEL_NATIONAL) {
                    if (a.Market_Area_Name__c == 'Eastern Contract' || a.Market_Area_Name__c == 'Western Contract') {
                        a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT);
                    } else {
                        a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL);
                    }
                } else if (a.Channel__c == GEA_Constants.ACCOUNT_CHANNEL_HQ) {
                    if (contractDistributorClasses.contains(a.Customer_Class__c)) {
                        a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR);
                    } else if ((a.Market_Area_Name__c == 'Eastern Contract' || a.Market_Area_Name__c == 'Western Contract')
                               || (contractDirectClasses.contains(a.Customer_Class__c))) {
                                   a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT);
                               } else if (a.National_Account_Indicator__c == 'Yes') {
                                   a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL);
                               } else {
                                   a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL);
                               }
                } else {
                    a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL);
                }
            } else if (a.Oracle_Type__c == GEA_Constants.ORACLE_TYPE_PARTY) {
                a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY);
            } else if (a.Oracle_Type__c == GEA_Constants.ORACLE_TYPE_SITE) {
                a.RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE);
            }
        }
    }
}
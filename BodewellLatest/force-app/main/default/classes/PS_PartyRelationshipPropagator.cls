public class PS_PartyRelationshipPropagator {

    public static void propagateToPartyChildRecordsOnInsert(List<Party_Relationship__c> prs) {
        Set<Id> partyAccountIds = new Set<Id>();

        for (Party_Relationship__c pr : prs) {
            if(pr.Party__c != null) {
                partyAccountIds.add(pr.Party__c);
            }
        }

        populateAccountFields(partyAccountIds);
    }

    public static void propagateToPartyChildRecordsOnUpdate(Map<Id, Party_Relationship__c> newPrsById, Map<Id, Party_Relationship__c> oldPrsById) {
        Set<Id> partyAccountIds = new Set<Id>();

        for (Id prId : newPrsById.keySet()) {
            if (newPrsById.get(prId).Party_Relationship_Name__c != oldPrsById.get(prId).Party_Relationship_Name__c
                || newPrsById.get(prId).Status__c != oldPrsById.get(prId).Status__c
                || newPrsById.get(prId).Relationship_Type__c != oldPrsById.get(prId).Relationship_Type__c
                || newPrsById.get(prId).Relationship_Role__c != oldPrsById.get(prId).Relationship_Role__c
                || newPrsById.get(prId).Party__c != oldPrsById.get(prId).Party__c) {

                if(newPrsById.get(prId).Party__c != null) {
                    partyAccountIds.add(newPrsById.get(prId).Party__c);
                }
                if (newPrsById.get(prId).Party__c != oldPrsById.get(prId).Party__c && oldPrsById.get(prId).Party__c != null) {
                    partyAccountIds.add(oldPrsById.get(prId).Party__c);
                }
            }
        }

        populateAccountFields(partyAccountIds);
    }

    public static void propagateToPartyChildRecordsOnPartyDelete(List<Party_Relationship__c> deletedPrsById) {
        Set<Id> partyAccountIds = new Set<Id>();

        for (Party_Relationship__c pr : deletedPrsById) {
            if(pr.Party__c != null) {
                partyAccountIds.add(pr.Party__c);
            }
        }

        populateAccountFields(partyAccountIds);
    }

    private static void populateAccountFields(Set<Id> partyAccountIds) {
        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, List<Party_Relationship__c>> prsByPartyId = new Map<Id, List<Party_Relationship__c>>();

        for (Party_Relationship__c pr : [SELECT Party__c, Status__c, Party_Relationship_Name__c, Relationship_Type__c, Relationship_Role__c
            FROM Party_Relationship__c WHERE Party__c IN :partyAccountIds AND Status__c = 'A' ORDER BY LastModifiedDate]){
            if (prsByPartyId.containsKey(pr.Party__c)) {
                prsByPartyId.get(pr.Party__c).add(pr);
            } else {
                prsByPartyId.put(pr.Party__c, new List<Party_Relationship__c>{pr});
            }
        }

        for (Account a : [SELECT ParentId, Built_In_Specialist__c, Showcase_Customer__c, RecordType.DeveloperName, Certified_Adv_Reseller__c, Buying_Group__c, Direct_Sales_PTS__c,
            Prestige_Distributor__c, Exclusive_GEA_Reseller__c, Commercial_Consolidation_Relationship__c, Freight__c, Handling__c, NMS_MC_Legal_Doc_Required__c, Map_Participation__c
            FROM Account WHERE ParentId IN :partyAccountIds AND RecordType.DeveloperName IN (:GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT, :GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR,
            :GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL, :GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL)]) {
            clearFieldValues(a);
            accountsToUpdate.add(a);

            if(!prsByPartyId.containsKey(a.ParentId)) {
                continue;
            }

            for (Party_Relationship__c pr :prsByPartyId.get(a.ParentId)) {
                if (a.RecordType.DeveloperName == GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL) {
                    if (pr.Relationship_Type__c == 'Certified Advertising Reseller') {
                        a.Certified_Adv_Reseller__c = 'Yes';
                    }
                    if (pr.Relationship_Type__c != null && pr.Relationship_Type__c.containsIgnoreCase('Showcase')) {
                        a.Showcase_Customer__c = true;
                    }
                    if (pr.Relationship_Type__c == 'BIS Select GE Appliances Group' || pr.Relationship_Type__c == 'BIS Choice GE Appliances Group') {
                        a.Built_In_Specialist__c = true;
                    }
                    if (pr.Relationship_Role__c == 'BUYING_GROUP_FOR') {
                        a.Buying_Group__c = pr.Party_Relationship_Name__c;
                    }

                    if (pr.Relationship_Role__c == 'DIRECT_SALE_PTS_GROUP_FOR'
                        && pr.Relationship_Type__c == 'DIRECT_SALE_PTS_GROUP') {
                        a.Direct_Sales_PTS__c = 'Yes';
                    }
                }

                if (a.RecordType.DeveloperName == GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR) {
                    if (pr.Relationship_Type__c == 'Prestige GE Appliances Group') {
                        a.Prestige_Distributor__c = true;
                    }
                }

                if (new Set<String>{GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR,
                    GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL}.contains(a.RecordType.DeveloperName)) {
                    if(pr.Relationship_Type__c != null && (pr.Relationship_Type__c.containsIgnoreCase('gea dealer exc') || pr.Relationship_Type__c.containsIgnoreCase('gea abd exclusive'))) {
                        a.Exclusive_GEA_Reseller__c = 'Yes';
                    } else if (pr.Relationship_Type__c != null && pr.Relationship_Type__c.containsIgnoreCase('NMS-MC Legal Doc Required')) {
                        a.NMS_MC_Legal_Doc_Required__c = true;
                    }
                }

                if (new Set<String>{GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT, GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR,
                    GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL, GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL}.contains(a.RecordType.DeveloperName)) {
                    if (pr.Relationship_Type__c == 'commercial consolidation') {
                        a.Commercial_Consolidation_Relationship__c = pr.Party_Relationship_Name__c;
                    }
                    if (pr.Relationship_Type__c != null && pr.Relationship_Type__c.containsIgnoreCase('waive freight')) {
                        a.Freight__c = pr.Relationship_Type__c;
                    }
                    if (pr.Relationship_Type__c != null && pr.Relationship_Type__c.containsIgnoreCase('waive handling')) {
                        a.Handling__c = pr.Relationship_Type__c;
                    }
                    if(pr.Relationship_Role__c == 'Map Participating Group For') {
                        a.Map_Participation__c = 'Yes';
                            
                    }
                    if (pr.Relationship_Type__c != null && pr.Relationship_Type__c.containsIgnoreCase('Monogram Reseller Group')) {
                        a.Monogram_Reseller__c = 'Yes';
                            
                    }
                    if (pr.Relationship_Type__c != null && pr.Relationship_Type__c.containsIgnoreCase('Monogram Pref Buildr')) {
                        a.Monogram_Pref_Builder__c = 'Yes';
                            
                    }
                }
            }
        }

        if(!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    private static void clearFieldValues(Account a) {
        a.Certified_Adv_Reseller__c = null;
        a.Buying_Group__c = null;
        a.Direct_Sales_PTS__c = null;
        a.Prestige_Distributor__c = false;
        a.Exclusive_GEA_Reseller__c = null;
        a.Commercial_Consolidation_Relationship__c = null;
        a.Freight__c = null;
        a.Handling__c = null;
        a.Showcase_Customer__c = false;
        a.Built_In_Specialist__c = false;
        a.NMS_MC_Legal_Doc_Required__c = false;
        a.Map_Participation__c = null;
        a.Monogram_Reseller__c = null;
        a.Monogram_Pref_Builder__c = null;
    }
}
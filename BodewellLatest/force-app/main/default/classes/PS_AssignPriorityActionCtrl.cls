public with sharing class PS_AssignPriorityActionCtrl {

    @AuraEnabled
    public static List<Id> searchRetailStores(
        List<String> locationTypes, List<String> customerClasses, List<String> buyingGroups,List<String> nationalStoreTypes, List<String> markets,
        String commercialConsolidation, String relationshipName, String relationshipRole, Boolean onlyDs, String oracleAccNumber, String relationshipType
    ) {
        Set<Id> accountIds = new Set<Id>();
        String queryArgs = '';

        Set<Id> partyAccountIds = getPartyAccountIds(relationshipName, relationshipRole, relationshipType);

        if (customerClasses != null && customerClasses.size() > 0) {
            queryArgs += 'Customer_Class__c IN :customerClasses';
        }
        
        if (String.isNotBlank(commercialConsolidation)) {
            if (String.isNotBlank(queryArgs)) {
                queryArgs += ' AND ';
            }
            queryArgs += 'Commercial_Consolidation_Relationship__c = :commercialConsolidation';
        }
        
        if (String.isNotBlank(oracleAccNumber)) { //Added by Niku as part of CCOP-90 for Oracle Account Number check
            if (String.isNotBlank(queryArgs)) {
                queryArgs += ' AND ';
            }
            String allSpaceRemoved = oracleAccNumber.replaceAll('(\\s+)', '');
            if(allSpaceRemoved.contains(',')){
                queryArgs += 'Oracle_Account_Number__c IN (\'';
                List<String> oracleAccNumbers = allSpaceRemoved.split(',');
                Integer size = oracleAccNumbers.size();
                for(String accnum :oracleAccNumbers){
                    if(size>1){
                    	queryArgs += accnum+'\',\'';
                        size--;
                    }
                    else
                    	queryArgs +=accnum+'\')';
                }
            }
            else
            	queryArgs += 'Oracle_Account_Number__c = :oracleAccNumber';
            System.debug('OAN---'+queryArgs);
        }

        if (markets != null && markets.size() > 0) {
            if (String.isNotBlank(queryArgs)) {
                queryArgs += ' AND ';
            }
            queryArgs += 'Market_Area_Region__c IN :markets';
        }

        if (buyingGroups != null && buyingGroups.size() > 0) {
            if (String.isNotBlank(queryArgs)) {
                queryArgs += ' AND ';
            }
            queryArgs += 'Buying_Group__c IN :buyingGroups';
        }
    
        if (nationalStoreTypes != null && nationalStoreTypes.size() > 0) {
            if (String.isNotBlank(queryArgs)) {
                queryArgs += ' AND ';
               
            }
            queryArgs += 'National_Account_Store_Type__c IN :nationalStoreTypes';
            
        }
        if (onlyDs != null && onlyDs) {
            String directSalesCustomerYes = 'Yes';
            if (String.isNotBlank(queryArgs )) {
                queryArgs += ' AND ';
            }
            queryArgs += 'Direct_Sales_Customer__c = :directSalesCustomerYes';
        }

        if (String.isNotBlank(relationshipName) || String.isNotBlank(relationshipRole) || String.isNotBlank(relationshipType)) {
            if (!partyAccountIds.isEmpty()) {
                if (String.isNotBlank(queryArgs)) {
                    queryArgs += ' AND ';
                }
                queryArgs += 'Id IN :partyAccountIds';
            } else {
                return new List<Id>();
            }
        }

        String retailStoreWhereClause = '';

        if (String.isNotBlank(queryArgs)) {
            String statusA = 'A';
            queryArgs += ' AND Status__c = :statusA';

            String queryString = 'SELECT Id FROM Account WHERE ' + queryArgs;
            system.debug('queryString--'+queryString);
            accountIds.addAll(
                (
                    new Map<Id, Account>(
                        (List<Account>) Database.query(queryString)
                    )
                ).keySet()
            );
            System.debug('accountIds---'+accountIds);

            retailStoreWhereClause += 'AccountId IN :accountIds';
        }

        if (locationTypes != null && locationTypes.size() > 0) {
            String locationTypesIncludesString = '(\'' + String.join(locationTypes, '\',\'') + '\')';
            if (String.isNotBlank(retailStoreWhereClause)) {
                retailStoreWhereClause += ' AND ';
            }

            retailStoreWhereClause += 'Location_Type__c INCLUDES ' + locationTypesIncludesString;
        }

        if (String.isBlank(retailStoreWhereClause)) {
            return new List<Id>();
        }

        String retailStoreQueryString = 'SELECT Id FROM RetailStore WHERE ' + retailStoreWhereClause + ' LIMIT 5000';
        List<Id> retailStoreIds = new List<Id>();

        retailStoreIds.addAll(
            (
                new Map<Id, RetailStore>(
                    (List<RetailStore>) Database.query(retailStoreQueryString)
                )
            ).keySet()
        );

        return retailStoreIds;
    }

    @AuraEnabled
    public static void createActions(List<Id> retailStoreIds, Id recordId) {
        System.enqueueJob(new PS_PriorityActionsCreatorQueueable(retailStoreIds, recordId));
    }

    @AuraEnabled
    public static Map<String, Map<String, String>> getPriorityActionValues() {
        Map<String, Map<String, String>> optionsByLabel = new Map<String, Map<String, String>>();

        for (PS_PriorityActionValues__mdt pav : [SELECT DeveloperName, PicklistValues__c FROM PS_PriorityActionValues__mdt]) {
            Map<String, String> options = new Map<String, String>();
            Set<String> picklistValues = (Set<String>)System.JSON.deserialize(pav.PicklistValues__c, Set<String>.class);
            for (String option : picklistValues) {
                options.put(option, option);
            }
            optionsByLabel.put(pav.DeveloperName, options);
        }
        optionsByLabel.put('LocationType', getLocationTypePicklistValues());
        optionsByLabel.put('nationalStoreTypes', getNationalstoreTypePicklistValues());
        return optionsByLabel;
    }

    private static Map<String, String> getLocationTypePicklistValues() {
        Map<String, String> options = new Map<String, String>();

        Schema.DescribeFieldResult fieldResult = RetailStore.Location_Type__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry value: values) {
            options.put(value.getValue(), value.getLabel());
        }

        return options;
    }

       private static Map<String, String> getNationalstoreTypePicklistValues() {
        Map<String, String> options = new Map<String, String>();

        Schema.DescribeFieldResult fieldResult =Account.National_Account_Store_Type__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry value: values) {
            options.put(value.getValue(), value.getLabel());
        }

        return options;
    }
    
    private static Set<Id> getPartyAccountIds (String relationshipName, String relationshipRole, String relationshipType) {
        Set<Id> partyAccountIds = new Set<Id>();
        if (String.isNotBlank(relationshipName) || String.isNotBlank(relationshipRole) || String.isNotBlank(relationshipType)) {
            String queryString = 'SELECT Id FROM Account WHERE ParentId IN (SELECT Party__c FROM Party_Relationship__c WHERE ';
            String partyQueryArgs = '';

            if (String.isNotBlank(relationshipName)) {
                partyQueryArgs += 'Party_Relationship_Name__c = :relationshipName';
            }

            if (String.isNotBlank(relationshipRole)) {
                if (String.isNotBlank(partyQueryArgs)) {
                    partyQueryArgs += ' AND ';
                }
                partyQueryArgs += 'Relationship_Role__c = :relationshipRole';
            }
            if (String.isNotBlank(relationshipType)) {
                if (String.isNotBlank(partyQueryArgs)) {
                    partyQueryArgs += ' AND ';
                }
                partyQueryArgs += 'Relationship_Type__c = :relationshipType';
            }

            queryString += partyQueryArgs + ')';

            partyAccountIds.addAll(
                (
                    new Map<Id, Account>(
                        (List<Account>) Database.query(queryString)
                    )
                ).keySet()
            );
        }

        return partyAccountIds;
    }

}
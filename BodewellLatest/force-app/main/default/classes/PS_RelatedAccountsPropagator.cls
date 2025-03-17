public class PS_RelatedAccountsPropagator {

    public static Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
    public static Map<Id, String> rtNameById {get {if (rtNameById == null) {
        rtNameById = new Map<Id, String>();
		for (String rtName : rtIdByName.keySet()) {
            rtNameById.put(rtIdByName.get(rtName), rtName);
        }
    	return rtNameById;
    } else return rtNameById;} set;}

    private static final Set<String> PARENT_ACCOUNT_RECORD_TYPES = new Set<String>{
        GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT, GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR,
        GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL, GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL
    };

    private static final Set<String> PARENT_ACCOUNT_RECORD_TYPES_WITHOUT_CONTRACT_DIRECT = new Set<String>{
        GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR, GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL,
        GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL
    };

    public static Integer LIMIT_SITE_ACCOUNTS_NUMBER_TO_PROCESS_WITHOUT_AXULARY_BATCH = 3000;
    public static Integer LIMIT_PARTY_CHILD_NUMBER_TO_PROCESS_WITHOUT_QUEUABLE_IN_TRIGGER = 1000;

    public static PS_AccountSiteLogic__mdt[] accountSiteLogic = [SELECT FieldName__c, RtToProcess__c FROM PS_AccountSiteLogic__mdt];
    public static PS_AccountPartyLogic__mdt[] accountPartyLogic = [SELECT FieldName__c, RtToProcess__c, DeveloperName FROM PS_AccountPartyLogic__mdt];
    public static List<PS_AccountBrand__mdt> availableBrands = [SELECT Label FROM PS_AccountBrand__mdt];

    private static Map<String, Integer> priorityByBillingPurpose = new Map<String, Integer>();
    private static Map<String, Integer> priorityByShippingPurpose = new Map<String, Integer>();
    private static Map<Integer, String> billingPurposeByPriority = new Map<Integer, String>();
    private static Map<Integer, String> shippingPurposeByPriority = new Map<Integer, String>();
    private static Set<String> availablePurposes = new Set<String>();

    private static Map<Id, PS_RelatedAccountsPropagator.PopulatedParentAccountInfo> parentAccountIdToInfoMap;
    private static Set<Id> siteParentAccountIdsToProcessInAxularyBatch;

    static {
        for (PS_AccountPurposePriority__mdt app : [SELECT Type__c, Priority__c, Label FROM PS_AccountPurposePriority__mdt]) {
            availablePurposes.add(app.label);
            if (app.Type__c == 'Shipping') {
                priorityByShippingPurpose.put(
                    app.Label.toLowerCase(),
                    (Integer) app.Priority__c
                );
                shippingPurposeByPriority.put(
                    (Integer) app.Priority__c,
                    app.Label.toLowerCase()
                );
            } else if (app.Type__c == 'Billing') {
                priorityByBillingPurpose.put(
                    app.Label.toLowerCase(),
                    (Integer) app.Priority__c
                );
                billingPurposeByPriority.put(
                    (Integer) app.Priority__c,
                    app.Label.toLowerCase()
                );
            }
        }
    }

    public static void populateCurrentAccounts(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {
        Account[] accountsToUpdate = new List<Account>();
        for (Id accountId : newAccounts.keySet()) {
            if (newAccounts.get(accountId).ParentId != oldAccounts.get(accountId).ParentId) {
                accountsToUpdate.add(newAccounts.get(accountId));
            }
        }
        if (!accountsToUpdate.isEmpty()) {
            populateCurrentAccounts(accountsToUpdate);
        }
    }

    public static void populateCurrentAccounts(List<Account> accounts) {

        Set<Id> parentIds = new Set<Id>();
        for (Account a : accounts) {
            if (a.ParentId != null) {
                parentIds.add(a.ParentId);
            }
        }

        Account[] partyParents = Database.query(buildPartyParentQuery());
        if (partyParents.isEmpty()) {
            return;
        }
        Map<Id, Account> partyParentById = new Map<Id, Account>(partyParents);

        setPartyChildAccountsOnChildInsert(accounts, partyParentById);
    }

    public static void handleAccountsOnBeforeDelete(Map<Id, Account> accounts) {
        Set<Id> partyParentIds = new Set<Id>();
        String profileName = [SELECT Name FROM Profile WHERE Id = :userinfo.getProfileId()]?.Name;
        Boolean isSystemAdministrator = profileName.contains('System Administrator');
        Set<Id> recordTypeIdsDisallowedToDelete = new Set<Id>{
            rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY),
            rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE),
            rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL),
            rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL),
            rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT),
            rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR)
        };

        for (Account a : accounts.values()) {
            if (!isSystemAdministrator && recordTypeIdsDisallowedToDelete.contains(a.RecordTypeId)) {
                a.addError(Label.PS_CANNOT_DELETE_ACCOUNT);
            } else if (a.RecordTypeId == rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY)) {
                partyParentIds.add(a.Id);
            }
        }

        clearChildAccountsOnParentDelete(partyParentIds);
    }

    public static void clearChildAccountsOnParentDelete(Set<Id> partyParentIds) {
        if (partyParentIds == null || partyParentIds.isEmpty()) {
            return;
        }

        String partyChildrenQueryString = buildPartyQuery();
        Account[] accountsToUpdate = new List<Account>();

        Map<PS_AccountPartyLogic__mdt, Set<String>> apLogicToRecordTypesMap = getApLogicToRecordTypesMap();
        for (Account ca : Database.query(partyChildrenQueryString)) {
            Boolean isFieldUpdated = false;

            for (PS_AccountPartyLogic__mdt apl : apLogicToRecordTypesMap.keySet()) {
                Set<String> recordsToProcess = apLogicToRecordTypesMap.get(apl);
                if (recordsToProcess.contains(ca.RecordType.DeveloperName)) {
                    ca.put(apl.FieldName__c, null);
                    isFieldUpdated = true;
                }
            }
            if (isFieldUpdated) {
                accountsToUpdate.add(ca);
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public static void populateRelatedAccounts(List<Account> accounts) {
        populateRelatedAccounts(new Map<Id, Account>(accounts), null, null);
    }

    public static void populateRelatedAccounts(List<Account> accounts, Set<Id> parentAccountIdsToProcessInAxularyBatch) {
        populateRelatedAccounts(new Map<Id, Account>(accounts), null, parentAccountIdsToProcessInAxularyBatch);
    }

    public static void populateRelatedAccounts(Map<Id, Account> accounts, Map<Id, Account> oldAccounts) {
        populateRelatedAccounts(accounts, oldAccounts, null);
    }

    public static void populateRelatedAccounts(Map<Id, Account> accounts, Map<Id, Account> oldAccounts, Set<Id> parentAccountIdsToProcessInAxularyBatch) {
        PS_RelatedAccountsPropagator.siteParentAccountIdsToProcessInAxularyBatch = parentAccountIdsToProcessInAxularyBatch;
        Map<Id, Account> accountsToUpdateById = new Map<Id, Account>();
        Map<Id, Account> partyParentsById = new Map<Id, Account>();
        Map<Id, List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>> siteChildrenByParentId
            = new Map<Id, List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>>();
        Map<Id, Boolean> parentIdToChildHasBillingPurposePrimaryFlagMap = new Map<Id, Boolean>();
        Map<Id, Boolean> parentIdToChildHasShippingPurposePrimaryFlagMap = new Map<Id, Boolean>();
        Set<Id> siteParentIds = new Set<Id>();
        List<Account> partyChildren = new List<Account>();

        for (Account a : accounts.values()) {
            if (a.RecordTypeId == rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE)) {
                if (a.ParentId != null) {
                    siteParentIds.add(a.ParentId);
                } if (Trigger.isExecuting && Trigger.isUpdate && oldAccounts.get(a.Id).ParentId != a.ParentId && oldAccounts.get(a.Id).ParentId != null) {
                    siteParentIds.add(oldAccounts.get(a.Id).ParentId);
                }
            } else if ((!Trigger.isExecuting || Trigger.isUpdate) && a.RecordTypeId == rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY)) {
                partyParentsById.put(a.Id, a);
            }
        }

        System.debug(LoggingLevel.DEBUG, '0: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '0: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '0: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '0: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        String siteQueryString = buildSiteQuery();

        System.debug(LoggingLevel.DEBUG, '1: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '1: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '1: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '1: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        filterSiteParentAccountIdsToProceed(siteParentIds);

        for (Account a : Database.query(siteQueryString)) {
            addSiteChildrenOrParentToUpdate(
                a,
                siteParentIds,
                parentIdToChildHasBillingPurposePrimaryFlagMap,
                parentIdToChildHasShippingPurposePrimaryFlagMap,
                siteChildrenByParentId,
                accountsToUpdateById
            );
        }

        System.debug(LoggingLevel.DEBUG, '2: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '2: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '2: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '2: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        setAccountAddresses(
            accountsToUpdateById,
            siteChildrenByParentId,
            parentIdToChildHasBillingPurposePrimaryFlagMap,
            parentIdToChildHasShippingPurposePrimaryFlagMap
        );

        System.debug(LoggingLevel.DEBUG, '3: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '3: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '3: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '3: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        setAccountSiteLogicFields(accountsToUpdateById, siteChildrenByParentId);

        siteChildrenByParentId.clear();

        System.debug(LoggingLevel.DEBUG, '4: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '4: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '4: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '4: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        if (!Trigger.isExecuting || Trigger.isUpdate) {
            Set<Id> partyParentIds = partyParentsById.keySet();
            String partyQueryString = buildPartyQuery();
            partyChildren = Database.query(partyQueryString);
            System.debug(LoggingLevel.DEBUG, 'PARTY ACCOUNT CHILDREN SIZE: ' + partyChildren.size());

            if (Trigger.isExecuting && partyChildren.size() < LIMIT_PARTY_CHILD_NUMBER_TO_PROCESS_WITHOUT_QUEUABLE_IN_TRIGGER) {
                setPartyChildAccountsOnParentUpdate(partyChildren, partyParentsById, oldAccounts, accountsToUpdateById);
            } else {
                System.enqueueJob(
                    new PS_SetPartyChildAccountsQueueable(
                        partyChildren,
                        partyParentsById,
                        oldAccounts,
                        accountsToUpdateById
                    )
                );
                return;
            }
        }

        if (!accountsToUpdateById.isEmpty()) {
            PS_AccountTriggerHandler.relatedAccountsPopulated = true;
            update accountsToUpdateById.values();
        }
    }

    public static void filterSiteParentAccountIdsToProceed(Set<Id> siteParentIds) {
        if (siteParentIds.isEmpty()) {
            return;
        }

        Set<Id> parentAccountIdsToProcessInAxularyBatch = new Set<Id>();

        List<AggregateResult> siteAccountGroupedResults = [
            SELECT ParentId, COUNT(Id) ChildSize
            FROM Account
            WHERE ParentId IN :siteParentIds
            GROUP BY ParentId
            ORDER BY COUNT(Id) DESC
        ];

        Integer resultCount = 0;

        Map<Id, Integer> parentAccountIdToChildSizeMap = new Map<Id, Integer>();
        Integer totalChildCount = 0;


        for (AggregateResult sagr : siteAccountGroupedResults) {
            Id parentId = (Id) sagr.get('ParentId');
            Integer childSize = (Integer) sagr.get('ChildSize');
            parentAccountIdToChildSizeMap.put(parentId, childSize);
            totalChildCount += childSize;

            resultCount++;
        }

        if (totalChildCount > LIMIT_SITE_ACCOUNTS_NUMBER_TO_PROCESS_WITHOUT_AXULARY_BATCH) {
            for (Id parentAccountId : parentAccountIdToChildSizeMap.keySet()) {
                totalChildCount -= parentAccountIdToChildSizeMap.get(parentAccountId);
                parentAccountIdsToProcessInAxularyBatch.add(parentAccountId);
                siteParentIds.remove(parentAccountId);
                if (totalChildCount <= LIMIT_SITE_ACCOUNTS_NUMBER_TO_PROCESS_WITHOUT_AXULARY_BATCH) {
                    break;
                }
            }
        }

        if (PS_RelatedAccountsPropagator.siteParentAccountIdsToProcessInAxularyBatch != null) {
            PS_RelatedAccountsPropagator.siteParentAccountIdsToProcessInAxularyBatch.addAll(parentAccountIdsToProcessInAxularyBatch);
        }
    }

    public static void populateAddressesOnParentAccount(
        Map<Id, Account> accounts,
        Map<Id, PS_RelatedAccountsPropagator.PopulatedParentAccountInfo> accountInfoMap
    ) {
        PS_RelatedAccountsPropagator.parentAccountIdToInfoMap = accountInfoMap;
        Map<Id, Account> accountsToUpdateById = new Map<Id, Account>();

        Map<Id, List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>> siteChildrenByParentId
            = new Map<Id, List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>>();

        Map<Id, Boolean> parentIdToChildHasBillingPurposePrimaryFlagMap = new Map<Id, Boolean>();
        Map<Id, Boolean> parentIdToChildHasShippingPurposePrimaryFlagMap = new Map<Id, Boolean>();
        Set<Id> siteParentIds = new Set<Id>();



        for (Account a : accounts.values()) {
            if (a.RecordTypeId == rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE)) {
                if (a.ParentId != null) {
                    siteParentIds.add(a.ParentId);
                    if (!parentAccountIdToInfoMap.containsKey(a.ParentId)) {
                        parentAccountIdToInfoMap.put(
                            a.parentId,
                            new PS_RelatedAccountsPropagator.PopulatedParentAccountInfo(a.parentId)
                        );
                    }
                }
            }
        }

        System.debug(LoggingLevel.DEBUG, '0: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '0: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '0: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '0: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        for (Account a : accounts.values()) {
            addSiteChildrenOrParentToUpdate(
                a,
                siteParentIds,
                parentIdToChildHasBillingPurposePrimaryFlagMap,
                parentIdToChildHasShippingPurposePrimaryFlagMap,
                siteChildrenByParentId,
                accountsToUpdateById
            );
        }

        System.debug(LoggingLevel.DEBUG, '1: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '1: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '1: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '1: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        setAccountAddresses(
            accountsToUpdateById,
            siteChildrenByParentId,
            parentIdToChildHasBillingPurposePrimaryFlagMap,
            parentIdToChildHasShippingPurposePrimaryFlagMap
        );

        System.debug(LoggingLevel.DEBUG, '2: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '2: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '2: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '2: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        setAccountSiteLogicFields(accountsToUpdateById, siteChildrenByParentId);

        siteChildrenByParentId.clear();

        System.debug(LoggingLevel.DEBUG, '3: HEAP SIZE: ' + Limits.getHeapSize());
        System.debug(LoggingLevel.DEBUG, '3: LIMIT HEAP SIZE: ' + Limits.getLimitHeapSize());
        System.debug(LoggingLevel.DEBUG, '3: CPU TIME: ' + Limits.getCpuTime());
        System.debug(LoggingLevel.DEBUG, '3: LIMIT CPU TIME: ' + Limits.getLimitCpuTime());

        if (!accountsToUpdateById.isEmpty()) {
            PS_AccountTriggerHandler.relatedAccountsPopulated = true;
            update accountsToUpdateById.values();
        }
    }

    private static void addSiteChildrenOrParentToUpdate(
        Account a, Set<Id> siteParentIds,
        Map<Id, Boolean> parentIdToChildHasBillingPurposePrimaryFlagMap,
        Map<Id, Boolean> parentIdToChildHasShippingPurposePrimaryFlagMap,
        Map<Id, List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>> siteChildrenByParentId,
        Map<Id, Account> accountsToUpdateById
    ) {
        String currentSiteChildBillingPurpose;
        String currentSiteChildShippingPurpose;
        String currentSiteChildBillingPurposePrimaryFlag;
        String currentSiteChildShippingPurposePrimaryFlag;
        Boolean childHasAStatus;
        if (!siteParentIds.contains(a.Id) && a.parentId != null && a.RecordTypeId == rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_SITE)) {
            childHasAStatus = a.Status__c == 'A';

            if (!parentIdToChildHasBillingPurposePrimaryFlagMap.containsKey(a.ParentId)) {
                parentIdToChildHasBillingPurposePrimaryFlagMap.put(a.parentId, false);
            }

            if (!parentIdToChildHasShippingPurposePrimaryFlagMap.containsKey(a.ParentId)) {
                parentIdToChildHasShippingPurposePrimaryFlagMap.put(a.parentId, false);
            }

            if (String.isNotBlank(a.Purpose__c)) {
                currentSiteChildBillingPurpose = extractPurpose(a.Purpose__c, billingPurposeByPriority);
                currentSiteChildShippingPurpose = extractPurpose(a.Purpose__c, shippingPurposeByPriority);
            }

            if (String.isNotBlank(a.Purpose_Primary_Flag__c)) {
                currentSiteChildBillingPurposePrimaryFlag = extractPurpose(a.Purpose_Primary_Flag__c, billingPurposeByPriority);
                currentSiteChildShippingPurposePrimaryFlag = extractPurpose(a.Purpose_Primary_Flag__c, shippingPurposeByPriority);

                Boolean hasBillingPurposePrimaryFlag = (
                    priorityByBillingPurpose.containsKey(currentSiteChildBillingPurposePrimaryFlag) &&
                    childHasAStatus
                );

                Boolean hasShippingPurposePrimaryFlag = (
                    priorityByShippingPurpose.containsKey(currentSiteChildShippingPurposePrimaryFlag) &&
                    childHasAStatus
                );

                if (hasBillingPurposePrimaryFlag && parentIdToChildHasBillingPurposePrimaryFlagMap.get(a.ParentId) == false) {
                    parentIdToChildHasBillingPurposePrimaryFlagMap.put(a.parentId, true);
                }

                if (hasShippingPurposePrimaryFlag && parentIdToChildHasShippingPurposePrimaryFlagMap.get(a.ParentId) == false) {
                    parentIdToChildHasShippingPurposePrimaryFlagMap.put(a.parentId, true);
                }
            }

            PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper siteAccountWithPurposes
                = new PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper(
                a,
                currentSiteChildBillingPurpose,
                currentSiteChildShippingPurpose,
                currentSiteChildBillingPurposePrimaryFlag,
                currentSiteChildShippingPurposePrimaryFlag
            );

            if (siteChildrenByParentId.containsKey(a.ParentId)) {
                siteChildrenByParentId.get(a.ParentId).add(
                    siteAccountWithPurposes
                );
            } else {
                siteChildrenByParentId.put(
                    a.parentId,
                    new List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>{siteAccountWithPurposes}
                );
            }
        } else if (siteParentIds.contains(a.Id)) {
            accountsToUpdateById.put(a.Id, a);
        }
    }

    private static String buildSiteQuery() {
        String queryString = 'SELECT ';

        for (PS_AccountSiteLogic__mdt asl : accountSiteLogic) {
            queryString += asl.FieldName__c + ', ';
        }

        queryString += 'BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, ShippingState, '
                       + 'ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, Brands_Not_Allowed__c, Where_To_Buy_Locator__c, Identifying_Address__c, '
                       + 'RecordType.DeveloperName, RecordType.Name, ParentId, Parent.RecordTypeId, BillingAddress, Purpose__c, Purpose_Primary_Flag__c, Status__c '
                       + 'FROM Account WHERE ParentId IN :siteParentIds OR Id IN :siteParentIds ORDER BY LastModifiedDate DESC';

        return queryString;
    }

    private static String buildPartyQuery() {
        String queryString = 'SELECT ';

        for (PS_AccountPartyLogic__mdt apl : accountPartyLogic) {
            queryString += apl.FieldName__c + ', ';
        }

        queryString += 'RecordType.DeveloperName, ParentId, Parent.RecordTypeId '
                       + 'FROM Account WHERE parentId IN :partyParentIds ORDER BY LastModifiedDate DESC';

        return queryString;
    }

    private static String buildPartyParentQuery() {
        String queryString = 'SELECT ';

        for (PS_AccountPartyLogic__mdt apl : accountPartyLogic) {
            queryString += apl.FieldName__c + ', ';
        }

        queryString += 'RecordType.DeveloperName '
                       + 'FROM Account WHERE Id IN :parentIds AND RecordType.DeveloperName = \'' + GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY + '\' ORDER BY LastModifiedDate DESC';

        return queryString;
    }

    private static void setAccountAddresses (
        Map<Id, Account> parentAccountsById,
        Map<Id, List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>> siteChildrenByParentId,
        Map<Id, Boolean> parentIdToChildHasBillingPurposePrimaryFlagMap,
        Map<Id, Boolean> parentIdToChildHasShippingPurposePrimaryFlagMap
    ) {
        for (Id parentId : parentAccountsById.keySet()) {
            Integer watermarkBilling = 0;
            Integer watermarkShipping = 0;
            Account pa = parentAccountsById.get(parentId);

            pa.BillingStreet = null;
            pa.BillingCity = null;
            pa.BillingState = null;
            pa.BillingPostalCode = null;
            pa.BillingCountry = null;
            pa.BillingLatitude = null;
            pa.BillingLongitude = null;
            pa.ShippingStreet = null;
            pa.ShippingCity = null;
            pa.ShippingState = null;
            pa.ShippingPostalCode = null;
            pa.ShippingCountry = null;
            pa.ShippingLatitude = null;
            pa.ShippingLongitude = null;

            // This variable uses in PS_RelatedAccountsAuxiliaryBatch batch context only
            PS_RelatedAccountsPropagator.PopulatedParentAccountInfo parentAccountInfo;
            if (parentAccountIdToInfoMap != null && parentAccountIdToInfoMap.containsKey(parentId)) {
                parentAccountInfo = parentAccountIdToInfoMap.get(parentId);
            }

            if (parentAccountInfo == null || (parentAccountInfo != null && !parentAccountInfo.hasWhereToBuyLocator)) {
                pa.Where_To_Buy_Locator__c = 'No';
            }

            if (!siteChildrenByParentId.containsKey(parentId)) {
                continue;
            }

            Boolean childHasBillingPurposePrimaryFlag = parentIdToChildHasBillingPurposePrimaryFlagMap.get(parentId);
            Boolean childHasShippingPurposePrimaryFlag = parentIdToChildHasShippingPurposePrimaryFlagMap.get(parentId);

            for (PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper caWrapper : siteChildrenByParentId.get(parentId)) {
                Account ca = caWrapper.siteAccount;

                if (parentAccountInfo == null || (parentAccountInfo != null && !parentAccountInfo.hasWhereToBuyLocator)) {
                    setWhereToBuyLocator(pa, ca, parentAccountInfo);
                }

                Boolean addressesCanBePopulated = (
                    ca.Status__c == 'A'
                    && (String.isNotBlank(ca.Purpose__c) || String.isNotBlank(ca.Purpose_Primary_Flag__c))
                    && PARENT_ACCOUNT_RECORD_TYPES.contains(pa.RecordType.DeveloperName)
                );

                if (addressesCanBePopulated) {
                    Boolean skipBillingAddressFillingIn = (
                        childHasBillingPurposePrimaryFlag &&
                        String.isBlank(caWrapper.billingPurposePrimaryFlag)
                    );

                    String billingPurpose = String.isNotBlank(caWrapper.billingPurposePrimaryFlag)
                        ? caWrapper.billingPurposePrimaryFlag
                        : caWrapper.billingPurpose;

                    Boolean billingAddressShouldBePopualted = (
                        !skipBillingAddressFillingIn
                        && priorityByBillingPurpose.containsKey(billingPurpose)
                        && priorityByBillingPurpose.get(billingPurpose) > watermarkBilling
                    );

                    // This condition uses in PS_RelatedAccountsAuxiliaryBatch batch context only
                    if (billingAddressShouldBePopualted && parentAccountInfo != null && parentAccountInfo.prioritySiteAccountIdByBillingPurpose != null) {
                        billingAddressShouldBePopualted = !parentAccountInfo.hasHigherPriorityByBillingPurposeThan(
                            ca, childHasBillingPurposePrimaryFlag, priorityByBillingPurpose.get(billingPurpose)
                        );
                    }

                    if (billingAddressShouldBePopualted) {
                        watermarkBilling = priorityByBillingPurpose.get(billingPurpose);
                        pa.BillingStreet = ca.BillingStreet;
                        pa.BillingCity = ca.BillingCity;
                        pa.BillingState = ca.BillingState;
                        pa.BillingPostalCode = ca.BillingPostalCode;
                        pa.BillingCountry = ca.BillingCountry;
                        pa.BillingLatitude = ca.BillingLatitude;
                        pa.BillingLongitude = ca.BillingLongitude;

                        if (parentAccountInfo != null) {
                            parentAccountInfo.setPrioritySiteAccountInfoByBillingPurpose(
                                ca, childHasBillingPurposePrimaryFlag, priorityByBillingPurpose.get(billingPurpose)
                            );
                        }
                    }

                    Boolean skipShippingAddressFillingIn = (
                        childHasShippingPurposePrimaryFlag &&
                        String.isBlank(caWrapper.shippingPurposePrimaryFlag)
                    );

                    String shippingPurpose = String.isNotBlank(caWrapper.shippingPurposePrimaryFlag)
                        ? caWrapper.shippingPurposePrimaryFlag
                        : caWrapper.shippingPurpose;

                    Boolean shippingAddressShouldBePopualted = (
                        !skipShippingAddressFillingIn
                        && priorityByShippingPurpose.containsKey(shippingPurpose)
                        && priorityByShippingPurpose.get(shippingPurpose) > watermarkShipping
                    );

                    // This condition uses in PS_RelatedAccountsAuxiliaryBatch batch context only
                    if (shippingAddressShouldBePopualted && parentAccountInfo != null && parentAccountInfo.prioritySiteAccountIdByShippingPurpose != null) {
                        shippingAddressShouldBePopualted = !parentAccountInfo.hasHigherPriorityByShippingPurposeThan(
                            ca, childHasShippingPurposePrimaryFlag, priorityByShippingPurpose.get(shippingPurpose)
                        );
                    }

                    if (shippingAddressShouldBePopualted) {
                        watermarkShipping = priorityByShippingPurpose.get(shippingPurpose);
                        pa.ShippingStreet = ca.ShippingStreet;
                        pa.ShippingCity = ca.ShippingCity;
                        pa.ShippingState = ca.ShippingState;
                        pa.ShippingPostalCode = ca.ShippingPostalCode;
                        pa.ShippingCountry = ca.ShippingCountry;
                        pa.ShippingLatitude = ca.ShippingLatitude;
                        pa.ShippingLongitude = ca.ShippingLongitude;

                        if (parentAccountInfo != null) {
                            parentAccountInfo.setPrioritySiteAccountInfoBySippingPurpose(
                                ca, childHasShippingPurposePrimaryFlag, priorityByShippingPurpose.get(shippingPurpose)
                            );
                        }
                    }
                }
            }
        }
    }

    private static void setWhereToBuyLocator (Account pa, Account ca, PS_RelatedAccountsPropagator.PopulatedParentAccountInfo parentAccountInfo) {
        if (pa.Where_To_Buy_Locator__c == 'No' && ca.Status__c == 'A' && ca.Purpose__c != null  && ca.Purpose__c.containsIgnoreCase('Where to Buy')
                &&  PARENT_ACCOUNT_RECORD_TYPES_WITHOUT_CONTRACT_DIRECT.contains(pa.RecordType.DeveloperName)) {
            pa.Where_To_Buy_Locator__c = 'Yes';

            if (parentAccountInfo != null) {
                parentAccountInfo.hasWhereToBuyLocator = true;
            }
        }
    }

    private static void setAccountSiteLogicFields (
        Map<Id, Account> parentAccountsById,
        Map<Id, List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>> siteChildrenByParentId
    ) {
        Map<Id, PS_RelatedAccountsPropagator.PrioritySiteAccount> priorityChildByParentId = new Map<Id, PS_RelatedAccountsPropagator.PrioritySiteAccount>();
        priorityChildByParentId = getPriorityChildAccounts(parentAccountsById, siteChildrenByParentId);
        clearSiteLogicFields(parentAccountsById, priorityChildByParentId);

        Map<PS_AccountSiteLogic__mdt, Set<String>> asLogicToRecordTypesMap = getAsLogicToRecordTypesMap();

        for (Id parentId : priorityChildByParentId.keySet()) {
            PS_RelatedAccountsPropagator.PrioritySiteAccount prioritySite = priorityChildByParentId.get(parentId);
            Account pa = parentAccountsById.get(parentId);
            Account priorityAccountForSiteLogic = prioritySite.priorityAccountForSiteLogic;
            Account priorityAccountForBrandsAllowed = prioritySite.priorityAccountForBrandsAllowed;

            if (priorityAccountForSiteLogic != null) {
                for (PS_AccountSiteLogic__mdt asl : asLogicToRecordTypesMap.keySet()) {
                    Set<String> recordsToProcess = asLogicToRecordTypesMap.get(asl);
                    if (recordsToProcess.contains(pa.RecordType.DeveloperName)) {
                        pa.put(asl.FieldName__c, priorityAccountForSiteLogic.get(asl.FieldName__c));
                    }
                }
            }
            if (priorityAccountForBrandsAllowed != null) {
                setAllowedBrandsOnParent(priorityAccountForBrandsAllowed, pa);
            }
        }
    }

    public static void setPartyChildAccountsOnParentUpdate(
        List<Account> partyChildAccounts, Map<Id, Account> partyAccountsById,
        Map<Id, Account> oldAccounts, Map<Id, Account> accountsToUpdateById
    ) {
        if (partyChildAccounts.isEmpty()) {
            return;
        }

        Map<PS_AccountPartyLogic__mdt, Set<String>> apLogicToRecordTypesMap = getApLogicToRecordTypesMap();

        for (Account ca : partyChildAccounts) {
            if (accountsToUpdateById.containsKey(ca.Id)) {
                ca = accountsToUpdateById.get(ca.Id);
            }

            Account pa = partyAccountsById.get(ca.ParentId);
            Boolean accountUpdated = false;

            for (PS_AccountPartyLogic__mdt apl : apLogicToRecordTypesMap.keySet()) {
                Set<String> recordsToProcess = apLogicToRecordTypesMap.get(apl);
                if (rtNameById.containsKey(ca.RecordTypeId) && recordsToProcess.contains(rtNameById.get(ca.RecordTypeId))) {
                    if (!Trigger.isExecuting || (pa.get(apl.FieldName__c) != oldAccounts.get(pa.Id).get(apl.FieldName__c))) {
                        ca.put(apl.FieldName__c, pa.get(apl.FieldName__c));
                        accountUpdated = true;
                    }
                }
            }

            if (accountUpdated) {
                accountsToUpdateById.put(ca.Id, ca);
            }
        }
    }

    public static void setPartyChildAccountsOnChildInsert(List<Account> partyChildAccounts, Map<Id, Account> partyParentAccountById) {
        Map<PS_AccountPartyLogic__mdt, Set<String>> apLogicToRecordTypesMap = getApLogicToRecordTypesMap();

        for (Account ca : partyChildAccounts) {
            Account pa = partyParentAccountById.get(ca.ParentId);

            for (PS_AccountPartyLogic__mdt apl : apLogicToRecordTypesMap.keySet()) {
                Set<String> recordsToProcess = apLogicToRecordTypesMap.get(apl);
                if (rtNameById.containsKey(ca.RecordTypeId) && recordsToProcess.contains(rtNameById.get(ca.RecordTypeId))) {
                    ca.put(apl.FieldName__c, pa.get(apl.FieldName__c));
                }
            }
        }
    }

    private static void clearSiteLogicFields (
        Map<Id, Account> parentAccountsById, Map<Id, PS_RelatedAccountsPropagator.PrioritySiteAccount> priorityChildByParentId
    ) {
        Map<PS_AccountSiteLogic__mdt, Set<String>> asLogicToRecordTypesMap = getAsLogicToRecordTypesMap();

        for (Id parentId : parentAccountsById.keySet()) {

            // This variable uses in PS_RelatedAccountsAuxiliaryBatch batch context only
            PS_RelatedAccountsPropagator.PopulatedParentAccountInfo parentAccountInfo;
            if (parentAccountIdToInfoMap != null && parentAccountIdToInfoMap.containsKey(parentId)) {
                parentAccountInfo = parentAccountIdToInfoMap.get(parentId);
            }

            Boolean siteLogicFieldsShouldBeClear = false;

            if (!priorityChildByParentId.containsKey(parentId) || priorityChildByParentId.get(parentId).priorityAccountForSiteLogic == null) {
                siteLogicFieldsShouldBeClear = true;
                if (parentAccountInfo != null && parentAccountInfo.prioritySiteAccountIdForPopulatingSiteLogicFields != null) {
                    siteLogicFieldsShouldBeClear = false;
                }
            }

            Boolean setAllBrandsOnParent = false;

            if (!priorityChildByParentId.containsKey(parentId) || priorityChildByParentId.get(parentId).priorityAccountForBrandsAllowed == null) {
                setAllBrandsOnParent = true;
                if (parentAccountInfo != null && parentAccountInfo.prioritySiteAccountIdForPopulatingBrandsAllowed != null) {
                    setAllBrandsOnParent = false;
                }
            }

            Account pa = parentAccountsById.get(ParentId);

            if (siteLogicFieldsShouldBeClear) {
                for (PS_AccountSiteLogic__mdt asl : asLogicToRecordTypesMap.keySet()) {
                    Set<String> recordsToProcess = asLogicToRecordTypesMap.get(asl);
                    if (recordsToProcess.contains(pa.RecordType.DeveloperName)) {
                        pa.put(asl.FieldName__c, null);
                    }
                }
            }

            if (setAllBrandsOnParent) {
                setAllowedBrandsOnParent(null, pa);
            }
        }
    }

    private static Map<Id, PS_RelatedAccountsPropagator.PrioritySiteAccount> getPriorityChildAccounts (
        Map<Id, Account> parentAccountsById,
        Map<Id, List<PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper>> siteChildrenByParentId
    ) {
        Map<Id, PS_RelatedAccountsPropagator.PrioritySiteAccount> priorityChildByParentId = new Map<Id, PS_RelatedAccountsPropagator.PrioritySiteAccount>();
        for (Id parentId : parentAccountsById.keySet()) {
            // This variable uses in PS_RelatedAccountsAuxiliaryBatch batch context only
            PS_RelatedAccountsPropagator.PopulatedParentAccountInfo parentAccountInfo;
            if (parentAccountIdToInfoMap != null && parentAccountIdToInfoMap.containsKey(parentId)) {
                parentAccountInfo = parentAccountIdToInfoMap.get(parentId);
            }


            Integer watermark = 0;
            Integer watermarkBrandsAllowed = 0;

            if (!siteChildrenByParentId.containsKey(parentId)) {
                continue;
            }

            for (PS_RelatedAccountsPropagator.SiteAccountWithPurposesWrapper caWrapper : siteChildrenByParentId.get(parentId)) {
                Account ca = caWrapper.siteAccount;
                Integer priority = getSiteLogicPriority(ca);
                Integer brandsAllowedPriority = getBrandsAllowedPriority(ca);

                if (priority != 0 && (!priorityChildByParentId.containsKey(parentId) || priority > watermark)) {
                    watermark = priority;

                    Boolean priorityChildShouldBePut = true;

                    if (parentAccountInfo != null && parentAccountInfo.prioritySiteAccountIdForPopulatingSiteLogicFields != null) {
                        priorityChildShouldBePut = !parentAccountInfo.hasHigherPriorityForPopulatingSiteLogicFieldsThan(ca, priority);
                    }

                    if (priorityChildShouldBePut) {
                        if (priorityChildByParentId.containsKey(parentId)) {
                            priorityChildByParentId.get(parentId).priorityAccountForSiteLogic = ca;
                        } else {
                            PS_RelatedAccountsPropagator.PrioritySiteAccount prioritySite = new PS_RelatedAccountsPropagator.PrioritySiteAccount();
                            prioritySite.priorityAccountForSiteLogic = ca;
                            priorityChildByParentId.put(parentId, prioritySite);
                        }

                        if (parentAccountInfo != null) {
                            parentAccountInfo.setPrioritySiteAccountInfoForPopulatingSiteLogicFields(ca, priority);
                        }
                    }
                }

                if (brandsAllowedPriority != 0 && (!priorityChildByParentId.containsKey(parentId) || brandsAllowedPriority > watermarkBrandsAllowed)) {
                    watermarkBrandsAllowed = brandsAllowedPriority;

                    Boolean priorityChildShouldBePut = true;

                    if (parentAccountInfo != null && parentAccountInfo.prioritySiteAccountIdForPopulatingBrandsAllowed != null) {
                        priorityChildShouldBePut = !parentAccountInfo.hasHigherPriorityForPopulatingBrandsAllowedThan(ca, brandsAllowedPriority);
                    }

                    if (priorityChildShouldBePut) {
                        if (priorityChildByParentId.containsKey(parentId)) {
                            priorityChildByParentId.get(parentId).priorityAccountForBrandsAllowed = ca;
                        } else {
                            PS_RelatedAccountsPropagator.PrioritySiteAccount prioritySite = new PS_RelatedAccountsPropagator.PrioritySiteAccount();
                            prioritySite.priorityAccountForBrandsAllowed = ca;
                            priorityChildByParentId.put(parentId, prioritySite);
                        }

                        if (parentAccountInfo != null) {
                            parentAccountInfo.setPrioritySiteAccountInfoForPopulatingBrandsAllowed(ca, brandsAllowedPriority);
                        }
                    }
                }
            }
        }
        return priorityChildByParentId;
    }

    private static Integer getSiteLogicPriority (Account ca) {
        if (ca.Status__c == 'A' && ca.Identifying_Address__c == 'Y') {
            return 4;
        } else if (ca.Status__c == 'A' && ca.Identifying_Address__c == 'N') {
            return 3;
        } else if (ca.Status__c != 'A' && ca.Identifying_Address__c == 'Y') {
            return 2;
        } else if (ca.Status__c != 'A' && ca.Identifying_Address__c == 'N') {
            return 1;
        } else {
            return 0;
        }
    }

    private static Integer getBrandsAllowedPriority (Account ca) {
        String soldToPurpose = 'SOLD_TO';
        String currentPurpose = ca.Purpose__c;
        Boolean hasSoldToPurpose = (
            String.isNotBlank(currentPurpose)
            && currentPurpose.containsIgnoreCase(soldToPurpose)
        );

        if (ca.Status__c == 'A' && ca.Identifying_Address__c == 'Y' && hasSoldToPurpose) {
            return 8;
        } else if (ca.Status__c == 'A' && ca.Identifying_Address__c == 'N' && hasSoldToPurpose) {
            return 7;
        } else if (ca.Status__c != 'A' && ca.Identifying_Address__c == 'Y' && hasSoldToPurpose) {
            return 6;
        } else if (ca.Status__c != 'A' && ca.Identifying_Address__c == 'N' && hasSoldToPurpose) {
            return 5;
        } else if (ca.Status__c == 'A' && ca.Identifying_Address__c == 'Y') {
            return 4;
        } else if (ca.Status__c == 'A' && ca.Identifying_Address__c == 'N') {
            return 3;
        } else if (ca.Status__c != 'A' && ca.Identifying_Address__c == 'Y') {
            return 2;
        } else if (ca.Status__c != 'A' && ca.Identifying_Address__c == 'N') {
            return 1;
        } else {
            return 0;
        }
    }

    private static void setAllowedBrandsOnParent (Account ca, Account pa) {
        if (PARENT_ACCOUNT_RECORD_TYPES.contains(pa.RecordType.DeveloperName)) {
            pa.Brands_Allowed__c = '';
            Set<String> brandsNotAllowed = new Set<String>();
            if (ca != null && !String.isBlank(ca.Brands_Not_Allowed__c)) {
                for (String brand : ca.Brands_Not_Allowed__c.split(',')) {
                    brandsNotAllowed.add(brand.trim());
                }
            }

            for (PS_AccountBrand__mdt brand : availableBrands) {
                if (!brandsNotAllowed.contains(brand.Label)) {
                    pa.Brands_Allowed__c += brand.Label + ';';
                }
            }

            if (pa.Brands_Allowed__c.endsWith(';')) {
                pa.Brands_Allowed__c = pa.Brands_Allowed__c.removeEnd(';');
            }
        }
    }

    private static String extractPurpose(String purposeFromAccount, Map<Integer, String> purposeByPriority) {
        if (String.isBlank(purposeFromAccount)) {
            return null;
        }
        Set<String> extractedPurposes = new Set<String>(purposeFromAccount.split(','));

        Integer watermark = 0;
        String extractedPurpose;
        for (Integer priority : purposeByPriority.keySet()) {
            String purpose = purposeByPriority.get(priority);
            if (String.isBlank(purpose)) {
                continue;
            }

            for (String currentExtractedPurpose : extractedPurposes) {
                if (currentExtractedPurpose.trim().equalsIgnoreCase(purpose) && priority > watermark) {
                    extractedPurpose = purpose;
                    watermark = priority;
                    break;
                }
            }
        }

        return extractedPurpose;
    }

    private static Map<PS_AccountPartyLogic__mdt, Set<String>> getApLogicToRecordTypesMap() {
        Map<PS_AccountPartyLogic__mdt, Set<String>> aPLogicToRecordTypesMap = new Map<PS_AccountPartyLogic__mdt, Set<String>>();

        for (PS_AccountPartyLogic__mdt apl : accountPartyLogic) {
            aPLogicToRecordTypesMap.put(
                apl,
                (Set<String>) System.JSON.deserialize(apl.RtToProcess__c, Set<String>.class)
            );
        }

        return aPLogicToRecordTypesMap;
    }

    private static Map<PS_AccountSiteLogic__mdt, Set<String>> getAsLogicToRecordTypesMap() {
        Map<PS_AccountSiteLogic__mdt, Set<String>> asLogicToRecordTypesMap = new Map<PS_AccountSiteLogic__mdt, Set<String>>();

        for (PS_AccountSiteLogic__mdt asl : accountSiteLogic) {
            asLogicToRecordTypesMap.put(
                asl,
                (Set<String>) System.JSON.deserialize(asl.RtToProcess__c, Set<String>.class)
            );
        }

        return asLogicToRecordTypesMap;
    }

    public class SiteAccountWithPurposesWrapper {

        public Account siteAccount;
        public String billingPurpose;
        public String shippingPurpose;
        public String billingPurposePrimaryFlag;
        public String shippingPurposePrimaryFlag;

        public SiteAccountWithPurposesWrapper(
            Account siteAccount,
            String billingPurpose,
            String shippingPurpose,
            String billingPurposePrimaryFlag,
            String shippingPurposePrimaryFlag
        ) {
            this.siteAccount = siteAccount;
            this.billingPurpose = billingPurpose;
            this.shippingPurpose = shippingPurpose;
            this.billingPurposePrimaryFlag = billingPurposePrimaryFlag;
            this.shippingPurposePrimaryFlag = shippingPurposePrimaryFlag;
        }

    }

    /**
     * @description Uses in PS_RelatedAccountsAuxiliaryBatch batch context
    **/
    public class PopulatedParentAccountInfo {

        public Id accountId;

        public Id prioritySiteAccountIdByBillingPurpose;
        public Boolean childHasBillingPurposePrimaryFlag;
        public Datetime prioritySiteAccountLastModifiedDateByBillingPurpose;
        public Integer billingPriority;

        public Id prioritySiteAccountIdByShippingPurpose;
        public Boolean childHasShippingPurposePrimaryFlag;
        public Datetime prioritySiteAccountLastModifiedDateByShippingPurpose;
        public Integer shippingPriority;

        public Boolean hasWhereToBuyLocator = false;

        public Id prioritySiteAccountIdForPopulatingSiteLogicFields;
        public Datetime prioritySiteAccountLastModifiedDateForPopulatingSiteLogicFields;
        public Integer prioritySiteAccountForPopulatingSiteLogicFields;

        public Id prioritySiteAccountIdForPopulatingBrandsAllowed;
        public Datetime prioritySiteAccountLastModifiedDateForPopulatingBrandsAllowed;
        public Integer prioritySiteAccountForPopulatingSiteBrandsAllowed;

        public PopulatedParentAccountInfo(Id accountId) {
            this.accountId = accountId;
        }

        public void setPrioritySiteAccountInfoByBillingPurpose(
            Account siteAccount, Boolean childHasBillingPurposePrimaryFlag, Integer billingPriority
        ) {
            this.prioritySiteAccountIdByBillingPurpose = siteAccount.Id;
            this.prioritySiteAccountLastModifiedDateByBillingPurpose = siteAccount.LastModifiedDate;
            this.childHasBillingPurposePrimaryFlag = childHasBillingPurposePrimaryFlag;
            this.billingPriority = billingPriority;
        }

        public void setPrioritySiteAccountInfoBySippingPurpose(
            Account siteAccount, Boolean childHasShippingPurposePrimaryFlag, Integer shippingPriority
        ) {
            this.prioritySiteAccountIdByShippingPurpose = siteAccount.Id;
            this.prioritySiteAccountLastModifiedDateByShippingPurpose = siteAccount.LastModifiedDate;
            this.childHasShippingPurposePrimaryFlag = childHasShippingPurposePrimaryFlag;
            this.shippingPriority = shippingPriority;
        }

        public void setPrioritySiteAccountInfoForPopulatingSiteLogicFields(
            Account siteAccount, Integer priority
        ) {
            this.prioritySiteAccountIdForPopulatingSiteLogicFields = siteAccount.Id;
            this.prioritySiteAccountLastModifiedDateForPopulatingSiteLogicFields = siteAccount.LastModifiedDate;
            this.prioritySiteAccountForPopulatingSiteLogicFields = priority;
        }

        public void setPrioritySiteAccountInfoForPopulatingBrandsAllowed(
            Account siteAccount, Integer priority
        ) {
            this.prioritySiteAccountIdForPopulatingBrandsAllowed = siteAccount.Id;
            this.prioritySiteAccountLastModifiedDateForPopulatingBrandsAllowed = siteAccount.LastModifiedDate;
            this.prioritySiteAccountForPopulatingSiteBrandsAllowed = priority;
        }

        public Boolean hasHigherPriorityByBillingPurposeThan(
            Account siteAccount,
            Boolean currentChildHasBillingPurposePrimaryFlag,
            Integer currentChildBillingPriority
        ) {
            Boolean hasHigherPriority = false;

            if (this.childHasBillingPurposePrimaryFlag && !currentChildHasBillingPurposePrimaryFlag) {
                hasHigherPriority = true;
            } else if (this.childHasBillingPurposePrimaryFlag == currentChildHasBillingPurposePrimaryFlag) {
                if (this.billingPriority > currentChildBillingPriority) {
                    hasHigherPriority = true;
                } else if (this.billingPriority == currentChildBillingPriority) {
                    if (this.prioritySiteAccountLastModifiedDateByBillingPurpose > siteAccount.LastModifiedDate) {
                        hasHigherPriority = true;
                    } else if (this.prioritySiteAccountLastModifiedDateByBillingPurpose == siteAccount.LastModifiedDate) {
                        if (this.prioritySiteAccountIdByBillingPurpose > siteAccount.Id) {
                            hasHigherPriority = true;
                        }
                    }
                }
            }

            return hasHigherPriority;
        }

        public Boolean hasHigherPriorityByShippingPurposeThan(
            Account siteAccount,
            Boolean currentChildHasShippingPurposePrimaryFlag,
            Integer currentChildShippingProirity
        ) {
            Boolean hasHigherPriority = false;

            if (this.childHasShippingPurposePrimaryFlag && !currentChildHasShippingPurposePrimaryFlag) {
                hasHigherPriority = true;
            } else if (this.childHasShippingPurposePrimaryFlag == currentChildHasShippingPurposePrimaryFlag) {
                if (this.shippingPriority > currentChildShippingProirity) {
                    hasHigherPriority = true;
                } else if (this.shippingPriority == currentChildShippingProirity) {
                    if (this.prioritySiteAccountLastModifiedDateByShippingPurpose > siteAccount.LastModifiedDate) {
                        hasHigherPriority = true;
                    } else if (this.prioritySiteAccountLastModifiedDateByShippingPurpose == siteAccount.LastModifiedDate) {
                        if (this.prioritySiteAccountIdByShippingPurpose > siteAccount.Id) {
                            hasHigherPriority = true;
                        }
                    }
                }
            }

            return hasHigherPriority;
        }

        public Boolean hasHigherPriorityForPopulatingSiteLogicFieldsThan(
            Account siteAccount, Integer priority
        ) {
            Boolean hasHigherPriority = false;

            if (this.prioritySiteAccountForPopulatingSiteLogicFields > priority) {
                hasHigherPriority = true;
            } else if (this.prioritySiteAccountForPopulatingSiteLogicFields == priority) {
                if (this.prioritySiteAccountLastModifiedDateForPopulatingSiteLogicFields > siteAccount.LastModifiedDate) {
                    hasHigherPriority = true;
                } else if (this.prioritySiteAccountLastModifiedDateForPopulatingSiteLogicFields == siteAccount.LastModifiedDate) {
                    if (this.prioritySiteAccountIdForPopulatingSiteLogicFields > siteAccount.Id) {
                        hasHigherPriority = true;
                    }
                }
            }

            return hasHigherPriority;
        }

        public Boolean hasHigherPriorityForPopulatingBrandsAllowedThan(
            Account siteAccount, Integer priority
        ) {
            Boolean hasHigherPriority = false;

            if (this.prioritySiteAccountForPopulatingSiteBrandsAllowed > priority) {
                hasHigherPriority = true;
            } else if (this.prioritySiteAccountForPopulatingSiteBrandsAllowed == priority) {
                if (this.prioritySiteAccountLastModifiedDateForPopulatingBrandsAllowed > siteAccount.LastModifiedDate) {
                    hasHigherPriority = true;
                } else if (this.prioritySiteAccountLastModifiedDateForPopulatingBrandsAllowed == siteAccount.LastModifiedDate) {
                    if (this.prioritySiteAccountIdForPopulatingBrandsAllowed > siteAccount.Id) {
                        hasHigherPriority = true;
                    }
                }
            }

            return hasHigherPriority;
        }

    }

    public class PrioritySiteAccount {
        public Account priorityAccountForSiteLogic;
        public Account priorityAccountForBrandsAllowed;

        public PrioritySiteAccount() {}
    }

}
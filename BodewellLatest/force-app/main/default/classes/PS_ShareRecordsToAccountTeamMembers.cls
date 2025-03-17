public class PS_ShareRecordsToAccountTeamMembers {

    private PS_ShareAccountSalesPerfToTeamMembers shareSalesPerformances = new PS_ShareAccountSalesPerfToTeamMembers();
    private PS_ShareCustomerAgreementToTeamMembers shareCustomerAgreements = new PS_ShareCustomerAgreementToTeamMembers();
    private PS_ShareMeetCompsToAccountTeamMembers shareMeetComps = new PS_ShareMeetCompsToAccountTeamMembers();
    private PS_ShareProgramRequestToAccTeamMembers shareProgramRequests = new PS_ShareProgramRequestToAccTeamMembers();
    private PS_ShareStoreProductsToAccTeamMembers shareStoreProducts = new PS_ShareStoreProductsToAccTeamMembers();

    public void createShareRecords (
        List<AccountTeamMember> accountTeamMembers, List<SObject> records, String sharedObjectName
    ) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember member : accountTeamMembers) {
            accountIds.add(member.AccountId);
            userIds.add(member.UserId);
        }

        if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_MEET_COMP) {
            createMeetCompShareRecords(accountTeamMembers, (List<Meet_Comp__c>) records, accountIds, userIds);
        } else if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST) {
            createProgramRequestShareRecords(accountTeamMembers, (List<Program_Request__c>) records, accountIds, userIds);
        } else if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT) {
            createStoreProductShareRecords(accountTeamMembers, (List<StoreProduct>) records, accountIds, userIds);
        } else if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT) {
            createCustomerAgreementShareRecords(accountTeamMembers, (List<Customer_Agreement__c>) records, accountIds, userIds);
        } else if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE) {
            createSalesPerfShareRecords(accountTeamMembers, (List<Account_Sales_Performance__c>) records, accountIds, userIds);
        }
    }

    public void createShareOfNewRecordsToAccountTeamMembers (List<SObject> records, String sharedObjectName) {
        if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_MEET_COMP) {
            shareMeetComps.createSharesForAccountTeamMembers((List<Meet_Comp__c>) records);
        } else if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST) {
            shareProgramRequests.createSharesForAccountTeamMembers((List<Program_Request__c>) records);
        } else if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT) {
            shareStoreProducts.createSharesForAccountTeamMembers((List<StoreProduct>) records);
        } else if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT) {
            shareCustomerAgreements.createSharesForAccountTeamMembers((List<Customer_Agreement__c>) records);
        } else if (sharedObjectName == GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE) {
            shareSalesPerformances.createSharesForAccountTeamMembers((List<Account_Sales_Performance__c>) records);
        }
    }

    public void createMeetCompShareRecords (
        List<AccountTeamMember> accountTeamMembers,
        List<Meet_Comp__c> meetComps,
        Set<Id> accountIds,
        Set<Id> userIds
    ) {
        Map<Id, List<Meet_Comp__c>> meetCompsByAccId = indexMeetCompsByAccountId(meetComps);
        Map<Id, List<Meet_Comp__Share>> existingMeetCompSharesByParentId = findExistingMeetCompShares(
            accountIds,
            userIds,
            new Map<Id, Meet_Comp__c>(meetComps).keySet()
        );

        List<Meet_Comp__Share> meetCompShares = new List<Meet_Comp__Share>();
        for (AccountTeamMember member : accountTeamMembers) {
            meetCompShares.addAll(
                createMeetCompShares(
                    member,
                    meetCompsByAccId.get(member.AccountId),
                    existingMeetCompSharesByParentId
                )
            );
        }
        insert meetCompShares;
    }

    public void createProgramRequestShareRecords (
        List<AccountTeamMember> accountTeamMembers,
        List<Program_Request__c> programRequests,
        Set<Id> accountIds,
        Set<Id> userIds
    ) {
        Map<Id, List<Program_Request__c>> requestsByAccId = indexRequestsByAccountId(programRequests);
        Map<Id, List<Program_Request__Share>> existingRequestSharesByParentId = findExistingProgramRequestShares(
            accountIds,
            userIds,
            new Map<Id, Program_Request__c>(programRequests).keySet()
        );

        List<Program_Request__Share> requestShares = new List<Program_Request__Share>();
        for (AccountTeamMember member : accountTeamMembers) {
            requestShares.addAll(
                createProgramRequestShares(
                    member,
                    requestsByAccId.get(member.AccountId),
                    existingRequestSharesByParentId
                )
            );
        }
        insert requestShares;
    }

    public void createStoreProductShareRecords (
        List<AccountTeamMember> accountTeamMembers,
        List<StoreProduct> storeProducts,
        Set<Id> accountIds,
        Set<Id> userIds
    ) {
        Map<Id, List<StoreProduct>> storeProductsByAccId = indexStoreProductsByAccountId(storeProducts);
        Map<Id, List<StoreProductShare>> existingStoreProductSharesByParentId = findExistingStoreProductShares(
            accountIds,
            userIds,
            new Map<Id, StoreProduct>(storeProducts).keySet()
        );

        List<StoreProductShare> storeProductShares = new List<StoreProductShare>();
        for (AccountTeamMember member : accountTeamMembers) {
            storeProductShares.addAll(
                createStoreProductShares(
                    member,
                    storeProductsByAccId.get(member.AccountId),
                    existingStoreProductSharesByParentId
                )
            );
        }
        insert storeProductShares;
    }

    public void createCustomerAgreementShareRecords (
        List<AccountTeamMember> accountTeamMembers,
        List<Customer_Agreement__c> customerAgreements,
        Set<Id> accountIds,
        Set<Id> userIds
    ) {
        Map<Id, List<Customer_Agreement__c>> agreementsByAccId = indexAgreementsByAccountId(customerAgreements);
        Map<Id, List<Customer_Agreement__Share>> existingAgreementSharesByParentId = findExistingCustomerAgreementShares(
            accountIds,
            userIds,
            new Map<Id, Customer_Agreement__c>(customerAgreements).keySet()
        );

        List<Customer_Agreement__Share> agreementShares = new List<Customer_Agreement__Share>();
        for (AccountTeamMember member : accountTeamMembers) {
            agreementShares.addAll(
                createCustomerAgreementShares(
                    member,
                    agreementsByAccId.get(member.AccountId),
                    existingAgreementSharesByParentId
                )
            );
        }
        insert agreementShares;
    }

    public void createSalesPerfShareRecords (
        List<AccountTeamMember> accountTeamMembers,
        List<Account_Sales_Performance__c> salesPerfs,
        Set<Id> accountIds,
        Set<Id> userIds
    ) {
        Map<Id, List<Account_Sales_Performance__c>> salesPerfsByAccId = indexSalesPerformancesByAccountId(salesPerfs);
        Map<Id, List<Account_Sales_Performance__Share>> existingSalesPerfSharesByParentId = findExistingSalesPerformanceShares(
            accountIds,
            userIds,
            new Map<Id, Account_Sales_Performance__c>(salesPerfs).keySet()
        );

        List<Account_Sales_Performance__Share> salesPerfShares = new List<Account_Sales_Performance__Share>();
        for (AccountTeamMember member : accountTeamMembers) {
            salesPerfShares.addAll(
                createSalesPerfShares(
                    member,
                    salesPerfsByAccId.get(member.AccountId),
                    existingSalesPerfSharesByParentId
                )
            );
        }
        insert salesPerfShares;
    }

    private Map<Id, List<Meet_Comp__c>> indexMeetCompsByAccountId (List<Meet_Comp__c> meetComps) {
        Map<Id, List<Meet_Comp__c>> meetCompByAccountId = new Map<Id, List<Meet_Comp__c>>();
        for (Meet_Comp__c meetComp : meetComps) {
            if (meetCompByAccountId.get(meetComp.Account__c) == null) {
                meetCompByAccountId.put(meetComp.Account__c, new List<Meet_Comp__c>());
            }
            meetCompByAccountId.get(meetComp.Account__c).add(meetComp);
        }
        return meetCompByAccountId;
    }

    private Map<Id, List<Program_Request__c>> indexRequestsByAccountId (List<Program_Request__c> programRequests) {
        Map<Id, List<Program_Request__c>> requestByAccountId = new Map<Id, List<Program_Request__c>>();
        for (Program_Request__c request : programRequests) {
            if (requestByAccountId.get(request.Account__c) == null) {
                requestByAccountId.put(request.Account__c, new List<Program_Request__c>());
            }
            requestByAccountId.get(request.Account__c).add(request);
        }
        return requestByAccountId;
    }

    private Map<Id, List<StoreProduct>> indexStoreProductsByAccountId (List<StoreProduct> storeProducts) {
        Map<Id, List<StoreProduct>> storeProductByAccountId = new Map<Id, List<StoreProduct>>();
        for (StoreProduct storeProduct : storeProducts) {
            if (storeProductByAccountId.get(storeProduct.Account__c) == null) {
                storeProductByAccountId.put(storeProduct.Account__c, new List<StoreProduct>());
            }
            storeProductByAccountId.get(storeProduct.Account__c).add(storeProduct);
        }
        return storeProductByAccountId;
    }

    private Map<Id, List<Customer_Agreement__c>> indexAgreementsByAccountId (List<Customer_Agreement__c> customerAgreements) {
        Map<Id, List<Customer_Agreement__c>> agreementByAccountId = new Map<Id, List<Customer_Agreement__c>>();
        for (Customer_Agreement__c agreement : customerAgreements) {
            if (agreementByAccountId.get(agreement.Account_Name__c) == null) {
                agreementByAccountId.put(agreement.Account_Name__c, new List<Customer_Agreement__c>());
            }
            agreementByAccountId.get(agreement.Account_Name__c).add(agreement);
        }
        return agreementByAccountId;
    }

    private Map<Id, List<Account_Sales_Performance__c>> indexSalesPerformancesByAccountId (List<Account_Sales_Performance__c> salesPerfs) {
        Map<Id, List<Account_Sales_Performance__c>> salesPerfsByAccountId = new Map<Id, List<Account_Sales_Performance__c>>();
        for (Account_Sales_Performance__c perf : salesPerfs) {
            if (salesPerfsByAccountId.get(perf.Account__c) == null) {
                salesPerfsByAccountId.put(perf.Account__c, new List<Account_Sales_Performance__c>());
            }
            salesPerfsByAccountId.get(perf.Account__c).add(perf);
        }
        return salesPerfsByAccountId;
    }

    private Map<Id, List<Meet_Comp__Share>> findExistingMeetCompShares (Set<Id> accountIds, Set<Id> userIds, Set<Id> meetCompIds) {
        Map<Id, List<Meet_Comp__Share>> existingMeetCompSharesByParentId = new Map<Id, List<Meet_Comp__Share>>();

        for (Meet_Comp__Share share : [SELECT Id, ParentId, UserOrGroupId FROM Meet_Comp__Share
                                       WHERE UserOrGroupId IN :userIds
                                           AND Parent.Account__c IN :accountIds
                                           AND Parent.Id IN :meetCompIds]
        ) {
            if (existingMeetCompSharesByParentId.get(share.ParentId) == null) {
                existingMeetCompSharesByParentId.put(share.ParentId, new List<Meet_Comp__Share>());
            }
            existingMeetCompSharesByParentId.get(share.ParentId).add(share);
        }
        return existingMeetCompSharesByParentId;
    }

    private Map<Id, List<Program_Request__Share>> findExistingProgramRequestShares (Set<Id> accountIds, Set<Id> userIds, Set<Id> programRequestIds) {
        Map<Id, List<Program_Request__Share>> existingRequestSharesByParentId = new Map<Id, List<Program_Request__Share>>();

        for (Program_Request__Share share : [SELECT Id, ParentId, UserOrGroupId FROM Program_Request__Share
                                             WHERE UserOrGroupId IN :userIds
                                                 AND Parent.Account__c IN :accountIds
                                                 AND Parent.Id IN :programRequestIds]
        ) {
            if (existingRequestSharesByParentId.get(share.ParentId) == null) {
                existingRequestSharesByParentId.put(share.ParentId, new List<Program_Request__Share>());
            }
            existingRequestSharesByParentId.get(share.ParentId).add(share);
        }
        return existingRequestSharesByParentId;
    }

    private Map<Id, List<StoreProductShare>> findExistingStoreProductShares (Set<Id> accountIds, Set<Id> userIds, Set<Id> storeProductIds) {
        Map<Id, List<StoreProductShare>> existingStoreProductSharesByParentId = new Map<Id, List<StoreProductShare>>();

        for (StoreProductShare share : [SELECT Id, ParentId, UserOrGroupId FROM StoreProductShare
                                        WHERE UserOrGroupId IN :userIds
                                            AND Parent.Account__c IN :accountIds
                                            AND Parent.Id IN :storeProductIds]
        ) {
            if (existingStoreProductSharesByParentId.get(share.ParentId) == null) {
                existingStoreProductSharesByParentId.put(share.ParentId, new List<StoreProductShare>());
            }
            existingStoreProductSharesByParentId.get(share.ParentId).add(share);
        }
        return existingStoreProductSharesByParentId;
    }

    private Map<Id, List<Customer_Agreement__Share>> findExistingCustomerAgreementShares (Set<Id> accountIds, Set<Id> userIds, Set<Id> customerAgreementIds) {
        Map<Id, List<Customer_Agreement__Share>> existingAgreementSharesByParentId = new Map<Id, List<Customer_Agreement__Share>>();

        for (Customer_Agreement__Share share : [SELECT Id, ParentId, UserOrGroupId FROM Customer_Agreement__Share
                                                WHERE UserOrGroupId IN :userIds
                                                    AND Parent.Account_Name__c IN :accountIds
                                                    AND Parent.Id IN :customerAgreementIds]
        ) {
            if (existingAgreementSharesByParentId.get(share.ParentId) == null) {
                existingAgreementSharesByParentId.put(share.ParentId, new List<Customer_Agreement__Share>());
            }
            existingAgreementSharesByParentId.get(share.ParentId).add(share);
        }
        return existingAgreementSharesByParentId;
    }

    private Map<Id, List<Account_Sales_Performance__Share>> findExistingSalesPerformanceShares (Set<Id> accountIds, Set<Id> userIds, Set<Id> salesPerfIds) {
        Map<Id, List<Account_Sales_Performance__Share>> existingSalesPerfSharesByParentId = new Map<Id, List<Account_Sales_Performance__Share>>();

        for (Account_Sales_Performance__Share share : [SELECT Id, ParentId, UserOrGroupId FROM Account_Sales_Performance__Share
                                                       WHERE UserOrGroupId IN :userIds
                                                           AND Parent.Account__c IN :accountIds
                                                           AND Parent.Id IN :salesPerfIds]
        ) {
            if (existingSalesPerfSharesByParentId.get(share.ParentId) == null) {
                existingSalesPerfSharesByParentId.put(share.ParentId, new List<Account_Sales_Performance__Share>());
            }
            existingSalesPerfSharesByParentId.get(share.ParentId).add(share);
        }
        return existingSalesPerfSharesByParentId;
    }

    private List<Meet_Comp__Share> createMeetCompShares (AccountTeamMember member, List<Meet_Comp__c> meetComps, Map<Id, List<Meet_Comp__Share>> existingMeetCompSharesByParentId) {
        List<Meet_Comp__Share> shares = new List<Meet_Comp__Share>();
        if (meetComps != null) {
            Boolean shareAlreadyExist;
            for (Meet_Comp__c meetComp : meetComps) {
                shareAlreadyExist = shareMeetComps.shareAlreadyExists(member.UserId, meetComp.Id, existingMeetCompSharesByParentId);
                if (!shareAlreadyExist) {
                    shares.add(shareMeetComps.createMeetCompShare(member.UserId, meetComp.Id));
                }
            }
        }
        return shares;
    }

    private List<Program_Request__Share> createProgramRequestShares (AccountTeamMember member, List<Program_Request__c> requests, Map<Id, List<Program_Request__Share>> existingRequestSharesByParentId) {
        List<Program_Request__Share> shares = new List<Program_Request__Share>();
        if (requests != null) {
            for (Program_Request__c request : requests) {
                if (!shareProgramRequests.shareAlreadyExists(member.UserId, request.Id, existingRequestSharesByParentId)) {
                    shares.add(this.shareProgramRequests.createProgramRequestShare(member.UserId, request.Id));
                }
            }
        }
        return shares;
    }

    private List<StoreProductShare> createStoreProductShares (AccountTeamMember member, List<StoreProduct> storeProducts, Map<Id, List<StoreProductShare>> existingStoreProductSharesByParentId) {
        List<StoreProductShare> shares = new List<StoreProductShare>();
        if (storeProducts != null) {
            for (StoreProduct storeProduct : storeProducts) {
                if(!shareStoreProducts.shareAlreadyExists(member.UserId, storeProduct.Id, existingStoreProductSharesByParentId)) {
                    shares.add(this.shareStoreProducts.createStoreProductShare(member.UserId, storeProduct.Id));
                }
            }
        }
        return shares;
    }

    private List<Customer_Agreement__Share> createCustomerAgreementShares (AccountTeamMember member, List<Customer_Agreement__c> agreements, Map<Id, List<Customer_Agreement__Share>> existingAgreementSharesByParentId) {
        List<Customer_Agreement__Share> shares = new List<Customer_Agreement__Share>();
        if (agreements != null) {
            for (Customer_Agreement__c agreement : agreements) {
                if (!shareCustomerAgreements.shareAlreadyExists(member.UserId, agreement.Id, existingAgreementSharesByParentId)) {
                    shares.add(this.shareCustomerAgreements.createCustomerAgreementShare(member.UserId, agreement.Id));
                }
            }
        }
        return shares;
    }

    private List<Account_Sales_Performance__Share> createSalesPerfShares (AccountTeamMember member, List<Account_Sales_Performance__c> salesPerfs, Map<Id, List<Account_Sales_Performance__Share>> existingSalesPerfSharesByParentId) {
        List<Account_Sales_Performance__Share> shares = new List<Account_Sales_Performance__Share>();
        if (salesPerfs != null) {
            for (Account_Sales_Performance__c salesPerf : salesPerfs) {
                if (!shareSalesPerformances.shareAlreadyExists(member.UserId, salesPerf.Id, existingSalesPerfSharesByParentId)) {
                    shares.add(this.shareSalesPerformances.createAccountSalesPerformanceShare(member.UserId, salesPerf.Id));
                }
            }
        }
        return shares;
    }

    public void deleteShares (List<AccountTeamMember> members) {
        System.enqueueJob(
            new PS_DeleteSharesQueueable(
                members,
                GEA_Constants.OBJECT_API_NAME_MEET_COMP_SHARE,
                GEA_Constants.FIELD_API_NAME_MEET_COMP_SHARE_PARENT_ACCOUNT,
                Schema.Meet_Comp__Share.RowCause.Account_Team__c
            )
        );
        System.enqueueJob(
            new PS_DeleteSharesQueueable(
                members,
                GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST_SHARE,
                GEA_Constants.FIELD_API_NAME_PROGRAM_REQUEST_SHARE_PARENT_ACCOUNT,
                Schema.Program_Request__Share.RowCause.Account_Team__c
            )
        );
        System.enqueueJob(
            new PS_DeleteSharesQueueable(
                members,
                GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT_SHARE,
                GEA_Constants.FIELD_API_NAME_STORE_PRODUCT_SHARE_PARENT_ACCOUNT,
                Schema.StoreProductShare.RowCause.Manual
            )
        );
        System.enqueueJob(
            new PS_DeleteSharesQueueable(
                members,
                GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT_SHARE,
                GEA_Constants.FIELD_API_NAME_CUSTOMER_AGREEMENT_SHARE_PARENT_ACCOUNT,
                Schema.Customer_Agreement__Share.RowCause.Account_Team__c
            )
        );
        System.enqueueJob(
            new PS_DeleteSharesQueueable(
                members,
                GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE_SHARE,
                GEA_Constants.FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_SHARE_PARENT_ACCOUNT,
                Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c
            )
        );
    }

}
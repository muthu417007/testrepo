public class PS_ShareStoreProductsToAccTeamMembers {

    public void createSharesForAccountTeamMembers (List<StoreProduct> storeProducts) {
        Set<Id> storeProductIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (StoreProduct storeProduct : storeProducts) {
            accountIds.add(storeProduct.Account__c);
            storeProductIds.add(storeProduct.Id);
        }
        shareWithAccountTeamMembers(storeProducts, accountIds, storeProductIds);
    }

    public void shareWithAccountTeamMembers (List<StoreProduct> storeProducts, Set<Id> accountIds, Set<Id> storeProductIds) {
        Map<Id, List<AccountTeamMember>> teamMembersByAccountId = new Map<Id, List<AccountTeamMember>>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember teamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND User.IsActive = TRUE]) {
            if (teamMembersByAccountId.get(teamMember.AccountId) == null) {
                teamMembersByAccountId.put(teamMember.AccountId, new List<AccountTeamMember>());
            }
            teamMembersByAccountId.get(teamMember.AccountId).add(teamMember);
            userIds.add(teamMember.UserId);
        }

        Map<Id, List<StoreProductShare>> existingSharesByParentId = indexExistingSharesByParentId(storeProductIds, userIds);
        List<StoreProductShare> spShares = new List<StoreProductShare>();
        for (StoreProduct storeProduct : storeProducts) {
            if (teamMembersByAccountId.get(storeProduct.Account__c) != null) {
                for (AccountTeamMember teamMember : teamMembersByAccountId.get(storeProduct.Account__c)) {
                    if (!shareAlreadyExists(teamMember.UserId, storeProduct.Id, existingSharesByParentId)) {
                        spShares.add(createStoreProductShare(teamMember.UserId, storeProduct.Id));
                    }
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'shares being inserted PS_ShareStoreProductsToAccTeamMembers: ' + spShares.size());
        insert spShares;
    }

    public Boolean shareAlreadyExists (Id userId, Id storeProductId, Map<Id, List<StoreProductShare>> existingSharesByParentId) {
        if (existingSharesByParentId.get(storeProductId) != null) {
            for (StoreProductShare share : existingSharesByParentId.get(storeProductId)) {
                if (share.UserOrGroupId == userId) {
                    return true;
                }
            }
        }
        return false;
    }

    public StoreProductShare createStoreProductShare (Id userId, Id storeProductId) {
        return new StoreProductShare(
            RowCause = Schema.StoreProductShare.RowCause.Manual,
            UserOrGroupId = userId,
            AccessLevel = 'Edit',
            ParentId = storeProductId
        );
    }

    private Map<Id, List<StoreProductShare>> indexExistingSharesByParentId (Set<Id> storeProductIds, Set<Id> userIds) {
        Map<Id, List<StoreProductShare>> sharesByParentId = new Map<Id, List<StoreProductShare>>();
        for (StoreProductShare share : [SELECT Id, ParentId, UserOrGroupId FROM StoreProductShare WHERE ParentId IN :storeProductIds AND UserOrGroupId IN :userIds]) {
            if (sharesByParentId.get(share.ParentId) == null) {
                sharesByParentId.put(share.ParentId, new List<StoreProductShare>());
            }
            sharesByParentId.get(share.ParentId).add(share);
        }
        return sharesByParentId;
    }
}
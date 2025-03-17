public class PS_ShareAccountSalesPerfToTeamMembers {

    public void createSharesForAccountTeamMembers (List<Account_Sales_Performance__c> salesPerformances) {
        Set<Id> salesPerformanceIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Account_Sales_Performance__c salesPerformance : salesPerformances) {
            accountIds.add(salesPerformance.Account__c);
            salesPerformanceIds.add(salesPerformance.Id);
        }
        shareWithAccountTeamMembers(salesPerformances, accountIds, salesPerformanceIds);
    }

    private void shareWithAccountTeamMembers (List<Account_Sales_Performance__c> salesPerformances, Set<Id> accountIds, Set<Id> salesPerformanceIds) {
        Map<Id, List<AccountTeamMember>> teamMembersByAccountId = new Map<Id, List<AccountTeamMember>>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember teamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND User.IsActive = TRUE]) {
            if (teamMembersByAccountId.get(teamMember.AccountId) == null) {
                teamMembersByAccountId.put(teamMember.AccountId, new List<AccountTeamMember>());
            }
            teamMembersByAccountId.get(teamMember.AccountId).add(teamMember);
            userIds.add(teamMember.UserId);
        }

        Map<Id, List<Account_Sales_Performance__Share>> existingSharesByParentId = indexExistingSharesByParentId(salesPerformanceIds, userIds);
        List<Account_Sales_Performance__Share> shares = new List<Account_Sales_Performance__Share>();
        for (Account_Sales_Performance__c salesPerformance : salesPerformances) {
            if (teamMembersByAccountId.get(salesPerformance.Account__c) != null) {
                for (AccountTeamMember teamMember : teamMembersByAccountId.get(salesPerformance.Account__c)) {
                    if (!shareAlreadyExists(teamMember.UserId, salesPerformance.Id, existingSharesByParentId)) {
                        shares.add(createAccountSalesPerformanceShare(teamMember.UserId, salesPerformance.Id));
                    }
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'shares being inserted PS_ShareAccountSalesPerfToTeamMembers: ' + shares.size());
        insert shares;
    }

    public Boolean shareAlreadyExists (Id userId, Id salesPerformanceId, Map<Id, List<Account_Sales_Performance__Share>> existingSharesByParentId) {
        if (existingSharesByParentId.get(salesPerformanceId) != null) {
            for (Account_Sales_Performance__Share share : existingSharesByParentId.get(salesPerformanceId)) {
                if (share.UserOrGroupId == userId) {
                    return true;
                }
            }
        }
        return false;
    }

    public Account_Sales_Performance__Share createAccountSalesPerformanceShare (Id userId, Id salesPerformanceId) {
        return new Account_Sales_Performance__Share(
            RowCause = Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c,
            UserOrGroupId = userId,
            AccessLevel = 'Edit',
            ParentId = salesPerformanceId
        );
    }

    private Map<Id, List<Account_Sales_Performance__Share>> indexExistingSharesByParentId (Set<Id> salesPerformanceIds, Set<Id> userIds) {
        Map<Id, List<Account_Sales_Performance__Share>> sharesByParentId = new Map<Id, List<Account_Sales_Performance__Share>>();
        for (Account_Sales_Performance__Share share : [SELECT Id, ParentId, UserOrGroupId FROM Account_Sales_Performance__Share WHERE ParentId IN :salesPerformanceIds AND UserOrGroupId IN :userIds]) {
            if (sharesByParentId.get(share.ParentId) == null) {
                sharesByParentId.put(share.ParentId, new List<Account_Sales_Performance__Share>());
            }
            sharesByParentId.get(share.ParentId).add(share);
        }
        return sharesByParentId;
    }
}
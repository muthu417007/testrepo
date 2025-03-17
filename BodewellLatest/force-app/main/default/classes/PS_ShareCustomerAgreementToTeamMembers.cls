public class PS_ShareCustomerAgreementToTeamMembers {

    public void createSharesForAccountTeamMembers (List<Customer_Agreement__c> agreements) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> agreementIds = new Set<Id>();
        for (Customer_Agreement__c agreement : agreements) {
            accountIds.add(agreement.Account_Name__c);
            agreementIds.add(agreement.Id);
        }
        shareWithAccountTeamMembers(agreements, accountIds, agreementIds);
    }

    private void shareWithAccountTeamMembers (List<Customer_Agreement__c> agreements, Set<Id> accountIds, Set<Id> agreementIds) {
        Map<Id, List<AccountTeamMember>> teamMembersByAccountId = new Map<Id, List<AccountTeamMember>>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember teamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND User.IsActive = TRUE]) {
            if (teamMembersByAccountId.get(teamMember.AccountId) == null) {
                teamMembersByAccountId.put(teamMember.AccountId, new List<AccountTeamMember>());
            }
            teamMembersByAccountId.get(teamMember.AccountId).add(teamMember);
            userIds.add(teamMember.UserId);
        }

        Map<Id, List<Customer_Agreement__Share>> existingSharesByParentId = indexExistingSharesByParentId(agreementIds, userIds);
        List<Customer_Agreement__Share> shares = new List<Customer_Agreement__Share>();
        for (Customer_Agreement__c agreement : agreements) {
            if (teamMembersByAccountId.get(agreement.Account_Name__c) != null) {
                for (AccountTeamMember teamMember : teamMembersByAccountId.get(agreement.Account_Name__c)) {
                    if (!shareAlreadyExists(teamMember.UserId, agreement.Id, existingSharesByParentId)) {
                        shares.add(createCustomerAgreementShare(teamMember.UserId, agreement.Id));
                    }
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'shares being inserted PS_ShareCustomerAgreementToTeamMembers: ' + shares.size());
        insert shares;
    }

    public Boolean shareAlreadyExists (Id userId, Id agreementIds, Map<Id, List<Customer_Agreement__Share>> existingSharesByParentId) {
        if (existingSharesByParentId.get(agreementIds) != null) {
            for (Customer_Agreement__Share share : existingSharesByParentId.get(agreementIds)) {
                if (share.UserOrGroupId == userId) {
                    return true;
                }
            }
        }
        return false;
    }

    public Customer_Agreement__Share createCustomerAgreementShare (Id userId, Id agreementId) {
        return new Customer_Agreement__Share(
            RowCause = Schema.Customer_Agreement__Share.RowCause.Account_Team__c,
            UserOrGroupId = userId,
            AccessLevel = 'Edit',
            ParentId = agreementId
        );
    }

    private Map<Id, List<Customer_Agreement__Share>> indexExistingSharesByParentId (Set<Id> agreementIds, Set<Id> userIds) {
        Map<Id, List<Customer_Agreement__Share>> sharesByParentId = new Map<Id, List<Customer_Agreement__Share>>();
        for (Customer_Agreement__Share share : [SELECT Id, ParentId, UserOrGroupId FROM Customer_Agreement__Share WHERE ParentId IN :agreementIds AND UserOrGroupId IN :userIds]) {
            if (sharesByParentId.get(share.ParentId) == null) {
                sharesByParentId.put(share.ParentId, new List<Customer_Agreement__Share>());
            }
            sharesByParentId.get(share.ParentId).add(share);
        }
        return sharesByParentId;
    }
}
public without sharing class PS_AccountRecreateTeamMembers {

    public void findAndRecreateMembers (List<Account> newAccs, Map<Id, Account> oldAccountsById) {
        Set<Id> accountIds = getAccountIds(newAccs, oldAccountsById);
        List<AccountTeamMember> members = [
            SELECT AccountId, AccountAccessLevel, CaseAccessLevel,
                ContactAccessLevel, OpportunityAccessLevel, TeamMemberRole, UserId
            FROM AccountTeamMember
            WHERE AccountId IN :accountIds AND User.IsActive = TRUE];
        reInstertAccountTeamMembers(JSON.serialize(members));
    }

    private Set<Id> getAccountIds (List<Account> newAccs, Map<Id, Account> oldAccountsById) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : newAccs) {
            if (acc.OwnerId != oldAccountsById.get(acc.Id).OwnerId) {
                accountIds.add(acc.Id);
            }
        }
        return accountIds;
    }

    private static void reInstertAccountTeamMembers (String membersJson) {
        List<AccountTeamMember> members = (List<AccountTeamMember>) JSON.deserialize(membersJson, List<AccountTeamMember>.class);
        List<AccountTeamMember> newMembers = new List<AccountTeamMember>();
        for (AccountTeamMember member : members) {
            newMembers.add(member.clone(false, false, true, false));
        }

        insert newMembers;
    }
}
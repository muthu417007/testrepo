public class PS_ShareMeetCompsToAccountTeamMembers {

    public void createSharesForAccountTeamMembers (List<Meet_Comp__c> meetComps) {
        Set<Id> meetCompIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Meet_Comp__c meetComp : meetComps) {
            accountIds.add(meetComp.Account__c);
            meetCompIds.add(meetComp.Id);
        }
        shareWithAccountTeamMembers(meetComps, accountIds, meetCompIds);
    }

    private void shareWithAccountTeamMembers (List<Meet_Comp__c> meetComps, Set<Id> accountIds, Set<Id> meetCompIds) {
        Map<Id, List<AccountTeamMember>> teamMembersByAccountId = new Map<Id, List<AccountTeamMember>>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember teamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND User.IsActive = TRUE]) {
            if (teamMembersByAccountId.get(teamMember.AccountId) == null) {
                teamMembersByAccountId.put(teamMember.AccountId, new List<AccountTeamMember>());
            }
            teamMembersByAccountId.get(teamMember.AccountId).add(teamMember);
            userIds.add(teamMember.UserId);
        }

        Map<Id, List<Meet_Comp__Share>> existingSharesByParentId = indexExistingSharesByParentId(meetCompIds, userIds);
        List<Meet_Comp__Share> shares = new List<Meet_Comp__Share>();
        for (Meet_Comp__c meetComp : meetComps) {
            if (teamMembersByAccountId.get(meetComp.Account__c) != null) {
                for (AccountTeamMember teamMember : teamMembersByAccountId.get(meetComp.Account__c)) {
                    if (!shareAlreadyExists(teamMember.UserId, meetComp.Id, existingSharesByParentId)) {
                        shares.add(createMeetCompShare(teamMember.UserId, meetComp.Id));
                    }
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'shares being inserted PS_ShareMeetCompsToAccountTeamMembers: ' + shares.size());
        insert shares;
    }

    public Boolean shareAlreadyExists (Id userId, Id meetCompId, Map<Id, List<Meet_Comp__Share>> existingSharesByParentId) {
        if (existingSharesByParentId.get(meetCompId) != null) {
            for (Meet_Comp__Share share : existingSharesByParentId.get(meetCompId)) {
                if (share.UserOrGroupId == userId) {
                    return true;
                }
            }
        }
        return false;
    }

    public Meet_Comp__Share createMeetCompShare (Id userId, Id meetCompId) {
        return new Meet_Comp__Share(
            RowCause = Schema.Meet_Comp__Share.RowCause.Account_Team__c,
            UserOrGroupId = userId,
            AccessLevel = 'Edit',
            ParentId = meetCompId
        );
    }

    private Map<Id, List<Meet_Comp__Share>> indexExistingSharesByParentId (Set<Id> meetCompIds, Set<Id> userIds) {
        Map<Id, List<Meet_Comp__Share>> sharesByParentId = new Map<Id, List<Meet_Comp__Share>>();
        for (Meet_Comp__Share share : [SELECT Id, ParentId, UserOrGroupId FROM Meet_Comp__Share WHERE ParentId IN :meetCompIds AND UserOrGroupId IN :userIds]) {
            if (sharesByParentId.get(share.ParentId) == null) {
                sharesByParentId.put(share.ParentId, new List<Meet_Comp__Share>());
            }
            sharesByParentId.get(share.ParentId).add(share);
        }
        return sharesByParentId;
    }
}
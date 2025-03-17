public class PS_ShareProgramRequestToAccTeamMembers {

    public void createSharesForAccountTeamMembers (List<Program_Request__c> requests) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> programRequestIds = new Set<Id>();
        for (Program_Request__c pr : requests) {
            accountIds.add(pr.Account__c);
            programRequestIds.add(pr.Id);
        }
        shareWithAccountTeamMembers(requests, accountIds, programRequestIds);
    }

    private void shareWithAccountTeamMembers (List<Program_Request__c> programRequests, Set<Id> accountIds, Set<Id> programRequestIds) {
        Map<Id, List<AccountTeamMember>> teamMembersByAccountId = new Map<Id, List<AccountTeamMember>>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember teamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND User.IsActive = TRUE]) {
            if (teamMembersByAccountId.get(teamMember.AccountId) == null) {
                teamMembersByAccountId.put(teamMember.AccountId, new List<AccountTeamMember>());
            }
            teamMembersByAccountId.get(teamMember.AccountId).add(teamMember);
            userIds.add(teamMember.UserId);
        }

        Map<Id, List<Program_Request__Share>> existingSharesByParentId = indexExistingSharesByParentId(programRequestIds, userIds);
        List<Program_Request__Share> shares = new List<Program_Request__Share>();
        for (Program_Request__c request : programRequests) {
            if (teamMembersByAccountId.get(request.Account__c) != null) {
                for (AccountTeamMember teamMember : teamMembersByAccountId.get(request.Account__c)) {
                    if (!shareAlreadyExists(teamMember.UserId, request.Id, existingSharesByParentId)) {
                        shares.add(createProgramRequestShare(teamMember.UserId, request.Id));
                    }
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'shares being inserted PS_ShareProgramRequestToAccTeamMembers: ' + shares.size());
        insert shares;
    }

    public Boolean shareAlreadyExists (Id userId, Id programRequestId, Map<Id, List<Program_Request__Share>> existingSharesByParentId) {
        if (existingSharesByParentId.get(programRequestId) != null) {
            for (Program_Request__Share share : existingSharesByParentId.get(programRequestId)) {
                if (share.UserOrGroupId == userId) {
                    return true;
                }
            }
        }
        return false;
    }

    public Program_Request__Share createProgramRequestShare (Id userId, Id requestId) {
        return new Program_Request__Share(
            RowCause = Schema.Program_Request__Share.RowCause.Account_Team__c,
            UserOrGroupId = userId,
            AccessLevel = 'Edit',
            ParentId = requestId
        );
    }

    private Map<Id, List<Program_Request__Share>> indexExistingSharesByParentId (Set<Id> programRequestIds, Set<Id> userIds) {
        Map<Id, List<Program_Request__Share>> sharesByParentId = new Map<Id, List<Program_Request__Share>>();
        for (Program_Request__Share share : [SELECT Id, ParentId, UserOrGroupId FROM Program_Request__Share WHERE ParentId IN :programRequestIds AND UserOrGroupId IN :userIds]) {
            if (sharesByParentId.get(share.ParentId) == null) {
                sharesByParentId.put(share.ParentId, new List<Program_Request__Share>());
            }
            sharesByParentId.get(share.ParentId).add(share);
        }
        return sharesByParentId;
    }
}
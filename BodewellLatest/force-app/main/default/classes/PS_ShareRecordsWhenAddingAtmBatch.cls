public class PS_ShareRecordsWhenAddingAtmBatch implements Database.Batchable<sObject>, Database.Stateful {

    public List<AccountTeamMember> accountTeamMembers;
    public Set<Id> accountIds;
    public String query;
    public String sharedObjectName;

    public PS_ShareRecordsWhenAddingAtmBatch(String sharedObjectName, String accountFieldName, DateTime dateTimeFrom, DateTime dateTimeTo) {
        String accountTeamMembersQuery = 'SELECT AccountId, UserId, LastModifiedDate FROM AccountTeamMember WHERE User.IsActive = TRUE';
        String accountTeamMembersWherePart;
        if (dateTimeFrom != null || dateTimeTo != null) {
            accountTeamMembersWherePart = ' AND ';
            if (dateTimeFrom != null && dateTimeTo != null) {
                accountTeamMembersWherePart += 'LastModifiedDate >= :dateTimeFrom AND LastModifiedDate < :dateTimeTo';
            } else if (dateTimeFrom != null) {
                accountTeamMembersWherePart += 'LastModifiedDate >= :dateTimeFrom';
            } else {
                accountTeamMembersWherePart += 'LastModifiedDate < :dateTimeTo';
            }
        }

        if (String.isNotBlank(accountTeamMembersWherePart)) {
            accountTeamMembersQuery += accountTeamMembersWherePart;
        }

        List<AccountTeamMember> accountTeamMembers = Database.query(accountTeamMembersQuery);

        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for (AccountTeamMember member : accountTeamMembers) {
            accountIds.add(member.AccountId);
            userIds.add(member.UserId);
        }
        this.accountTeamMembers = accountTeamMembers;
        this.accountIds = accountIds;

        String queryPattern = 'SELECT Id, {0} FROM {1} WHERE {2} IN :accountIds';

        this.query = String.format(
            queryPattern,
            new List<String>{accountFieldName, sharedObjectName, accountFieldName}
        );

        this.sharedObjectName = sharedObjectName;
        System.debug(LoggingLevel.DEBUG, 'QUERY PS_ShareRecordsWhenAddingAtmBatch: ' + this.query);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug(LoggingLevel.DEBUG, 'SCOPE SIZE PS_ShareNewRecordsToAtmBatch: ' + scope.size());
        if (scope.isEmpty()) {
            return;
        }
        new PS_ShareRecordsToAccountTeamMembers().createShareRecords(
            this.accountTeamMembers,
            scope,
            sharedObjectName
        );
    }

    public void finish(Database.BatchableContext bc) {}

}
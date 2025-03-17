public class PS_DeleteSharesQueueable implements Queueable {

    public List<AccountTeamMember> members;
    public Set<Id> userIds;
    public Set<Id> accountIds;
    String objectShareName;
    String parentAccountFieldName;
    String rowCause;

    public PS_DeleteSharesQueueable(List<AccountTeamMember> members, String objectShareName, String parentAccountFieldName, String rowCause) {
        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        if (members != null) {
            for (AccountTeamMember member : members) {
                userIds.add(member.UserId);
                accountIds.add(member.AccountId);
            }
        }

        this.members = members;
        this.userIds = userIds;
        this.accountIds = accountIds;
        this.objectShareName = objectShareName;
        this.parentAccountFieldName = parentAccountFieldName;
        this.rowCause = rowCause;
    }

    public void execute(QueueableContext context) {
        if (members == null || members.isEmpty()) {
            return;
        }

        String queryPattern = 'SELECT Id FROM {0} '
            + 'WHERE UserOrGroupId IN :userIds '
                + 'AND {1} IN :accountIds '
                + 'AND RowCause = :rowCause LIMIT 10001';

        String query = String.format(
            queryPattern,
            new List<String>{objectShareName, parentAccountFieldName}
        );

        List<SObject> recordsToDelete = Database.query(query);

        if (recordsToDelete.isEmpty()) {
            return;
        }

        if (recordsToDelete.size() > 10000) {
            Database.executeBatch(
                new PS_DeleteSharesBatch(
                    this.userIds, this.accountIds, this.objectShareName, this.parentAccountFieldName, this.rowCause
                )
            );
        }

        delete recordsToDelete;
    }

}
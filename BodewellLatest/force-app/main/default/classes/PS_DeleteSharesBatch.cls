public class PS_DeleteSharesBatch implements Database.Batchable<sObject> {

    public Set<Id> userIds;
    public Set<Id> accountIds;
    String rowCause;
    public String query;

    public PS_DeleteSharesBatch(
        Set<Id> userIds, Set<Id> accountIds, String objectShareName, String parentAccountFieldName, String rowCause
    ) {
        this.userIds = userIds;
        this.accountIds = accountIds;
        this.rowCause = rowCause;

        String queryPattern = 'SELECT Id FROM {0} '
            + 'WHERE UserOrGroupId IN :userIds '
                + 'AND {1} IN :accountIds '
                + 'AND RowCause = :rowCause';

        this.query = String.format(
            queryPattern,
            new List<String>{objectShareName, parentAccountFieldName}
        );
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        if (scope.isEmpty()) {
            return;
        }
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {}

}
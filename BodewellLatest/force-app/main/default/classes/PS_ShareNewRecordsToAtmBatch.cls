public class PS_ShareNewRecordsToAtmBatch implements Database.Batchable<sObject>, Database.Stateful {

    public String sharedObjectName;
    public String accountFieldName;
    public String query;
    public DateTime dateTimeFrom;
    public DateTime dateTimeTo;
    public Boolean chainShareRecordsWhenAddingAtmBatch;

    public PS_ShareNewRecordsToAtmBatch(
        String sharedObjectName, String accountFieldName,
        DateTime dateTimeFrom, DateTime dateTimeTo, Boolean chainShareRecordsWhenAddingAtmBatch
    ) {
        this.sharedObjectName = sharedObjectName;
        this.accountFieldName = accountFieldName;

        String wherePart;
        if (dateTimeFrom != null || dateTimeTo != null) {
            wherePart = ' WHERE ';
            if (dateTimeFrom != null && dateTimeTo != null) {
                wherePart += 'CreatedDate >= :dateTimeFrom AND CreatedDate < :dateTimeTo';
            } else if (dateTimeFrom != null) {
                wherePart += 'CreatedDate >= :dateTimeFrom';
            } else {
                wherePart += 'CreatedDate < :dateTimeTo';
            }
        }

        String queryPattern = 'SELECT Id, {0} FROM {1}';

        this.query = String.format(
            queryPattern,
            new List<String>{accountFieldName, sharedObjectName}
        );

        if (String.isNotBlank(wherePart)) {
            this.query += wherePart;
        }

        this.dateTimeFrom = dateTimeFrom;
        this.dateTimeTo = dateTimeTo;
        this.chainShareRecordsWhenAddingAtmBatch = chainShareRecordsWhenAddingAtmBatch;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        if (scope.isEmpty()) {
            return;
        }
        new PS_ShareRecordsToAccountTeamMembers().createShareOfNewRecordsToAccountTeamMembers(scope, sharedObjectName);
    }

    public void finish(Database.BatchableContext bc) {
        if (chainShareRecordsWhenAddingAtmBatch != null && chainShareRecordsWhenAddingAtmBatch) {
            runShareRecordsWhenAddingAtmBatch(this.sharedObjectName, this.accountFieldName, this.dateTimeFrom, this.dateTimeTo);
        }
    }

    public static void runShareRecordsWhenAddingAtmBatch(String sharedObjName, String accFieldName, DateTime timeFrom, DateTime timeTo) {
        Database.executeBatch(
            new PS_ShareRecordsWhenAddingAtmBatch(sharedObjName, accFieldName, timeFrom, timeTo)
        );
    }
}
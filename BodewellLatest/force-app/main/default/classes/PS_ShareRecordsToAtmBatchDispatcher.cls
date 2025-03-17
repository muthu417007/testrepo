public class PS_ShareRecordsToAtmBatchDispatcher {

    private DateTime dateTimeFrom;
    private DateTime dateTimeTo;
    private Boolean chainShareRecordsWhenAddingAtmBatch = false;

    public PS_ShareRecordsToAtmBatchDispatcher() {}

    public PS_ShareRecordsToAtmBatchDispatcher withDateTimeFrom(DateTime dateTimeFrom) {
        this.dateTimeFrom = dateTimeFrom;
        return this;
    }

    public PS_ShareRecordsToAtmBatchDispatcher withDateTimeTo(DateTime dateTimeTo) {
        this.dateTimeTo = dateTimeTo;
        return this;
    }

    public PS_ShareRecordsToAtmBatchDispatcher chainShareRecordsWhenAddingAtmBatch() {
        this.chainShareRecordsWhenAddingAtmBatch = true;
        return this;
    }

    public void dispatch() {
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_MEET_COMP, GEA_Constants.FIELD_API_NAME_MEET_COMP_ACCOUNT,
                this.dateTimeFrom, this.dateTimeTo, this.chainShareRecordsWhenAddingAtmBatch
            )
        );
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_PROGRAM_REQUEST, GEA_Constants.FIELD_API_NAME_PROGRAM_REQUEST_ACCOUNT,
                this.dateTimeFrom, this.dateTimeTo, this.chainShareRecordsWhenAddingAtmBatch
            )
        );
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_STORE_PRODUCT, GEA_Constants.FIELD_API_NAME_STORE_PRODUCT_ACCOUNT,
                this.dateTimeFrom, this.dateTimeTo, this.chainShareRecordsWhenAddingAtmBatch
            )
        );
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_CUSTOMER_AGREEMENT, GEA_Constants.FIELD_API_NAME_CUSTOMER_AGREEMENT_ACCOUNT,
                this.dateTimeFrom, this.dateTimeTo, this.chainShareRecordsWhenAddingAtmBatch
            )
        );
        Database.executeBatch(
            new PS_ShareNewRecordsToAtmBatch(
                GEA_Constants.OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE, GEA_Constants.FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_ACCOUNT,
                this.dateTimeFrom, this.dateTimeTo, this.chainShareRecordsWhenAddingAtmBatch
            )
        );
    }

}
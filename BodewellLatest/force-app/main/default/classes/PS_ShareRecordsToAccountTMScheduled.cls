global class PS_ShareRecordsToAccountTMScheduled implements Schedulable {

    global void execute(SchedulableContext sc) {
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, StartTime, PreviousFireTime, NextFireTime
            FROM CronTrigger
            WHERE Id = :sc.getTriggerId()
        ];
        DateTime dateTimeFrom;
        DateTime dateTimeTo;

        dateTimeFrom = ct.NextFireTime.addHours(-2);
        dateTimeTo = dateTimeFrom.addHours(1);

        new PS_ShareRecordsToAtmBatchDispatcher()
            .withDateTimeFrom(dateTimeFrom)
            .withDateTimeTo(dateTimeTo)
            .chainShareRecordsWhenAddingAtmBatch()
            .dispatch();
    }

}
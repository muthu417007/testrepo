trigger PersonalShopper_TimezoneUpdate on ServiceAppointment (before insert,before update) {
    String strFormatedDate;
    String strFormatedMonth;
	for(ServiceAppointment SA : Trigger.New) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            if(SA.Subject == 'Personal Shopper Appointment' && SA.SchedStartTime != null && SA.SchedEndTime != null && SA.ConsumerTimezone__c != null)
            {
                String strTimezone = SA.ConsumerTimezone__c; 
                DateTime dtStartDatetime = DateTime.newInstance(SA.SchedStartTime.year(), SA.SchedStartTime.month(), SA.SchedStartTime.day(), SA.SchedStartTime.hour(), SA.SchedStartTime.minute(), SA.SchedStartTime.second());
                SA.ConsumerSchedStartDateTime__c = dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone);
                SA.ConsumerSchedStartDate__c = dtStartDatetime.format('MM-dd-yyyy hh:mm a', strTimezone).mid(0, 10);
                SA.ConsumerSchedStartTime__c = dtStartDatetime.format('MM-dd-yyyy hh:mm a', strTimezone).mid(11, 11);
                if(dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '01')
                {
                    strFormatedMonth = 'January';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '02')
                {
                    strFormatedMonth = 'February';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '03')
                {
                    strFormatedMonth = 'March';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '04')
                {
                    strFormatedMonth = 'April';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '05')
                {
                    strFormatedMonth = 'May';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '06')
                {
                    strFormatedMonth = 'June';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '07')
                {
                    strFormatedMonth = 'July';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '08')
                {
                    strFormatedMonth = 'August';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '09')
                {
                    strFormatedMonth = 'September';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '10')
                {
                    strFormatedMonth = 'October';
                }
                else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '11')
                {
                    strFormatedMonth = 'November';
                }
				else if (dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(0, 2)== '12')
                {
                    strFormatedMonth = 'December';
                }       
                strFormatedDate= dtStartDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone).mid(3, 2);
                if(strFormatedDate=='01')
                {
                    strFormatedDate = '1st';
                }
                else if(strFormatedDate=='02')
                {
                    strFormatedDate = '2nd';
                }
                else if(strFormatedDate=='03')
                {
                    strFormatedDate = '3rd';
                }
                else 
                {
                    strFormatedDate = strFormatedDate + 'th';
                }
                SA.ConsumerScheduledStartDate__c = strFormatedMonth + ' ' + strFormatedDate;
                DateTime dtEndDatetime = DateTime.newInstance(SA.SchedEndTime.year(), SA.SchedEndTime.month(), SA.SchedEndTime.day(), SA.SchedEndTime.hour(), SA.SchedEndTime.minute(), SA.SchedEndTime.second());
                SA.ConsumerSchedEndDateTime__c = dtEndDatetime.format('MM-dd-yyyy hh:mm:ss a', strTimezone);
                SA.ConsumerSchedEndDate__c = dtEndDatetime.format('MM-dd-yyyy hh:mm a', strTimezone).mid(0, 10);
                SA.ConsumerSchedEndTime__c = dtEndDatetime.format('MM-dd-yyyy hh:mm a', strTimezone).mid(11, 11);
            }
        }
    }
}
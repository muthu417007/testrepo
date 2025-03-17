global class PS_MeetCompNotification_Scheduler implements PS_MeetCompNotification_Dispatcher.IScheduleDispatched {
	global void execute(SchedulableContext SC) {
		PS_MeetCompReminder_Batch batch = new PS_MeetCompReminder_Batch(); 
    	database.executebatch(batch);
   	}
}
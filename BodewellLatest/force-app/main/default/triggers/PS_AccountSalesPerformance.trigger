trigger PS_AccountSalesPerformance on Account_Sales_Performance__c (after insert) {
	PS_TriggerDispatcher.run(new PS_AccountSalesPerformanceTriggerHandler());
}
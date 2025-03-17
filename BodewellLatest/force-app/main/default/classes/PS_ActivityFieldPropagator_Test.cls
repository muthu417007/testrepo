@isTest
public class PS_ActivityFieldPropagator_Test {

    @testSetup
    static void setup() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
		Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');

        Account retailAccount = new Account(Name = 'retailAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL));
        Account retailNationalAccount = new Account(Name = 'retailNationalAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL));
        Account locationAccount = new Account(Name = 'locationAccount');
        insert new List<Account> {retailAccount, locationAccount, retailNationalAccount};

        Task t1 = new Task(Subject = 'task1', Status = 'Not Started', whatId = retailAccount.id, TaskSubType = 'Call');
        Task t2 = new Task(Subject = 'task2', Status = 'Not Started', whatId = retailAccount.id, TaskSubType = 'Email');
        Task t3 = new Task(Subject = 'task3', Status = 'Not Started', whatId = retailAccount.id, TaskSubType = 'Call');
        Task t4 = new Task(Subject = 'task4', Status = 'Not Started', whatId = retailNationalAccount.id, TaskSubType = 'Call');
        Task t5 = new Task(Subject = 'task5', Status = 'Not Started', whatId = locationAccount.id, TaskSubType = 'Call');
        insert new List<Task> {t1, t2, t3, t4, t5};
    }
    
    @isTest
	static void siteShouldSetActivityDatesOnAccount () {
        //GIVEN
		Task[] tasks = [SELECT Status FROM Task];
        for (Task t : tasks) {
            t.Status = 'Complete';
        }
        
        //WHEN
        update tasks;
        
        //THEN
        Account retailAccount = [SELECT Last_Call_Date__c FROM Account WHERE Name = 'retailAccount'];
       	Account retailNationalAccount = [SELECT Last_Call_Date__c FROM Account WHERE Name = 'retailNationalAccount'];
        Account locationAccount = [SELECT Last_Call_Date__c FROM Account WHERE Name = 'locationAccount'];
        
        System.assertEquals(System.today(), retailAccount.Last_Call_Date__c);
        System.assertEquals(System.today(), retailNationalAccount.Last_Call_Date__c);
        System.assertEquals(null, locationAccount.Last_Call_Date__c);
    }

    @isTest
    static void coverageForPS_ITriggerHandler () {
        PS_Task_TriggerHandler handler = new PS_Task_TriggerHandler();
        handler.beforeInsert(new List<SObject>());
        handler.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        handler.beforeDelete(new Map<Id, SObject>());
        handler.afterDelete(new Map<Id, SObject>());
    }
}
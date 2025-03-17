@isTest
private class PS_VisitFieldPropagator_Test {

    @testSetup
    static void setup() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
		Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');

        Account retailAccount = new Account(Name = 'retailAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL));
        Account retailNationalAccount = new Account(Name = 'retailNationalAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL));
        Account locationAccount = new Account(Name = 'locationAccount');
        insert new List<Account> {retailAccount, locationAccount, retailNationalAccount};

        Schema.Location testLocation = new Schema.Location(Name = 'test');
        insert testLocation;

        RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = retailAccount.Id, LocationId = testLocation.Id);
        RetailStore rs2 = new RetailStore(Name = 'rs2', AccountId = retailNationalAccount.Id, LocationId = testLocation.Id);
        RetailStore rs3 = new RetailStore(Name = 'rs3', AccountId = locationAccount.Id, LocationId = testLocation.Id);
        insert new List<RetailStore> {rs1, rs2, rs3};

        Visit v1 = new Visit(
            Subject__c = 'visit1', Status = 'Planned', AccountId = retailAccount.id,
            PlaceId = rs1.Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
        Visit v2 = new Visit(
            Subject__c = 'visit2', Status = 'Planned', AccountId = retailNationalAccount.id,
            PlaceId = rs2.Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
 		Visit v3 = new Visit(
            Subject__c = 'visit3', Status = 'Planned', AccountId = locationAccount.id,
            PlaceId = rs3.Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );
        Visit v4 = new Visit(
            Subject__c = 'visit4', Status = 'Planned', AccountId = retailAccount.id,
            PlaceId = rs1.Id, PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5), VisitorId = UserInfo.getUserId()
        );

        insert new List<Visit> {v1, v2, v3, v4};
    }

    @isTest
	static void shouldSetLastVisitDateOnAccount () {
        //GIVEN
		Visit[] visits = [SELECT Status, Subject__c, ActualVisitEndTime FROM Visit];
        for (Visit v : visits) {
            v.Status = 'Completed';
            if (v.Subject__c == 'visit1') {
                v.ActualVisitEndTime = System.now();
            } else if (v.Subject__c == 'visit2') {
                v.ActualVisitEndTime = System.now();
            } else if (v.Subject__c == 'visit3') {
                v.ActualVisitEndTime = System.now();
            } else if (v.Subject__c == 'visit4') {
                v.ActualVisitEndTime = System.now().addDays(2);
            }
        }

        //WHEN
        update visits;

        //THEN
        Account retailAccount = [SELECT Last_Visit_Date__c FROM Account WHERE Name = 'retailAccount'];
       	Account retailNationalAccount = [SELECT Last_Visit_Date__c FROM Account WHERE Name = 'retailNationalAccount'];
        Account locationAccount = [SELECT Last_Visit_Date__c FROM Account WHERE Name = 'locationAccount'];

        System.assertEquals(System.today().addDays(2), retailAccount.Last_Visit_Date__c);
        System.assertEquals(System.today(), retailNationalAccount.Last_Visit_Date__c);
        System.assertEquals(null, locationAccount.Last_Visit_Date__c);
    }

    @isTest
    static void shouldCreateAdditionalVisitTasksWhenVisitInProgress() {
        //GIVEN
        PS_AccountTriggerHandler.TriggerDisabled = true;
		Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account testRetailAccount = new Account(
            Name = 'testRetailAccount',
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL)
        );
        insert testRetailAccount;

        Schema.Location testLocation = new Schema.Location(Name = 'testLocation');
        insert testLocation;

        RetailStore testRetailStore1 = new RetailStore(
            Name = 'retailStore1',
            AccountId = testRetailAccount.Id,
            LocationId = testLocation.Id
        );
        RetailStore testRetailStore2 = new RetailStore(
            Name = 'retailStore2',
            AccountId = testRetailAccount.Id,
            LocationId = testLocation.Id
        );
        RetailStore testRetailStore3 = new RetailStore(
            Name = 'retailStore3',
            AccountId = testRetailAccount.Id,
            LocationId = testLocation.Id
        );
        insert new List<RetailStore> {testRetailStore1, testRetailStore2, testRetailStore3};

        Showroom_Display_Location_Action__c action0 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore1.Id,
            Task_Name__c = 'Task name 0',
            Task_Description__c = 'Task description 0',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = false,
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(1),
            Recurrence__c = 'One Time'
        );
        Showroom_Display_Location_Action__c action1 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore1.Id,
            Task_Name__c = 'Task name',
            Task_Description__c = 'Task description',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = false,
            Start_Date__c = System.today().addDays(9),
            End_Date__c = System.today().addDays(11),
            Recurrence__c = 'One Time'
        );

        insert new List<Showroom_Display_Location_Action__c>{action0, action1};

        Visit testVisit1 = new Visit(
            Subject__c = 'visit1',
            Status = 'Planned',
            AccountId = testRetailAccount.id,
            PlaceId = testRetailStore1.Id,
            PlannedVisitStartTime = System.today().addDays(10),
            PlannedVisitEndTime = System.today().addDays(13),
            VisitorId = UserInfo.getUserId()
        );
        Visit testVisit2 = new Visit(
            Subject__c = 'visit12',
            Status = 'Planned',
            AccountId = testRetailAccount.id,
            PlaceId = testRetailStore2.Id,
            PlannedVisitStartTime = System.today().addDays(3),
            PlannedVisitEndTime = System.today().addDays(5),
            VisitorId = UserInfo.getUserId()
        );
        Visit testVisit3 = new Visit(
            Subject__c = 'visit13',
            Status = 'Planned',
            AccountId = testRetailAccount.id,
            PlaceId = testRetailStore3.Id,
            PlannedVisitStartTime = System.today().addDays(3),
            PlannedVisitEndTime = System.today().addDays(5),
            VisitorId = UserInfo.getUserId()
        );
        insert new List<Visit>{testVisit1, testVisit2, testVisit3};

        List<Visit_Task__c> visitTasksCreated = [SELECT Id FROM Visit_Task__c];
        System.assertEquals(1, visitTasksCreated.size(), 'Number of created visit tasks should be equal 2');

        Showroom_Display_Location_Action__c action2 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore1.Id,
            Task_Name__c = 'Task name 2',
            Task_Description__c = 'Task description 2',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = false,
            Start_Date__c = System.today().addDays(9),
            End_Date__c = System.today().addDays(11),
            Recurrence__c = 'One Time'
        );
        Showroom_Display_Location_Action__c action3 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore2.Id,
            Task_Name__c = 'Task name 3',
            Task_Description__c = 'Task description 3',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = true,
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(4),
            Recurrence__c = 'Repeat While Active'
        );
        Showroom_Display_Location_Action__c action4 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore3.Id,
            Task_Name__c = 'Task name 4',
            Task_Description__c = 'Task description 4',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = true,
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(4),
            Recurrence__c = 'Repeat While Active'
        );
        insert new List<Showroom_Display_Location_Action__c>{action2, action3, action4};

        //WHEN
        testVisit1.Status = 'InProgress';
        testVisit2.Status = 'InProgress';
        testVisit3.Status = 'InProgress';
        update new List<Visit>{testVisit1, testVisit2, testVisit3};

        //THEN
        visitTasksCreated = [SELECT Id FROM Visit_Task__c];
        System.assertEquals(4, visitTasksCreated.size(), 'Number of created visit tasks should be equal 4');

        List<Visit_Task__c> newlyVisitTasksCreated1 = [SELECT Id, Visit__c FROM Visit_Task__c WHERE Task_Name__c = :action2.Task_Name__c];
        System.assertEquals(
            1,
            newlyVisitTasksCreated1.size(),
            'Number of created visit tasks with Task_Name__c = \'' + action2.Task_Name__c + '\' should be equal 1')
        ;
        System.assertEquals(testVisit1.Id, newlyVisitTasksCreated1[0].Visit__c);

        List<Visit_Task__c> newlyVisitTasksCreated2 = [SELECT Id, Visit__c FROM Visit_Task__c WHERE Task_Name__c = :action3.Task_Name__c];
        System.assertEquals(
            1,
            newlyVisitTasksCreated2.size(),
            'Number of created visit tasks with Task_Name__c = \'' + action3.Task_Name__c + '\' should be equal 1'
        );
        System.assertEquals(testVisit2.Id, newlyVisitTasksCreated2[0].Visit__c);

        List<Visit_Task__c> newlyVisitTasksCreated3 = [SELECT Id, Visit__c FROM Visit_Task__c WHERE Task_Name__c = :action4.Task_Name__c];
        System.assertEquals(
            1,
            newlyVisitTasksCreated3.size(),
            'Number of created visit tasks with Task_Name__c = \'' + action4.Task_Name__c + '\' should be equal 1'
        );
        System.assertEquals(testVisit3.Id, newlyVisitTasksCreated3[0].Visit__c);
    }

    @isTest
    static void shouldNotCreateAdditionalVisitTasksWhenVisitInProgress() {
        //GIVEN
        PS_AccountTriggerHandler.TriggerDisabled = true;
		Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');
        Account testRetailAccount = new Account(
            Name = 'testRetailAccount',
            RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL)
        );
        insert testRetailAccount;

        Schema.Location testLocation = new Schema.Location(Name = 'testLocation');
        insert testLocation;

        RetailStore testRetailStore = new RetailStore(
            Name = 'testRetailStore',
            AccountId = testRetailAccount.Id,
            LocationId = testLocation.Id
        );
        insert testRetailStore;

        Showroom_Display_Location_Action__c action1 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore.Id,
            Task_Name__c = 'Task name',
            Task_Description__c = 'Task description',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = false,
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(4),
            Recurrence__c = 'One Time'
        );

        insert action1;

        Visit testVisit1 = new Visit(
            Subject__c = 'visit1',
            Status = 'Planned',
            AccountId = testRetailAccount.id,
            PlaceId = testRetailStore.Id,
            PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5),
            VisitorId = UserInfo.getUserId()
        );
        Visit testVisit2 = new Visit(
            Subject__c = 'visit12',
            Status = 'Planned',
            AccountId = testRetailAccount.id,
            PlaceId = testRetailStore.Id,
            PlannedVisitStartTime = System.today().addDays(2),
            PlannedVisitEndTime = System.today().addDays(5),
            VisitorId = UserInfo.getUserId()
        );
        insert new List<Visit>{testVisit1, testVisit2};

        List<Visit_Task__c> visitTasksCreated = [SELECT Id FROM Visit_Task__c];
        System.assertEquals(2, visitTasksCreated.size(), 'Number of created visit tasks should be equal 2');

        Showroom_Display_Location_Action__c action2 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore.Id,
            Task_Name__c = 'Task name 2',
            Task_Description__c = 'Task description 2',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = false,
            Start_Date__c = System.today().addDays(6),
            End_Date__c = System.today().addDays(10),
            Recurrence__c = 'One Time'
        );
        Showroom_Display_Location_Action__c action3 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore.Id,
            Task_Name__c = 'Task name 3',
            Task_Description__c = 'Task description 3',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = false,
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(1),
            Recurrence__c = 'One Time'
        );
        Showroom_Display_Location_Action__c action4 = new Showroom_Display_Location_Action__c(
            Showroom_Display_Location__c = testRetailStore.Id,
            Task_Name__c = 'Task name 4',
            Task_Description__c = 'Task description 4',
            Task_Type__c = 'Text',
            IsRequired__c = false,
            Complete__c = true,
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(4),
            Recurrence__c = 'One Time'
        );
        insert new List<Showroom_Display_Location_Action__c>{action2, action3, action4};

        //WHEN
        testVisit1.Status = 'InProgress';
        testVisit2.Status = 'InProgress';
        update new List<Visit>{testVisit1, testVisit2};

        //THEN
        visitTasksCreated = [SELECT Id FROM Visit_Task__c];
        System.assertEquals(2, visitTasksCreated.size(), 'Number of created visit tasks should be equal 2');

        visitTasksCreated = [SELECT Id FROM Visit_Task__c WHERE Task_Name__c = :action1.Task_Name__c];
        System.assertEquals(
            2,
            visitTasksCreated.size(),
            'Number of created visit tasks with Task_Name__c = \'' + action1.Task_Name__c + '\' should be equal 2');
    }

    @isTest
	static void coverageForPS_ITriggerHandler () {
        PS_Visit_TriggerHandler handler = new PS_Visit_TriggerHandler();
        handler.beforeInsert(new List<SObject>());
        handler.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        handler.beforeDelete(new Map<Id, SObject>());
        handler.afterDelete(new Map<Id, SObject>());
    }

}
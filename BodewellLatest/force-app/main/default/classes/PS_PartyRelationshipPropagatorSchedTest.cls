@IsTest
public class PS_PartyRelationshipPropagatorSchedTest {

    @testSetup
    static void setup() {
        PS_AccountTriggerHandler.TriggerDisabled = true;
        Map<String, Id> rtIdByName = PS_Util.buildMapOfRecordTypes('Account');

        Account partyAccount1 = new Account(Name = 'partyAccount1', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY));
        Account partyAccount2 = new Account(Name = 'partyAccount2', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_PARTY));
        insert new List<Account> {partyAccount1, partyAccount2};

        Account retailAccount = new Account(ParentId = partyAccount1.Id, Name = 'retailAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL));
        Account retailNationalAccount = new Account(ParentId = partyAccount1.Id, Name = 'retailNationalAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL));
        Account contractDirectAccount = new Account(ParentId = partyAccount2.Id, Name = 'contractDirectAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT));
        Account contractDistributorAccount = new Account(ParentId = partyAccount2.Id, Name = 'contractDistributorAccount', RecordTypeId = rtIdByName.get(GEA_Constants.RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR));
        insert new List<Account> {retailAccount, retailNationalAccount, contractDirectAccount, contractDistributorAccount};
        Party_Relationship__c pr1 = new Party_Relationship__c (
            Party__c = partyAccount1.Id,
            Status__c = 'A',
            Relationship_Type__c = 'waive freight',
            Party_Relationship_Name__c = 'party relationship Name 1',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );

        Party_Relationship__c pr2 = new Party_Relationship__c (
            Party__c = partyAccount2.Id,
            Status__c = 'A',
            Relationship_Type__c = 'commercial consolidation',
            Party_Relationship_Name__c = 'party relationship Name 2',
            Relationship_Role__c = 'BUYING_GROUP_FOR'
        );

        //WHEN
        insert new List<Party_Relationship__c> {pr1, pr2};
    }

    static testmethod void execute_ShouldScheduleJob() {
        //GIVEN
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2031';

        //WHEN
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP,  new PS_PartyRelationshipPropagatorDispatcher());

        //THEN
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2031-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}
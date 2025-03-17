@isTest(SeeAllData=true)
public class Test_VRACreateImages {
    @isTest static void createHistoryRecord() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new VRAMockCallout());
        tspa__Visual_History__c tvh = [Select id,tspa__Invite_Type__c,tspa__Session_Status__c,tspa__Status__c,tspa__Session_Id__c,tspa__Related_Record_ID__c,tspa__Device_Type__c,tspa__Invite_Destination__c,tspa__Device_Browser__c,tspa__Reference_ID__c from tspa__Visual_History__c limit 1];
        tspa__Visual_History__c testrecord = tvh.clone();
        testrecord.tspa__Session_Id__c='60952de5ec9c915025821d8a';
        testrecord.tspa__Session_Status__c='closed';
        testrecord.tspa__Status__c='closed';
        testrecord.tspa__Invite_Type__c='Observer';
        String accRecordType = [Select Name,Id from recordtype where sobjecttype='Account' and Name='Location' limit 1].Id;
        Account acc = new Account(Name='Test Account',RecordTypeId=accRecordType);
        insert acc;
        Case newCase = new Case(Subject='Test Case',Reason='Service',AccountId=acc.id);
        insert newCase;
        Case cs = [Select id,casenumber from case where id=:newCase.Id];
        system.debug('casenumber'+cs.casenumber);
        testrecord.tspa__Reference_ID__c=cs.Id;
        insert testrecord;
        test.stopTest();
    }
}
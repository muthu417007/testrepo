@IsTest
public with sharing class PS_UpdateContactGlobalIdBatchTest {

    @IsTest
    public static void shouldUpdateContactsGlobalId() {
        //given
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 400; i++) {
            contacts.add(
                    new Contact(
                            LastName = 'TestLastName' + i,
                            Email = 'test' + i + '@test.com'
                    )
            );
        }
        insert contacts;

        contacts.clear();
        for (Contact contact : [SELECT Id FROM Contact]) {
            contact.Global_Customer_Id__c = null;
            contacts.add(contact);
        }
        update contacts;

        //then
        Test.startTest();
        Database.executeBatch(new PS_UpdateContactGlobalIdBatch(), 400);
        Test.stopTest();

        System.assertEquals(
                400,
                [SELECT Id FROM Contact WHERE Global_Customer_Id__c != NULL].size(),
                'Invalid number of contacts without GlobalId value'
        );
    }
}
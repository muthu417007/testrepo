@isTest
private class ContactTriggerHandlerTest {

    final static String PROFILE_NAME_SYSTEM_ADMINISTRATOR = 'System Administrator';
    final static String PROFILE_NAME_BASE_SALES_CONTRACT = 'Base Sales - Contract';
    final static String RT_STANDARD = 'Standard';
    final static String RT_ARCHITECT_DESIGNER = 'Architect_Designer';
    final static String RT_INSTALLATION_CONTRACTOR = 'Installation_Contractor';
    final static String RT_DELIVERY_AGENT = 'Delivery_Agent';
    static Map<String, Id> contactRtIdByName = PS_Util.buildMapOfRecordTypes('Contact');

    @TestSetup
    static void makeData() {
        Id systemAdministratorProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_SYSTEM_ADMINISTRATOR].Id;
        Id baseSalesContractProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_BASE_SALES_CONTRACT].Id;


        List<User> users = new List<User>();
        users.add(
                new User(
                        firstName = 'Abc',
                        lastName = 'xyz',
                        Alias = 'abcbc',
                        profileId = systemAdministratorProfileId,
                        username = 'abcabc.xyz@test.com',
                        email = 'test@test.com',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US'
                )
        );
        users.add(
                new User(
                        firstName = 'Abcd',
                        lastName = 'xyza',
                        Alias = 'abcbd',
                        profileId = baseSalesContractProfileId,
                        username = 'abcabc.xyz2@test.com',
                        email = 'test2@test.com',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US')
        );
        users.add(
                new User(
                        firstName = 'Data',
                        lastName = 'Integration',
                        Alias = 'daint',
                        profileId = systemAdministratorProfileId,
                        username = 'data.Integration@test.com',
                        email = 'test3@test.com',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US')
        );
        insert users;
    }
    
    @isTest
    static void testEventsRegisteredUpdate(){
        User dataIntegrationUser = [Select Id from User where username='data.Integration@test.com'];
        List<Contact> contacts = new List<Contact>();
        contacts.add(
                    new contact(
                            LastName = 'ContactEventRegistration',
                            RecordTypeId = contactRtIdByName.get(RT_ARCHITECT_DESIGNER),
                        	Events_Registered__c = 'Test Event'
                    )
            );
        insert contacts;
        System.runAs(dataIntegrationUser) {
            Contact con = [Select id, events_registered__c from contact where lastname='ContactEventRegistration'];
            con.events_registered__c = 'Test Event 2022-07-24';
            update con;
        }
        
    }

    @isTest
    static void testDeletionAllowed() {
        User systemAdministratorUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz@test.com'];
        User baseSalesContractUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        List<Contact> contacts = new List<Contact>();

        System.runAs(systemAdministratorUser) {
            contacts.add(
                    new contact(
                            LastName = 'Contact1',
                            RecordTypeId = contactRtIdByName.get(RT_STANDARD)
                    )
            );
            contacts.add(
                    new contact(
                            LastName = 'Contact2',
                            RecordTypeId = contactRtIdByName.get(RT_DELIVERY_AGENT)
                    )
            );

            insert contacts;

            Set<Id> contactIds = new Set<Id>();
            for (Contact contact : contacts) {
                contactIds.add(contact.Id);
            }

            delete contacts;

            List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact WHERE Id = :contactIds ALL ROWS];
            for (Contact deletedContact : deletedContacts) {
                System.assert(deletedContact.IsDeleted, 'Contact should be deleted by System Administrator');
            }
        }

        contacts.clear();

        System.runAs(baseSalesContractUser) {
            contacts.add(
                    new contact(
                            LastName = 'Contact1',
                            RecordTypeId = contactRtIdByName.get(RT_STANDARD)
                    )
            );
            contacts.add(
                    new contact(
                            LastName = 'Contact2',
                            RecordTypeId = contactRtIdByName.get(RT_ARCHITECT_DESIGNER)
                    )
            );
            contacts.add(
                    new contact(
                            LastName = 'Contact3',
                            RecordTypeId = contactRtIdByName.get(RT_INSTALLATION_CONTRACTOR)
                    )
            );

            insert contacts;

            Set<Id> contactIds = new Set<Id>();
            for (Contact contact : contacts) {
                contactIds.add(contact.Id);
            }

            delete contacts;

            List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact WHERE Id = :contactIds ALL ROWS];
            for (Contact deletedContact : deletedContacts) {
                System.assert(deletedContact.IsDeleted, 'Contact should be deleted by ASM user');
            }
        }
    }

    @isTest
    static void testDeletionDisallowed() {
        User baseSalesContractUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz2@test.com'];

        Contact contact = new Contact(
                LastName = 'Contact1',
                RecordTypeId = contactRtIdByName.get(RT_DELIVERY_AGENT)
        );
        System.runAs(baseSalesContractUser) {
            insert contact;

            try {
                delete contact;
            } catch (Exception ex) {
                System.assert(
                        ex.getMessage().contains(Label.CannotDeleteContact),
                        'Exception message should contain: \'' + Label.CannotDeleteContact + '\''
                );
            }

        }
    }

    @isTest
    static void shouldCreateContactRoleWhenCreatingContact() {
        Account retailAccount = new Account(
                Name = 'retailAccount',
                Oracle_Type__c = GEA_Constants.ORACLE_TYPE_ACCOUNT,
                Channel__c = GEA_Constants.ACCOUNT_CHANNEL_RETAIL
        );
        insert retailAccount;

        Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = retailAccount.Id,
                StageName = 'New',
                CloseDate = Date.today().addDays(5)
        );

        insert opp;

        Contact con = new Contact(
                LastName = 'Contact1',
                RecordTypeId = contactRtIdByName.get(RT_DELIVERY_AGENT),
                Related_Opportunity__c = opp.Id
        );

        insert con;

        List<OpportunityContactRole> ocRoles = [SELECT OpportunityId, ContactId FROM OpportunityContactRole];

        System.assert(ocRoles.size() > 0, 'Contact Role list should not be empty');
        System.assertEquals(opp.Id, ocRoles[0].OpportunityId, 'Contact Role Opportunity ID does not expected');
        System.assertEquals(con.Id, ocRoles[0].ContactId, 'Contact Role Contact ID does not expected');

        Contact insertedContact = [SELECT Related_Opportunity__c FROM Contact WHERE Id = :con.Id];
        System.assert(insertedContact.Related_Opportunity__c == null, 'Related Opportunity field value should be cleared after contact is inserted');
    }

    @isTest
    static void shouldNotCreateContactRoleWhenCreatingContact() {
        Account retailAccount = new Account(
                Name = 'retailAccount',
                Oracle_Type__c = GEA_Constants.ORACLE_TYPE_ACCOUNT,
                Channel__c = GEA_Constants.ACCOUNT_CHANNEL_RETAIL
        );
        insert retailAccount;

        Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = retailAccount.Id,
                StageName = 'New',
                CloseDate = Date.today().addDays(5)
        );

        insert opp;

        Contact con = new Contact(
                LastName = 'Contact1',
                RecordTypeId = contactRtIdByName.get(RT_DELIVERY_AGENT)
        );

        insert con;

        List<OpportunityContactRole> ocRoles = [SELECT OpportunityId, ContactId FROM OpportunityContactRole];

        System.assert(ocRoles.isEmpty(), 'Contact Roles should not be created');
    }

    @IsTest
    public static void shouldSavePreviousEmail_WhenContactEmailUpdated() {
        User systemAdministratorUser = [SELECT Id FROM User WHERE Username = 'abcabc.xyz@test.com'];

        Contact contact;

        System.runAs(systemAdministratorUser) {
            contact = new Contact(
                    LastName = 'Contact1',
                    Email = 'test1@email.com',
                    RecordTypeId = contactRtIdByName.get(RT_STANDARD)
            );
            insert contact;
        }

        Test.startTest();
        contact.Email = 'test2@email.com';
        update contact;
        Test.stopTest();

        Contact updatedContact = [
                SELECT Email,Previous_Emails__c
                FROM Contact
                WHERE
                        Id = :contact.Id
                LIMIT 1
        ];

        System.assertEquals(
                'test2@email.com',
                updatedContact.Email,
                'Invalid new email value'
        );

        System.assertEquals(
                'test1@email.com',
                updatedContact.Previous_Emails__c,
                'Invalid previous emails value'
        );
    }
}
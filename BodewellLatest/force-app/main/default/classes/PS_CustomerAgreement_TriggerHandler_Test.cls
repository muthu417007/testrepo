@isTest
private class PS_CustomerAgreement_TriggerHandler_Test {

    final static String PROFILE_NAME_BASE_SALES_CONTRACT = 'Base Sales - Contract';

    @testSetup
	static void setup() {
        Account acc1 = new Account(Name = 'Account 1');
        insert acc1;

        Profile prof = [select Id from profile where name LIKE '%System Administrator%'];
        Id baseSalesContractProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_BASE_SALES_CONTRACT].Id;
        List<User> users = new List<User>();
        users.add(new User(
            firstName = 'Abc',
            lastName = 'xyz',
            Alias = 'abcbc',
            profileId = prof.id,
            username = 'abcabc.xyz@test.com',
            email = 'test@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        users.add(new User(
            firstName = 'Abcd',
            lastName = 'xyza',
            Alias = 'abcbd',
            profileId = prof.id,
            username = 'abcabc.xyz2@test.com',
            email = 'test2@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        users.add(new User(
            firstName = 'Abcde',
            lastName = 'xyzb',
            Alias = 'abcbe',
            profileId = baseSalesContractProfileId,
            username = 'abcabc.xyz3@test.com',
            email = 'test3@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        insert users;
    }

    @isTest
    static void onDelete_shouldAllowDeletion() {
        User systemAdministratorUser = [SELECT Id FROM User WHERE Username = 'abcabc.xyz@test.com'];
        User baseSalesContractUser = [SELECT Id FROM User WHERE Username = 'abcabc.xyz3@test.com'];

        List<Customer_Agreement__c> agreements = new List<Customer_Agreement__c>();

        System.runAs(systemAdministratorUser) {
            agreements.add(
                new Customer_Agreement__c(DocuSign_Envelope_Status__c = 'Completed')
            );
            agreements.add(
                new Customer_Agreement__c()
            );

            insert agreements;

            Set<Id> agreementIds = new Set<Id>();
            for(Customer_Agreement__c agreement : agreements) {
                agreementIds.add(agreement.Id);
            }

            delete agreements;

            List<Customer_Agreement__c> deletedAgreements = [SELECT Id, IsDeleted FROM Customer_Agreement__c WHERE Id = :agreementIds ALL ROWS];
            for (Customer_Agreement__c deletedAgreement : deletedAgreements) {
                System.assert(deletedAgreement.IsDeleted, 'Customer Agreements should be deleted by System Administrator');
            }
        }

        agreements.clear();

        System.runAs(baseSalesContractUser) {
            agreements.add(
                new Customer_Agreement__c()
            );

            insert agreements;

            Set<Id> agreementIds = new Set<Id>();
            for(Customer_Agreement__c agreement : agreements) {
                agreementIds.add(agreement.Id);
            }

            delete agreements;

            List<Customer_Agreement__c> deletedAgreements = [SELECT Id, IsDeleted FROM Customer_Agreement__c WHERE Id = :agreementIds ALL ROWS];
            for (Customer_Agreement__c deletedAgreement : deletedAgreements) {
                System.assert(deletedAgreement.IsDeleted, 'Customer Agreements should be deleted by B2B Sales user');
            }
        }
    }

    @isTest
    static void onDelete_shouldPreventDeletion() {
        User baseSalesContractUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz3@test.com'];

        List<Customer_Agreement__c> agreements = new List<Customer_Agreement__c>();
        System.runAs(baseSalesContractUser) {
            agreements.add(
                new Customer_Agreement__c(DocuSign_Envelope_Status__c = 'Completed')
            );

            insert agreements;

            List<Database.DeleteResult> deleteResults = Database.delete(agreements, false);

            Integer unsuccessfulDeletionsCount = 0;
            for (Database.DeleteResult result : deleteResults) {
                if (!result.isSuccess()) {
                    unsuccessfulDeletionsCount++;
                    System.assert(
                        result.getErrors()[0].getMessage().contains(Label.PS_CANNOT_DELETE_CUSTOMER_AGREEMENT),
                        'Exception message should contain: \'' + Label.PS_CANNOT_DELETE_CUSTOMER_AGREEMENT + '\''
                    );
                }
            }
            System.assertEquals(
                agreements.size(),
                unsuccessfulDeletionsCount,
                'Number of unsuccessful deletions should be equals ' + agreements.size()
            );
        }
    }

    static testMethod void testEmptyMethods () {
        new PS_CustomerAgreement_TriggerHandler().beforeInsert(null);
        new PS_CustomerAgreement_TriggerHandler().beforeDelete(null);
        new PS_CustomerAgreement_TriggerHandler().beforeUpdate(null, null);
        new PS_CustomerAgreement_TriggerHandler().afterUpdate(null, null);
        new PS_CustomerAgreement_TriggerHandler().afterDelete(null);
    }
}
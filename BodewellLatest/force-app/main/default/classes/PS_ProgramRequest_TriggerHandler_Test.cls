@isTest
private class PS_ProgramRequest_TriggerHandler_Test {

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

        List<Program_Request__c> requests = new List<Program_Request__c>();

        System.runAs(systemAdministratorUser) {
            requests.add(
                new Program_Request__c(
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3),
                    Stage_Name__c = GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_DRAFT
                )
            );
            requests.add(
                new Program_Request__c(
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3),
                    Stage_Name__c = GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_AWAITING_APPROVAL
                )
            );
            requests.add(
                new Program_Request__c(
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3),
                    Stage_Name__c = GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_APPROVED
                )
            );
            requests.add(
                new Program_Request__c(
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3),
                    Stage_Name__c = GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_REJECTED
                )
            );

            insert requests;

            Set<Id> requestIds = new Set<Id>();
            for(Program_Request__c request : requests) {
                requestIds.add(request.Id);
            }

            delete requests;

            List<Program_Request__c> deletedRequests = [SELECT Id, IsDeleted FROM Program_Request__c WHERE Id = :requestIds ALL ROWS];
            for (Program_Request__c deletedRequest : deletedRequests) {
                System.assert(deletedRequest.IsDeleted, 'Customer Programs should be deleted by System Administrator');
            }
        }

        requests.clear();

        System.runAs(baseSalesContractUser) {
            requests.add(
                new Program_Request__c(
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3),
                    Stage_Name__c = GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_DRAFT
                )
            );

            insert requests;

            Set<Id> requestIds = new Set<Id>();
            for(Program_Request__c request : requests) {
                requestIds.add(request.Id);
            }

            delete requests;

            List<Program_Request__c> deletedRequests = [SELECT Id, IsDeleted FROM Program_Request__c WHERE Id = :requestIds ALL ROWS];
            for (Program_Request__c deletedRequest : deletedRequests) {
                System.assert(deletedRequest.IsDeleted, 'Customer Programs should be deleted by B2B Sales user');
            }
        }
    }

    @isTest
    static void onDelete_shoulPreventDeletion() {
        User baseSalesContractUser = [SELECT Id FROM User WHERE username = 'abcabc.xyz3@test.com'];

        List<Program_Request__c> requests = new List<Program_Request__c>();
        System.runAs(baseSalesContractUser) {
            requests.add(
                new Program_Request__c(
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3),
                    Stage_Name__c = GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_AWAITING_APPROVAL
                )
            );
            requests.add(
                new Program_Request__c(
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3),
                    Stage_Name__c = GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_APPROVED
                )
            );
            requests.add(
                new Program_Request__c(
                    Start_Date__c = System.today().addDays(-3),
                    End_Date__c = System.today().addDays(3),
                    Stage_Name__c = GEA_Constants.PROGRAM_REQUEST_STAGE_NAME_REJECTED
                )
            );

            insert requests;

            List<Database.DeleteResult> deleteResults = Database.delete(requests, false);

            Integer unsuccessfulDeletionsCount = 0;
            for (Database.DeleteResult result : deleteResults) {
                if (!result.isSuccess()) {
                    unsuccessfulDeletionsCount++;
                    System.assert(
                        result.getErrors()[0].getMessage().contains(Label.PS_CANNOT_DELETE_CUSTOMER_PROGRAM),
                        'Exception message should contain: \'' + Label.PS_CANNOT_DELETE_CUSTOMER_PROGRAM + '\''
                    );
                }
            }
            System.assertEquals(
                requests.size(),
                unsuccessfulDeletionsCount,
                'Number of unsuccessful deletions should be equals ' + requests.size()
            );
        }
    }

    static testMethod void testEmptyMethods () {
        new PS_ProgramRequest_TriggerHandler().beforeInsert(null);
        new PS_ProgramRequest_TriggerHandler().beforeDelete(null);
        new PS_ProgramRequest_TriggerHandler().beforeUpdate(null, null);
        new PS_ProgramRequest_TriggerHandler().afterUpdate(null, null);
        new PS_ProgramRequest_TriggerHandler().afterDelete(null);
    }
}
/**
 * Batch Apex to create Portal User from Person Account
 * 09/08/2023
 */

 global class CreatePortalUserFromPersonAccountBatch implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        // Query Person Accounts that meet your criteria
        String query = 'SELECT Id, FirstName, LastName, PersonEmail FROM Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accList){
        List<User> portalUsersToCreate = new List<User>();

        Id accountId = '0018B00000PT2QNQA1';
        ID contactId = [SELECT Id FROM CONTACT WHERE AccountId = :accountId LImit 1].Id; 
        for(Account personAccount : accList){
            // Create a User record for each Person Account
            User portalUser = new User();

            portalUser.FirstName = personAccount.FirstName;
            portalUser.LastName = personAccount.LastName;  
            portalUser.Username = personAccount.PersonEmail;
            portalUser.Email = personAccount.PersonEmail;
            //portalUser.ContactId = [SELECT Id FROM Contact WHERE AccountId = :personAccount.Id LIMIT 1].Id;
            portalUser.ContactId = contactId;
            portalUser.ProfileId = '0058B0000035mZjQAI';
            portalUser.Alias = 'abc';
            portalUser.LocaleSidKey = 'en_US';
            portalUser.LanguageLocaleKey = 'en_US';
            portalUser.EmailEncodingKey = 'UTF-8';
            portalUser.TimeZoneSidKey = 'America/New_York';
            portalUsersToCreate.add(portalUser);
        }
        // Insert the portal users
        try {
            if (!portalUsersToCreate.isEmpty()) {
                Database.insert(portalUsersToCreate, false);
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }

    global void finish(Database.BatchableContext BC) {

        // Perform any post-processing actions here

    }
}
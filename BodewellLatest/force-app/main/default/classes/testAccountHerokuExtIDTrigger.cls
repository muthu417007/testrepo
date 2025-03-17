@isTest
public class testAccountHerokuExtIDTrigger {

        static testMethod void testBulkInsert() {
    
            List<account> accounts = new List<account>();
    
            Profile p = [select id from profile where name='System Administrator'];
            // create a user to run the test as
            User u = new User(alias = 'eft92160', email='eft92160@eftemail.com',
                emailencodingkey='UTF-8', lastname='eft92160', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',
                timezonesidkey='America/Los_Angeles', username='eft92160@eftemail.com');
            insert u;
    
            Profile p1 = [select id from profile where name='Customer Care'];
            // create a user to own the contact
            User u1 = new User(alias = 'eft9216', email='eft9216@eftemail.com',
                emailencodingkey='UTF-8', lastname='eft9216', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1.Id, country='United States',
                timezonesidkey='America/Los_Angeles', username='eft9216@eftemail.com');
            insert u1;
        

    
            // add 200 accounts to the list to be inserted
            for (Integer i=0;i<200;i++) {
    
                account a = new account(
                    name='Ed Tjarks Test',
                    LocationID__c='EFT-TEST'+string.valueof(i),
                    OwnerId = u1.Id
                );
                accounts.add(a);
    
            }
    
            // Switch to the runtime context
            Test.startTest();  
    
            // run as a different user to test security and rights
            System.runAs(u) {
                insert accounts;
            }
    
            // Switch back to the original context
            Test.stopTest();     
    
            // query for all contacts created
            for (account acct2 : [Select Heroku_Ext_Id__c from account Where OwnerId = :u1.Id])
                System.debug('GEA Account ID: '+acct2.id+' Heroku Ext ID: '+acct2.Heroku_Ext_Id__c);
    
        }
}